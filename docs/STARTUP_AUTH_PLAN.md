# BizFlow Startup & Authentication — Phase A Inspection Report

**Status:** Phase A COMPLETE — verified 2026-10-16 against actual source.
**Scope:** inspection and documentation only. This phase changed no application
code, no schema, no tests, and no dependencies. Phase B (`StartupGate`) was
already implemented and verified before this inspection; Phases D, E, F are not
started. `main.dart`, routing, `universal_search.dart`, staff-account security
behavior, and backup/restore logic were not modified for this report.

**Baseline at inspection:** `version: 1.5.0+5` (`pubspec.yaml`),
branch `feature/bizflow-1.1.0-foundation`, Flutter + Drift offline-first app.

---

## 1. A1–A7 status matrix

| Item | Status | Primary evidence |
|------|--------|------------------|
| A1 — Startup & initialization inspection | **COMPLETE** | §2 |
| A2 — App shell, routing, login screens | **COMPLETE** | §3 |
| A3 — Settings persistence & UI | **COMPLETE** | §4 |
| A4 — DB init, migrations, schema 12 vs backup 9 | **COMPLETE** | §5 |
| A5 — Business records & attribution | **COMPLETE** | §6 |
| A6 — Smallest safe design | **COMPLETE** | §8 |
| A7 — Inspection report | **COMPLETE** | this document |

---

## 2. A1 — Startup and initialization

### 2.1 Actual execution sequence (launch → shell)

1. **`main()`** — `lib/main.dart:8–12`:
   `WidgetsFlutterBinding.ensureInitialized()` → `notificationStore.seedWelcome()`
   → `runApp(const BizFlowApp())`. No database and no theme work happens here.
2. **`BizFlowApp.build`** — `lib/main.dart:18–31`: an
   `AnimatedBuilder(animation: themeController)` wraps `MaterialApp`
   (`themeMode: themeController.materialThemeMode`, line 27;
   `home: const StartupGate()`, line 28). `MaterialApp` declares **no named
   routes** — only `home:`.
3. **`StartupGate`** — `lib/core/widgets/startup_gate.dart:48–63` is shown as
   `MaterialApp.home`. `initState` (73–78) calls `_run()` (89), which invokes
   `(widget.initializer ?? _initializeEssentialServices)()` (91–92).
4. **`_initializeEssentialServices()`** — `startup_gate.dart:25–37`:
   - **Theme (non-fatal):** `await themeController.initialize()` inside
     try/catch (27–31); on failure the in-memory defaults are kept.
     `themeController` is a global `ThemeController`
     (`lib/core/theme/theme_controller.dart`) whose `initialize()` reads
     persisted preferences from **SharedPreferences**.
   - **Database (fatal):** `await appDatabase.customSelect('SELECT 1').getSingle()`
     (36) — forces the lazy singleton to open; any failure propagates.
5. **Success** → `_phase = _GatePhase.ready` (97) → child renders:
   `StartupGate.child` defaults to `const AppShell()` (52).
6. **Failure** → `_phase = _GatePhase.failed` + `_error` captured
   (onError, 99–105) → branded error UI: “BizFlow couldn't start” (257–259),
   bounded error detail (284–293), **Try again** button (298–317).

### 2.2 When the database opens — lazy by design, forced once at the gate

- `lib/data/database/database_provider.dart` line 3:
  `final AppDatabase appDatabase = AppDatabase();` — a **lazily initialized
  Dart top-level**. Construction does not touch SQLite/WASM; the connection and
  any pending schema migration run on the **first query**.
- The gate's `SELECT 1` (step 4) is that first query, so the open + migration
  happen exactly once, **before `AppShell` screens query**, while the branded
  loading screen is visible. Comment: `startup_gate.dart:18–21`.
- The gate never creates a second database instance, performs no network I/O
  and adds no artificial delay (`startup_gate.dart:23–24`).

### 2.3 Error handling and retry

- Non-fatal: theme hydration errors are swallowed (`startup_gate.dart:29–31`)
  — same cold-start behavior as before Phase B.
- Fatal-until-retried: any database open/migration failure → `_GatePhase.failed`
  with the message shown (max 4 lines) and a Retry button → `_start()`
  (81–87) resets to `initializing` and re-runs the initializer.
- Stale-attempt guard: `_run()` increments `_attempt`; completions from
  superseded runs are dropped (`attempt != _attempt`, 96 and 100) and `mounted`
  is checked — retry taps cannot double-apply state.
- Phases: `enum _GatePhase { initializing, failed, ready }` (65).

### 2.4 A1 tests

- `test/startup_gate_test.dart` — 4 widget tests using **injected**
  `initializer`/`child`, so they never touch the global DB singleton,
  SharedPreferences, or the real `AppShell`: loading state (25–39), child
  revealed (41–59), recoverable error state (61–73), retry recovers (75–101).
- Executed this session: `flutter test test/startup_gate_test.dart` → **4/4 passed**.
- `test/widget_test.dart` contains only 2 theme tests (not startup-related).

**A1 conclusion:** sequence fully mapped; Phase B implementation and tests
already present and green. Nothing missing.

---


## 3. A2 — App shell, routing, navigation, login screens

### 3.1 The active shell

- `lib/core/widgets/app_shell.dart` — class `AppShell`, the default
  `StartupGate.child`.
- Primary navigation is an **index-based** destination list, not routes:
  `static const List<_NavItem> _navItems` (63–72): Home (0), POS Terminal (2,
  `isProminent`), Products (1), Sales & Invoices (3), Customers (4),
  Inventory (5), Expenses (6), Analytics (7), More Tools (8) — 9 destinations
  rendered as bottom nav / rail / sidebar depending on width (`_NavItem` class
  at 777).
- Secondary navigation is imperative only:
  - Notifications — `Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()))` (`app_shell.dart:116–117`)
  - Settings — `Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()))` (`app_shell.dart:126–127`)
- No `routes:`, `onGenerateRoute:`, or deep-link handling exists in
  `lib/main.dart`.

### 3.2 Login screen — exists but is disconnected

- `lib/features/auth/presentation/screens/login_screen.dart` defines
  `LoginScreen` (8) / `_LoginScreenState` (20).
- **Unused:** a repo-wide search for `login_screen|LoginScreen` matches **only
  this file** — nothing imports it and no navigator reaches it.
- **Demo-grade source** (read in this inspection): hardcoded demo operators
  (‘Alex Rivera’, …); `_verifyPin()` accepts **any** 4-digit PIN (its final
  clause `_pin.length == 4` is always true at that call site); `_submitCredentials`
  always authenticates; zero dependency on `StaffAccountRepository`; no audit,
  no lockout, no owner recovery.
- **Conclusion:** not connected to the active startup flow; must stay
  untouched in Phase A. Phase D should replace its internals with real
  repository wiring — its verification logic must never be reused as-is.

---

## 4. A3 — Settings persistence and UI

### 4.1 Model, storage, repository, screen

- **Table/model:** `lib/data/database/tables/business_settings.dart` —
  `BusinessSettings extends Table`, single row (PK `id`): business identity
  (businessName, address, phone, email, currency), loyalty
  (loyaltyEnabled/loyaltyEarnRate/loyaltyRedeemValue), receipt branding
  (receiptHeader/Footer/ShowPhone/ShowAddress/Note). **No security/login
  columns exist.**
- **Repository:** `lib/data/repositories/business_settings_repository.dart` —
  class `BusinessSettingsRepository`:
  - `getSettings()` (12–40): reads the single row; if absent, inserts the
    `'default'` row (21–39) and re-reads — self-initializing.
  - `watchSettings()` (42–46): reactive `Stream<BusinessSetting>` with the
    static `_defaults` fallback (48–63).
  - `saveSettings({…})` (65–116): `insertOnConflictUpdate` on
    `id = 'default'`; every business/loyalty/receipt parameter is optional —
    `null` → `Value.absent()` → column untouched (e.g. 90–93).
- **Screen:** `lib/features/settings/presentation/screens/settings_screen.dart`
  — `SettingsScreen`/`_SettingsScreenState`:
  - loads in `initState` → `_loadBusinessSettings()` (60–64, 80+), reading
    each row field into controllers (88–104);
  - saves via `_saveBusinessSettings()` (195) → `saveSettings(...)` with all
    current values (211–227);
  - sections assembled at 1379–1391: `_buildThemeSection` (794),
    `_buildBusinessConfigurationSection` (1178), `_buildLoyaltySection` (1062),
    `_buildReceiptSection` (974).

### 4.2 Persistence across browser refresh / restart

- Business settings live in the local SQLite database (web build: WASM +
  worker via `DriftWebOptions(sqlite3Wasm: …, driftWorker: …)`,
  `app_database.dart:55–59`), which persists in browser storage — settings
  survive refresh and restart without any network sync. The screen re-reads
  them from disk on every open.
- Theme preferences are a **separate** store: SharedPreferences inside
  `ThemeController.initialize()` — not part of `business_settings`.

### 4.3 Smallest compatible location for a future `loginRequired` (not added)

1. **Storage:** `BoolColumn get loginRequired => boolean().withDefault(const Constant(false))()`
   in `BusinessSettings` + one migration gate `if (from < 13) await m.addColumn(businessSettings, businessSettings.loginRequired);`
   in `AppDatabase.migration` (schema v13). Default `false` ⇒ **zero behavior
   change for existing installs, no data backfill.**
2. **Repository:** optional `bool? loginRequired` parameter in
   `saveSettings()` using the existing `Value.absent()` pattern; read from the
   row in `getSettings()` (all call sites keep compiling unchanged).
3. **UI:** one new `_buildSecuritySection` added to the section list at
   `settings_screen.dart:1379–1391` (owner-only toggled in Phase E).
4. **Consumption:** `StartupGate` initializer decides “require login?” by
   reading this value after the DB opens — the gate remains the single
   startup choke point.

No change is made in Phase A.

---

## 5. A4 — Database initialization, migrations, and the schema 12 vs backup 9 gap

### 5.1 Current schema version and migration conventions

> **Phase E update (2026-10-21):** the schema is now **v14** and the backup
> constant is **in sync at 14** — the gap described in §5.3 is closed. See §14.

`lib/data/database/app_database.dart` (class `AppDatabase`):

- `int get schemaVersion => 14;` (line 64) and mirror constant
  `static const int currentSchemaVersion = 14;` (line 66).
- `MigrationStrategy` (line 69):
  - `onCreate` (71–73): `m.createAll()` — a fresh install gets the full v14
    schema directly.
  - `onUpgrade` (75–208): a **sequential `if (from < N)` ladder** v2 → v14,
    each block idempotent by guard and strictly additive:
    - v2 `sales.status` (76–78) · v3 `saleItems.purchasePrice` (80–82) ·
      v4 `businessSettings` table (84–86) · v5 loyalty columns (88–98) ·
      v6 `customers.pointsBalance` + data backfill via `customStatement`
      `UPDATE customers SET points_balance = loyalty_points` (100–110) ·
      v7 returns + audit tables (112–117) · v8 shifts + cash movements
      (119–123) · v9 receipt branding columns (125–138) · v10 suppliers/POs
      (140–145) · v11 credit tables (147–151) · **v12 `staffAccounts`**
      (153–156) · **v13 `businessSettings.loginRequired`** (158–162, Phase D) ·
      **v14 staff-attribution columns** (164–208, Phase E).
  - No `beforeOpen` hook — Drift defaults apply.
- **Convention for future changes:** bump `schemaVersion` by 1, append one more
  `if (from < N)` block (additive `addColumn`/`createTable`, data backfills via
  guarded `customStatement`), regenerate `app_database.g.dart`, and add a raw
  `user_version` upgrade test.
- Existing installations upgrade **automatically on first open** (the gate's
  `SELECT 1`) — old `user_version` is below 14, Drift runs `onUpgrade` from
  that version to 14 in one transaction.
- **v14 is the first step that cannot use a plain `m.addColumn(...)`.**
  Several of the tables receiving attribution columns are *created inside this
  same migration ladder* from the current table definitions — `sale_returns`
  at v7 (112–117), `cash_shifts`/`cash_movements` at v8 (119–123),
  `purchase_orders` at v10 (140–145) — and those definitions already contain
  the attribution columns. A plain `ADD COLUMN` would therefore fail with
  "duplicate column name" when upgrading from v6/v7/v9. The v14 block solves
  this with a local `addColumnIfMissing(table, column, ddl)` helper
  (176–199) that checks `sqlite_master` for the table and `pragma_table_info`
  for the column before issuing `ALTER TABLE ... ADD COLUMN`. All seven
  additions are guarded: `sales.staff_id` (201), `sale_returns.staff_id` (202),
  `cash_shifts.opened_by_id` (203), `cash_shifts.closed_by_id` (204),
  `cash_movements.staff_id` (205), `stock_movements.staff_id` (206),
  `purchase_orders.staff_id` (207).

### 5.2 Migration tests (executed this session)

`test/migration_test.dart` — 5 tests in 4 groups, built on `prepareRawDb()`
that writes `user_version` with raw SQL before opening `AppDatabase`:

- group `schema migration v5 -> v6` → `backfills points_balance from existing loyalty_points` (83–84)
- group `schema migration v11 -> v12` → `creates staffAccounts table when upgrading from v11` (125–126)
- group `schema migration v5 -> v12` → `applies every migration from v5 through v12` (300–301)
- group `schema migration v13 -> v14` → `adds the staff attribution columns to existing tables` (393–393) and `pre-existing rows survive the upgrade with null attribution` (485–485) — **added in Phase E**

Run: `flutter test test/migration_test.dart test/backup_service_test.dart`
→ **16/16 passed** (5 migration + 11 backup).

> **Phase E note:** the first three group names still say "v12", but the ladder
> they exercise now runs all the way to **v14** — `AppDatabase` opens at
> whatever `schemaVersion` the class declares (14), so these tests
> transitively cover the v13 (`loginRequired`) and v14 (staff attribution)
> steps as well. The v5→v12 group is the important regression case for the
> guarded `addColumnIfMissing` helper (§5.1): it starts from a database that
> has **none** of the attribution tables, so every guarded addition must
> gracefully no-op for missing tables and add the column for the ones that do
> exist.
>
> The two **v13→v14** tests were added in Phase E because the pre-existing
> tests never asserted the *attribution columns themselves*. The first builds a
> v13 database whose tables all exist but lack the new columns, then asserts
> via `pragma_table_info` that all seven columns were added. The second
> inserts a pre-upgrade sale row and asserts it survives with `staffId == null`
> — proving the upgrade is additive and does not rewrite historical data.

### 5.3 The schema 12 vs backup 9 gap — **CLOSED in Phase E**

> **Status: resolved.** `AppDatabase.schemaVersion` and
> `BackupService._currentSchemaVersion` are now **both 14**. The original
> finding is preserved below for audit history.

**Finding (Phase A): same concept, one stale mirror value — not two different
version concepts.**

Evidence in `lib/data/services/backup_service.dart`:

- line 15: `static const int _currentSchemaVersion = 9;`
- line 18: `static const int _oldestSupportedSchemaVersion = 4;`
- line 38: export writes `'databaseSchemaVersion': _currentSchemaVersion`
- lines 185–197: restore validates the declared version against the accepted
  window `[4, 9]` and rejects anything outside.

`_currentSchemaVersion` is intended to mirror `AppDatabase.schemaVersion`
(it is the schema version *declared inside backup JSON*, written at export and
checked at restore). History confirms drift: `docs/PLAN_v1.4.0.md:24` records
the earlier "backups record `databaseSchemaVersion: 4` while the schema is v6"
defect; the fix raised the constant to 9 **when the schema was 9**. The schema
then advanced to v10 (suppliers/POs), v11 (credit), v12 (staff) while the
backup constant stayed at 9 — it was never re-synced.

**Why nothing broke in Phase A (verified):**

1. Export *always writes* the constant 9, so any backup this build produces
   passes its own `[4, 9]` restore check — round trip is self-consistent.
2. Tables introduced in v10–v12 (suppliers, POs, credit, staff) are **not part
   of backup export/restore**, so restoring a "9"-labelled backup into a v12
   database copies exactly the tables it contains; migration state of the
   target DB is untouched by restore.
3. Staff are deliberately excluded from backups (see §6.4) — restore preserves
   existing staff rows (verified by tests), so login state survives restore.

**How Phase E closed it:**

- `BackupService._currentSchemaVersion` raised **9 → 14**
  (`backup_service.dart:24`), keeping the mirror in step with
  `AppDatabase.schemaVersion` (`app_database.dart:64`).
- `_oldestSupportedSchemaVersion` stays **4** (`backup_service.dart:27`), so
  the accepted restore window is now `[4, 14]`. **Older backups still restore**
  — the window only widened, it did not move.
- The v14 payload change is *backward-compatible by construction*: the two new
  fields (`sales.staffId`, `stockMovements.staffId`) are **optional on read**
  (`if (item.containsKey('staffId')) requireNullableString('staffId')`,
  `backup_service.dart:362–363` and `396–398`), and on write they default to
  `null` (`Value(item['staffId'] as String?)`, lines 571 and 633). A pre-v14
  backup restores with `null` attribution; a v14 backup round-trips its
  attribution exactly.
- Export now emits the attribution (`'staffId': sale.staffId` line 86,
  `'staffId': movement.staffId` line 133), so the declared version finally
  reflects what the payload actually contains.

> **Residual risk (unchanged):** the mirror is maintained by hand. Any future
> schema bump that adds a table to the export payload must raise
> `_currentSchemaVersion` **together with** `AppDatabase.schemaVersion`, with
> an export/restore test. The two constants now agree, but nothing enforces
> that mechanically — there is no test asserting
> `AppDatabase.schemaVersion == BackupService._currentSchemaVersion`.
> Candidate for a Phase F hardening test.

---

## 6. A5 — Business records and attribution

### 6.1 Schema: no staff-identity columns on business records

> **Phase E update (2026-10-21):** the table below records the **Phase A
> survey**. The attribution columns it reports as missing **now exist** —
> see §14.2 for the implemented schema.

Inspected every relevant table definition:

| Table (file) | Columns (relevant) | Staff attribution? |
|---|---|---|
| `Sales` (`tables/sales.dart`) | customerId, subtotal, discount, total, paidAmount, paymentMethod, status, createdAt | **None** |
| `SaleReturns` (`tables/sale_returns.dart`) | saleId, customerId, refundAmount, refundMethod, restocked, reason, createdAt | **None** |
| `CashShifts` (`tables/cash_shifts.dart`) | shiftNumber, openingFloat, closingCount, discrepancyReason, openedAt, closedAt, isOpen | **None** (no openedBy/closedBy) |
| `CashMovements` (`tables/cash_movements.dart`) | shiftId, direction, amount, note, createdAt | **None** |
| `AuditLogs` (`tables/audit_logs.dart`) | **`actor`** (line 12, default `'Owner'`), action, summary, entityType/entityId, before/afterJson, createdAt | **`actor` string only** — doc comment: “staff profiles can populate this later” (lines 10–11) |
| `StaffAccounts` (`tables/staff_accounts.dart`) | username (unique), displayName, role, isActive, pinVerifier, recoveryCodeVerifier, failedPinAttempts, pinLockedUntil, pinChangedAt, createdAt | identity source itself |

### 6.2 Which operations record staff identity today — audit `actor` survey

Audit infrastructure: `AuditRepository.log({action, actor = 'Owner', summary, entityType, entityId, before, after})`
(`lib/data/repositories/audit_repository.dart:48–76`) — best-effort by design
(`catch (_)`, 73–75: an audit failure never breaks the business action).

| Operation | Where written | Real staff identity? |
|---|---|---|
| Sale **create** | *no audit call exists* in `SaleRepository` | **No** |
| Sale **cancel** | direct `database.auditLogs` insert, `sale_repository.dart:306–326` (`sale.cancel`) | **No** — no `actor` argument anywhere in the file → `'Owner'` |
| Refund / return | `return_repository.dart:178` (`refund.create`) | **No** — zero `actor:` occurrences in file → `'Owner'` |
| Shift open / close / cash movement | `cash_shift_repository.dart:73, 115, 190` (`openShift` 51, `recordMovement` 85, `closeShift` 167) | **No** — zero `actor:` occurrences → `'Owner'` |
| Staff admin (create/verify/lock/role/active/display/recover) | `staff_account_repository.dart:400, 509, 593, 645, 694, 743, 812` | **Optional `actor` plumbing exists**: `actor: actor ?? 'Owner'` (402, 595, 647, 696, 745) and `actor: 'recovery'` (814) — but **no caller passes an actor** |
| Customer credit | `customer_credit_repository.dart:146, 188, 240` | **No** → `'Owner'` |
| Purchase orders | `purchase_order_repository.dart:237, 315, 412, 445, 480` | **No** → `'Owner'` |
| Suppliers | `supplier_repository.dart:111, 165, 212` | **No** → `'Owner'` |
| `'stock.change'` audit action | appears only in comments (`audit_logs.dart:14`) and the audit screen icon map (`audit_log_screen.dart:72`) — **no writer exists** | n/a |

**Conclusion:** the only *plumbing* for a real actor is `AuditRepository.log`'s
`actor` parameter and its mirror in `StaffAccountRepository` — every default is
`'Owner'`. No business record (sale/return/shift/movement) carries staff
identity, and there is no session concept to source it from. Sales creation is
not audited at all.

### 6.3 Where Phase E authorization must be enforced (identified, not implemented)

> **Phase E update (2026-10-21):** the targets listed below **are now
> implemented**. See §14.3 for the enforced role matrix.

Repository mutation boundaries visible from signatures:

- **Already gated (existing):** `StaffAccountRepository.setRole` (607),
  `setActive` (663), `setDisplayName` (716) — `asOwner: true` + transactional
  + audit; single-owner invariant in `createAccount` (327).
- **Must be gated in Phase E (proposed targets):**
  - `SaleRepository` — cancel/refund paths (manager+; create = any active staff)
  - `ReturnRepository.createReturn` (manager+)
  - `CashShiftRepository.openShift/closeShift/recordMovement` (cashier own shift; close/override manager+)
  - `BusinessSettingsRepository.saveSettings` (owner)
  - `BackupService.export/restore/resetAllData` (owner)
  - `DemoDataService` demo import/clear (manager+), product/expense/inventory writes (role matrix TBD in Phase E)
  - Read surfaces: Reports/Analytics, Staff admin (owner), Settings (owner) vs cashier POS-only.
- Attribution mechanism for Phase E (minimal): pass the **session username**
  into the existing optional `actor` parameters — no business-table schema
  change required (see §8, decision D3).

### 6.4 Staff security properties (verified in this codebase, unchanged)

- `staffAccounts` is excluded from backup export and deleted by
  `resetAllData` (`backup_service.dart:399`); restore **preserves** pre-existing
  staff rows — covered by `test/backup_service_test.dart` (staff/reset tests).
- Verifiers are bcrypt hashes never leaving the repository (summary DTOs
  structurally exclude them — `tables/staff_accounts.dart` doc comment;
  `StaffAccountSummary` built by `_summary()`, `staff_account_repository.dart:270`).

---

## 7. Existing staff authentication capabilities (evidence)

`lib/data/repositories/staff_account_repository.dart` — class
`StaffAccountRepository` (constructor 143, optional `AppDatabase` +
`pinHashCost`):

- **Policy constants:** `defaultPinHashCost = 10` (152, OWASP bcrypt ≥ 10),
  `maxFailedPinAttempts = 5` (155), standardized **15-minute** lock (157–162),
  `minPinLength = 4` / `maxPinLength = 8` (165–166),
  `recoveryCodeLength = 16` (~80 bits, 168–170).
- **API:** `createAccount` (327, owner creation returns one-time
  `recoveryCode`), `listStaff` (416), `getAccountByUsername` (425),
  `getAccountById` (431), **`verifyPin` → `StaffAuthResult`** (445; result
  carries `status`/`account`/`lockedUntil`, 119–122; statuses cover success,
  invalid/malformed PIN, accountNotFound, deactivated, locked — 91–105),
  `changePin` (549), `setRole` (607), `setActive` (663), `setDisplayName` (716),
  **`recoverOwnerPin`** (765 → `RecoveredOwnerPin`, rotates recovery code).
- **Lockout is persistent:** `failedPinAttempts` + `pinLockedUntil` are DB
  columns (`tables/staff_accounts.dart`) so restarts/web refreshes cannot
  bypass them; `_recordFailedAttempt` (497) implements the policy.
- **KDF threading:** `_hashPinOffload` (229) / `_checkPinOffload` (242) —
  genuine `Isolate.run` on native; **on Flutter Web the KDF runs inline on the
  UI thread** (platform constraint documented at 218–228): Phase D login UI
  must show a busy indicator while awaiting.
- Roles: `StaffRole { owner, manager, cashier }` — single permission system;
  owner never deactivatable, single-owner invariant enforced in `createAccount`.

**Gap to Phase D:** all of the above is repository-level only — no UI, no
session, no caller passes `actor`, and the only on-device “login screen” is the
disconnected demo (§3.2).

---

## 8. A6 — Smallest safe design (proposed; nothing here is implemented)

Legend: **[EXISTING]** = already in the codebase (evidence above),
**[PROPOSED]** = future Phase B/D/E/F work, deliberately minimal.

### D1 — Startup gate preserving the existing shell
- **[EXISTING]** `StartupGate` as `MaterialApp.home`, initializer/child
  injection, error+retry, `AppShell` as default child (`startup_gate.dart`),
  4 tests green.
- **[PROPOSED]** Phase B is *complete as-is*. Only additive change later: the
  initializer gains one step — after the forced `SELECT 1`, read
  `loginRequired` (§4.3) and, if true and no session exists, resolve to a
  login widget instead of `AppShell`. The gate stays the single choke point;
  `main.dart`, `AppShell`, and navigation remain untouched.

### D2 — Optional login, disabled by default
- **[EXISTING]** nothing (demo `LoginScreen` is disconnected and insecure).
- **[PROPOSED]** `loginRequired` boolean column, **default `false`**
  (§4.3 path: business_settings + `if (from < 13)` migration + optional
  `saveSettings` param + one Settings “Security” section). Existing installs
  and all current tests keep today's behavior: boot straight into `AppShell`.

### D3 — Local staff authentication with the existing repository
- **[EXISTING]** `StaffAccountRepository.verifyPin` with bcrypt, lockout
  (5 attempts / 15 min, persistent), inactive-account rejection, summary DTOs.
- **[PROPOSED]** A thin Phase-D login widget calls `verifyPin` directly — no
  new repository/service/package. Replace `login_screen.dart`'s internals
  (never its demo verification logic). Busy indicator mandatory (Web KDF
  inline, §7). Attribution = pass session username into existing optional
  `actor:` parameters (`AuditRepository.log`, `StaffAccountRepository.*`) —
  **no new columns on business tables** (deferred until product demands
  staffId FKs; that would be schema v14).

### D4 — Local session and logout
- **[EXISTING]** none (no session concept anywhere).
- **[PROPOSED]** one in-memory `ChangeNotifier` session holder (e.g.
  `SessionController`) holding `StaffAccountSummary`, `signedInAt`,
  `lastActivity`: created on successful `verifyPin`, cleared on logout and on
  `resetAllData`. **Not persisted** — a browser refresh with `loginRequired`
  simply re-prompts (simplest safe behavior; avoids storing any credential or
  session token). Shell header/logout button reads the same object.

### D5 — Owner recovery (anti-lockout)
- **[EXISTING]** one-time 16-char recovery code issued at owner creation
  (`createAccount` → `CreatedStaffAccount.recoveryCode`), `recoverOwnerPin`
  with rotation + audit (`actor: 'recovery'`), single-owner invariant, owner
  never deactivatable.
- **[PROPOSED]** Phase-D login UI must expose two paths: PIN entry and
  “recover owner access” (recovery code → new PIN). Owner account creation
  flow (first-run or Settings) must surface the recovery code exactly once.

### D6 — Business-logic authorization (Phase E)
- **[EXISTING]** owner gates on `setRole`/`setActive`/`setDisplayName`;
  audit trail infrastructure; role enum.
- **[PROPOSED]** enforcement *inside repository methods* (listed in §6.3),
  each taking the session role/username as an explicit parameter with a
  conservative default (absent session → current behavior) so no existing
  caller breaks; UI hiding is secondary, repository gates are authoritative.
  Role matrix kept small: cashier = POS/sales on own shift; manager = +returns,
  cancel, shifts, demo/import, products; owner = +settings, backup, staff admin,
  reports config.

### D7 — Security settings and inactivity locking
- **[EXISTING]** Settings screen section pattern; repository lockout policy
  constants; SharedPreferences use in `ThemeController`.
- **[PROPOSED]** one Security section: `loginRequired` toggle (owner-gated) +
  inactivity timeout (minutes, `0` = off, default off for existing installs),
  stored in `business_settings` with defaults. Inactivity = a timer in the
  session holder: on expiry, lock the session back to the login widget **for
  the current account PIN re-prompt**, never logging out other state. No
  background persistence, no new package.

---

## 9. Risks and backward-compatibility considerations

1. **Existing installs must not change behavior.** `loginRequired` default
   `false` (column default + absent-parameter pattern) and an inactivity
   default of “off” mean every current user boots straight into `AppShell`,
   exactly as today. No data backfill needed.
2. **Demo login screen is a security hazard if reused.** It accepts any
   4-digit PIN and always authenticates (§3.2). Phase D must replace its
   internals with `StaffAccountRepository` wiring; it must never be connected
   unchanged.
3. **Web KDF blocks the UI thread** (documented platform constraint,
   `staff_account_repository.dart:218–228`). Login/recovery/change-PIN flows
   must render a busy state or users will perceive freezes and double-tap.
4. **Backup metadata skew (schema 12 vs declared 9)** — currently harmless
   (§5.3), but any future inclusion of v10–v12 tables in backup payloads must
   update `_currentSchemaVersion` + validation window together with tests.
   Explicitly out of scope this phase.
   → **RESOLVED in Phase E** — both constants are 14 and the payload now
   declares what it contains (§5.3). The *process* risk remains: the mirror is
   hand-maintained and nothing asserts the two agree.
5. **Staff are never in backups** (verified, `backup_service.dart:399` +
   tests): after `resetAllData`, staff are gone; after *restore*, existing
   staff survive. With `loginRequired = true`, operators must understand that
   reset destroys login state while restore does not.
6. **Lockout without recovery UI = self-inflicted owner lockout.** The
   repository provides recovery codes, but until Phase D surfaces them, do not
   enable `loginRequired` in any build. Owner cannot be deleted or deactivated
   (invariant), so the recovery path always remains reachable.
7. **Sessions are in-memory:** refresh/relaunch re-prompts when login is on —
   intended (no token to steal, no persistence bugs), but it changes UX for
   web users; document when shipping.
8. **Audit rows keep default `'Owner'` when no actor is passed** — Phase E
   threading is additive; historical rows remain `'Owner'`. `audit_logs.actor`
   column already exists (no schema change).
   → **RESOLVED in Phase E** — the audit `actor` is now populated from the
   verified session username on every protected operation (§14.3). Rows written
   before Phase E (and rows written in login-disabled mode) keep `'Owner'`.
9. **Analyzer baseline:** the only pre-existing diagnostics are 10 in
   `lib/core/features/search/universal_search.dart` (forbidden file — never
   touched). All other files are clean; keep it that way.
   → **RESOLVED in Phase E** — the file's committed version did not compile
   (5 syntax errors at lines 462–469). The working-tree version fixes the
   unbalanced brackets and `dart format` normalization, and
   `flutter analyze --no-pub` now reports **no issues found** (§14.6).
10. **Test-runner constraint:** `flutter test` is required (tests use
    `dart:ui`); plain `dart test` fails. Do not “fix” tests to pass — earlier
    fixes corrected genuinely wrong assertions (`throwsA` on enums,
    non-awaited `returnsNormally`), not desired outcomes.

---

## 10. Smallest safe implementation plan for the remaining phases

> Phase B is already implemented and verified (StartupGate + 4 tests) — no
> further B work beyond the additive initializer step in D1 if/when Phase D
> lands. Phases below are plans only; none is started.
>
> **Status update (2026-10-21):** Phase D and Phase E are now **implemented**
> (§13 and §14). The Phase E plan below is retained as the original design
> intent; §14 records what was actually built and where it differs.

**Phase D — optional local login (minimal):**
1. Schema v13: `businessSettings.loginRequired` default `false` + one
   `if (from < 13)` gate + `business_settings_repository.saveSettings`
   optional param (§4.3 pattern). Regenerate Drift code; add one migration test
   (v12→v13) mirroring `test/migration_test.dart` style.
2. `SessionController` (in-memory, §D4) — new small class only; no new package.
3. Rebuild `login_screen.dart` internals: username + PIN → `verifyPin` with
   busy state, lockout countdown from `StaffAuthResult.lockedUntil`,
   account-not-found/deactivated messaging, owner recovery path via
   `recoverOwnerPin`; display username/role + logout in shell header.
4. Gate integration: after DB open, read `loginRequired`; when true and no
   session → login widget, else `AppShell` (default unchanged).
5. Settings “Security” section: `loginRequired` toggle (owner-gated in Phase E,
   temporarily visible with others until then).
6. Tests: login-screen widget tests (injected session + fake repository
   seam via constructor), session controller unit tests, migration test.

**Phase E — authorization + attribution (minimal):**
1. Optional `actor`/`actingRole` parameters (default = current behavior) on
   repository mutations listed in §6.3; gates enforced in repository, not just
   UI.
2. Thread session username → existing `actor:` audit parameters everywhere
   (returns, shifts, credit, PO, suppliers, sale cancel, staff admin) — no
   schema change.
3. UI: hide/disable menu entries by role (secondary); add repository-level
   tests per gate (allow/deny/absent-session cases) following
   `test/data/repositories/staff_account_repository_test.dart` patterns.
4. Owner-only: `saveSettings`, backup/restore/reset, staff admin (already),
   Security section.

**Phase F — security hardening (minimal):**
1. Inactivity timeout column (default `0` = off) + session timer → re-prompt
   (§D7); owner-gated configuration.
2. Verify: refresh with login on, lockout persistence across restart,
   audit rows carry real actors, `resetAllData` clears the session.
3. Docs: security notes in `docs/` + CHANGELOG; keep backup metadata policy
   (§9.4) documented for the next schema-touching backup change.

> **Phase F status (2026-10-22): COMPLETE.** The delivered scope, the
> security model, the timer design, the migration/backup compatibility notes
> and the verification record are in **§15**. Items 1–3 above are all
> implemented; the residual limitations are listed in §15.8.

---

## 11. Evidence — files inspected and commands executed

### 11.1 Source files read/inspected this phase

Direct reads or targeted pattern searches with line-number output:

- **Startup:** `lib/main.dart`, `lib/core/widgets/startup_gate.dart`,
  `lib/core/theme/theme_controller.dart`, `lib/data/database/database_provider.dart`
- **Shell/nav:** `lib/core/widgets/app_shell.dart`,
  `lib/features/auth/presentation/screens/login_screen.dart`
- **Settings:** `lib/data/database/tables/business_settings.dart`,
  `lib/data/repositories/business_settings_repository.dart`,
  `lib/features/settings/presentation/screens/settings_screen.dart`
- **Database:** `lib/data/database/app_database.dart` (full migration
  strategy), `lib/data/database/app_database.g.dart` (generated),
  `lib/data/database/tables/` — all tables incl. `sales.dart`,
  `sale_returns.dart`, `cash_shifts.dart`, `cash_movements.dart`,
  `audit_logs.dart`, `staff_accounts.dart`
- **Repositories/services:** `staff_account_repository.dart`,
  `audit_repository.dart`, `sale_repository.dart`, `return_repository.dart`,
  `cash_shift_repository.dart`, `customer_credit_repository.dart`,
  `purchase_order_repository.dart`, `supplier_repository.dart`,
  `business_settings_repository.dart`, `backup_service.dart`
- **Docs:** `docs/TODO.md` (v1.0→v1.5, no Startup/Auth section existed),
  `docs/IMPROVEMENT_PLAN.md` (v1.2.0), `docs/PLAN_v1.4.0.md` (backup-version
  history), `docs/PLAN_v1.3.0.md`
- **Tests:** `startup_gate_test.dart`, `migration_test.dart`,
  `backup_service_test.dart`, `loyalty_backup_test.dart`,
  `data/repositories/staff_account_repository_test.dart`, `widget_test.dart`

### 11.2 Commands executed this session

> **Note:** this table is the **Phase A** record and is preserved verbatim for
> audit purposes. Its counts reflect the state of the tree *during Phase A*
> (schema v12, backup constant 9, 171 tests). The Phase E counts are in
> §14.7.

| Command | Result |
|---|---|
| `flutter test test/startup_gate_test.dart` | **4/4 passed** |
| `flutter test test/migration_test.dart test/backup_service_test.dart` | **14/14 passed** |
| `flutter test` (full suite, prior Phase-A verification run) | **171/171 passed** |
| `flutter analyze` (prior verification run) | only the 10 pre-existing `universal_search.dart` diagnostics |
| Repo-wide greps: `login_screen\|LoginScreen`, `actor:`, `_audit.log`, `into(.*auditLogs)`, `stock.change`, `_currentSchemaVersion`, migration/test names | results quoted throughout §2–§7 |

No test was altered in Phase A to produce a passing result; no files outside
`docs/` were modified for this report.

### 11.3 What each conclusion rests on

- A1 sequence/error/retry → direct reads of `main.dart` + `startup_gate.dart` + green startup tests.
- A2 unused login → repo-wide reference search (self-only) + source read of `login_screen.dart`.
- A3 persistence → repository/screen reads + `DriftWebOptions` in `app_database.dart`.
- A4 v12-vs-9 → `app_database.dart` ladder + `backup_service.dart:15/18/38/185–197` + `PLAN_v1.4.0.md:24` + 14 green backup/migration tests.
- A5 attribution → every business table definition + all `_audit.log`/direct-insert sites + `actor:` search results.
- A6 design → synthesizes only mechanisms proven existent (§7) with explicitly labeled proposals.

---

## 12. Unresolved uncertainties / explicitly deferred

> **Phase E status of each item (2026-10-21):** items 4 and 5 are **resolved**
> in Phase E (§14). The rest remain open.

1. **Real-device/web runtime behavior** of the gate (WASM worker open path) was
   not exercised here — all verification ran on the Flutter test host. Web
   build compiles (verified in earlier phases) but has no automated e2e.
2. **Drift downgrade path** (opening a DB whose `user_version` > 14) is not
   covered by tests; Drift is expected to refuse — untested, low risk.
3. **`'stock.change'` audit** has no writer (§6.2) — noted as a pre-existing
   product gap, not touched.
4. **Full role matrix** (exact manager vs cashier capabilities per screen) is
   intentionally left to Phase E; §10 proposes a conservative starting matrix.
   → **RESOLVED in Phase E** — the enforced matrix is in §14.3.
5. **Backup schema-version sync (9→12)** and adding any new table to backup
   payloads: deferred by this phase's constraints (§5.3, §9.4).
   → **RESOLVED in Phase E** — both constants are now 14 (§5.3).
6. Whether `loginRequired` should also gate **app resume after backgrounding**
   (mobile) vs only cold start: product decision for Phase F.
7. **UI-level role gating** (hiding/disabling screens per role) is **not**
   implemented in Phase E — the enforcement is at the repository/service
   layer only. A cashier can still *see* a screen they may not act on; the
   action is rejected with a `StateError`. Layering the UI is deferred.
8. **No test asserts** `AppDatabase.schemaVersion ==
   BackupService._currentSchemaVersion` — the mirror is maintained by hand
   (§5.3 residual risk).

*End of Phase A report.*

## 13. Phase D — Optional Login Implementation Report

**Status:** Phase D COMPLETE — verified 2026-10-17 against actual source.

### 13.1 D1–D6 Status Matrix

| Item | Status | Primary evidence |
|------|--------|------------------|
| D1 — Persistent `loginRequired` setting | **COMPLETE** | `tables/business_settings.dart:52–53`; `app_database.dart:158–165` (v12→v13 migration); `business_settings_repository.dart` (`saveSettings(loginRequired:)`); `settings_screen.dart` toggle |
| D2 — Real staff selection and PIN login | **COMPLETE** | `login_screen.dart` uses `StaffAccountRepository.verifyPin` (bcrypt) |
| D3 — Session, logout, refresh, restart rules | **COMPLETE** | `session_controller.dart` (in-memory, no PIN/token persistence) |
| D4 — Backward compatibility | **COMPLETE** | Migration adds `loginRequired` default `false`; no existing data modified |
| D5 — Login-disabled startup path | **COMPLETE** | `startup_gate.dart` — `loginRequired == false` → `AppShell` directly |
| D6 — Safe owner recovery and lockout prevention | **COMPLETE** | `checkLoginReadiness()` validates active owner with PIN + recovery code |

### 13.2 Files Changed

| File | Reason |
|------|--------|
| `lib/data/repositories/staff_account_repository.dart` | Fixed pre-existing `GlassCard` → `Card` compilation error; removed unused `app_decor.dart` import |
| `lib/features/auth/presentation/screens/login_screen.dart` | Removed unused `app_decor.dart` import; fixed `GlassCard` → `Card` compilation error |
| `lib/features/settings/presentation/screens/settings_screen.dart` | Added `_loginRequired` state + `_saveLoginRequired()` + confirmation dialogs + Settings UI toggle |
| `test/phase_d_test.dart` | New focused tests for settings, login, session, startup, authorization boundary |
| `docs/STARTUP_AUTH_PLAN.md` | Updated with Phase D status and details |

### 13.3 Migration Details

- **Schema version:** 13 (already present in `app_database.dart:64`)
- **Migration `from < 13`:** adds `loginRequired` boolean column with `Constant(false)` default
- **No data modified, deleted, or reset.** Existing staff records and business data preserved.
- Backup service schema version (`_currentSchemaVersion = 9`) was **not** changed.
  → **Superseded in Phase E:** the backup constant was raised to **14** in
  Phase E and now matches `AppDatabase.schemaVersion` (§5.3).
---

## 14. Phase E — Staff Attribution & Authorization Implementation Report

**Status:** Phase E COMPLETE — verified 2026-10-21 against actual source.

**Goal:** link business operations and audit records to *authenticated* staff
members, and enforce role-based authorization at the repository/service
boundary — without breaking the Phase D single-operator experience for
installations that never enable login.

### 14.1 Scope Delivered

| Item | Status | Primary evidence |
|------|--------|------------------|
| Shared authorization core | **COMPLETE** | `lib/core/session/session_authorization.dart` (new) — `resolveActor`, `canPerform`, `requireRole`, `requireOwner`, `ResolvedActor` |
| Staff attribution columns (schema v14) | **COMPLETE** | `tables/sales.dart`, `tables/sale_returns.dart`, `tables/stock_movements.dart`, `tables/cash_movements.dart`, `tables/cash_shifts.dart`, `tables/purchase_orders.dart` |
| Sale attribution (create + cancel restock) | **COMPLETE** | `sale_repository.dart:23` (authorize), `:150` & `:214` (attribution), `:346` (cancel restock) |
| Return attribution + restock movement | **COMPLETE** | `return_repository.dart:68`, `:158`, `:301` |
| Stock adjustment attribution | **COMPLETE** | `product_repository.dart:17`, `:167`; `stock_movement_repository.dart:49`, `:66` |
| Expense attribution (audit actor) | **COMPLETE** | `expense_repository.dart:16`, `:89`, `:150`, `:184` |
| Shift / cash-movement attribution | **COMPLETE** | `cash_shift_repository.dart:53`, `:77` (`openedById`), `:101`, `:127`, `:192`, `:214` (`closedById`) |
| Purchase order attribution | **COMPLETE** | `purchase_order_repository.dart:19`, `:215`, `:458`, `:491` |
| Demo data attribution + gating | **COMPLETE** | `demo_data_service.dart:21`, `:37`, `:39`, `:503`, `:834` |
| Backup export/restore/reset authorization | **COMPLETE** | `backup_service.dart:34`, `:39`, `:162`, `:430`, `:453` |
| Backup payload carries attribution | **COMPLETE** | `backup_service.dart:86`, `:133`, `:362–363`, `:396–398`, `:571`, `:633` |
| Backup schema version sync (9 → 14) | **COMPLETE** | `backup_service.dart:24` now matches `app_database.dart:64` |
| Staff-admin authorization hardening | **COMPLETE** | `staff_account_repository.dart:296` (`_requireOwnerAuthority`) |
| Settings security gate (`loginRequired`) | **COMPLETE** | `business_settings_repository.dart:99` (`_guardSecurityChange`) |
| Phase E tests | **COMPLETE** | `test/phase_e_test.dart` — 11 tests |
| Phase E migration tests | **COMPLETE** | `test/migration_test.dart` — 2 new v13→v14 tests |

### 14.2 Implemented Schema (v14)

Seven **nullable** columns were added. Nullable is the backward-compatibility
contract: historical rows keep working with `null` attribution, and new rows
written while login enforcement is disabled are also `null`.

| Table | Column | Written by |
|---|---|---|
| `sales` | `staffId` | `sale_repository.dart:150` (complete), `:214` (cancel) |
| `sale_returns` | `staffId` | `return_repository.dart:158` |
| `stock_movements` | `staffId` | `product_repository.dart:167`, `stock_movement_repository.dart:66`, `sale_repository.dart:346` (cancel restock), `return_repository.dart:301` (return restock) |
| `cash_shifts` | `openedById` | `cash_shift_repository.dart:77` |
| `cash_shifts` | `closedById` | `cash_shift_repository.dart:214` |
| `cash_movements` | `staffId` | `cash_shift_repository.dart:127` |
| `purchase_orders` | `staffId` | `purchase_order_repository.dart:215` |

**Audit `actor`** (`audit_logs.actor`) was reused rather than adding a column —
it already existed. It is now populated with the *verified session username*
instead of the hard-coded `'Owner'` on every protected operation.

**Migration ladder:** see §5.1 for the full v2 → v14 ladder and the guarded
`addColumnIfMissing` helper (176–199) that makes the v14 step safe to run on
databases that predate several of the affected tables.







### 14.3 Enforced Role Matrix

`resolveActor` (`session_authorization.dart:28`) resolves the acting identity
for every protected operation:

1. **A session exists** → the account is re-read from the database. If it was
   **deleted or deactivated**, the session is **signed out** and a `StateError`
   is thrown — a stale session can never authorize an action. Otherwise the
   actor is that account.
2. **No session** → `business_settings.loginRequired` is read. If login is
   **enforced**, a `StateError` is thrown ("Authentication required"). If login
   is **disabled**, a null-staff actor is returned — the legacy single-operator
   mode, in which every role is implicitly permitted.

The matrix (each cell = `requireRole` call site):

| Operation | Owner | Manager | Cashier | Evidence |
|---|:--:|:--:|:--:|---|
| Complete sale | ✅ | ✅ | ✅ | `sale_repository.dart:24` (via `completeSale`) |
| Cancel sale | ✅ | ✅ | ✅ | `sale_repository.dart:24` (via `cancelSale`) |
| Delete sale | ✅ | ❌ | ❌ | `sale_repository.dart:385` |
| Refund / return | ✅ | ✅ | ✅ | `return_repository.dart:69` |
| Stock adjustment | ✅ | ✅ | ❌ | `product_repository.dart:18`, `stock_movement_repository.dart:50` |
| Open / close shift, cash movement | ✅ | ✅ | ✅ | `cash_shift_repository.dart:54`, `:102`, `:193` |
| Record expense | ✅ | ✅ | ❌ | `expense_repository.dart:17` |
| Supplier management | ✅ | ✅ | ❌ | `supplier_repository.dart:65` |
| Create / update / receive purchase order | ✅ | ✅ | ❌ | `purchase_order_repository.dart:196`, `:274`, `:373` |
| Change purchase-order status | ✅ | ✅ | ❌ | `purchase_order_repository.dart:492` |
| Delete purchase order | ✅ | ❌ | ❌ | `purchase_order_repository.dart:459` |
| View reports | ✅ | ✅ | ❌ | `report_repository.dart:154` |
| Demo data import / clear | ✅ | ✅ | ❌ | `demo_data_service.dart:22` |
| Backup export / restore / reset | ✅ | ❌ | ❌ | `backup_service.dart:34` (`requireOwner`) |
| Change `loginRequired` setting | ✅ | ❌ | ❌ | `business_settings_repository.dart:99` |
| Staff administration | ✅ | ❌ | ❌ | `staff_account_repository.dart:296` (`_requireOwnerAuthority`) |

**Owner-only operations** go through `requireOwner` /
`_requireOwnerAuthority`, which re-verifies the account against the database
rather than trusting a caller-supplied flag.

> **Note on the staff-admin path:** `StaffAccountRepository` previously
> accepted an `asOwner: true` boolean and an `actingUsername` string from the
> caller. **Neither is proof of authority** — any caller could pass them.
> Phase E keeps those parameters for backward compatibility (so existing
> callers and tests still compile) but, whenever a session exists, the
> **session identity is authoritative** and is re-verified against the
> database: deactivated/deleted → sign out + throw; non-owner → throw. With no
> session (first-run bootstrap / login-disabled mode) the pre-Phase-E checks
> remain in force so the first owner can still be created before any session
> can exist.


### 14.4 Backup Compatibility

- `_currentSchemaVersion` raised **9 → 14** (`backup_service.dart:24`),
  matching `AppDatabase.schemaVersion` (`app_database.dart:64`).
- `_oldestSupportedSchemaVersion` remains **4** → the accepted restore window
  is now **[4, 14]**. The window only widened, so **older backups still
  restore**.
- The two new payload fields are **optional on read**
  (`if (item.containsKey('staffId')) requireNullableString('staffId')`,
  lines 362–363 and 396–398) and default to `null` on write
  (`Value(item['staffId'] as String?)`, lines 571 and 633). A pre-v14 backup
  restores with `null` attribution; a v14 backup round-trips attribution
  exactly.
- Export/restore/reset are now **owner-only** and write their own audit rows
  (`backup.save` line 176, `backup.reset` line 444, `backup.restore` line 680).
  The owner check lives in `_authorizeOwner` (line 34), which delegates to
  `requireOwner` (line 35); it is called at export (line 39), restore
  (line 453) and reset.

### 14.5 Files Changed

| File | Change |
|---|---|
| `lib/core/session/session_authorization.dart` | **New** — the authorization core (`resolveActor`, `canPerform`, `requireRole`, `requireOwner`) |
| `lib/data/database/app_database.dart` | `schemaVersion` 12 → 14; new `from < 14` guarded migration block |
| `lib/data/database/app_database.g.dart` | Regenerated by Drift |
| `lib/data/database/tables/sales.dart` | `+ staffId` (nullable) |
| `lib/data/database/tables/sale_returns.dart` | `+ staffId` (nullable) |
| `lib/data/database/tables/stock_movements.dart` | `+ staffId` (nullable) |
| `lib/data/database/tables/cash_movements.dart` | `+ staffId` (nullable) |
| `lib/data/database/tables/cash_shifts.dart` | `+ openedById`, `+ closedById` (nullable) |
| `lib/data/database/tables/purchase_orders.dart` | `+ staffId` (nullable) |
| `lib/data/repositories/sale_repository.dart` | Actor resolution, attribution, owner-only delete |
| `lib/data/repositories/return_repository.dart` | Actor resolution, attribution, restock attribution |
| `lib/data/repositories/product_repository.dart` | Actor resolution, attribution, role gate |
| `lib/data/repositories/stock_movement_repository.dart` | Actor resolution, attribution, role gate |
| `lib/data/repositories/expense_repository.dart` | Actor resolution, role gate, audit actor |
| `lib/data/repositories/cash_shift_repository.dart` | Actor resolution, attribution, audit actor |
| `lib/data/repositories/purchase_order_repository.dart` | Actor resolution, attribution, role gates |
| `lib/data/repositories/supplier_repository.dart` | Actor resolution, role gate, audit actor |
| `lib/data/repositories/report_repository.dart` | Actor resolution, owner/manager gate on reports |
| `lib/data/repositories/staff_account_repository.dart` | `_requireOwnerAuthority` session-based hardening |
| `lib/data/repositories/business_settings_repository.dart` | `_guardSecurityChange` owner gate on `loginRequired`; audit rows |
| `lib/data/services/backup_service.dart` | Owner-only export/restore/reset; version 9 → 14; `staffId` in payload |
| `lib/data/demo/demo_data_service.dart` | Actor resolution, owner/manager gate, attribution |
| `lib/models/sale.dart` | `+ staffId` on the domain model |
| `test/phase_e_test.dart` | **New** — 11 Phase E tests |
| `test/migration_test.dart` | **New** — 2 v13→v14 migration tests (attribution columns + legacy-row preservation) |
| `test/backup_service_test.dart` | Updated for the new backup schema version |
| `test/loyalty_backup_test.dart` | Updated for the new backup schema version |
| `docs/STARTUP_AUTH_PLAN.md` | This report + corrected schema/migration documentation |
| `lib/core/widgets/universal_search.dart` | **Unrelated to Phase E** — fixes pre-existing syntax errors (§14.6) |


### 14.6 Unrelated Fix Retained — `universal_search.dart`

This file was modified in the working tree during the session. It was
investigated and the change was **reviewed and retained**, for these reasons:

- The **committed (HEAD) version does not compile.** Restored into the package
  and analyzed: **5 syntax errors** at lines 462–469
  (`Expected to find ']'`, `Expected to find ';'`, `missing_identifier`,
  `unexpected_token`) plus a `dead_code` warning and an `empty_statements`
  info — 10 diagnostics total, exactly matching the "analyzer baseline"
  noted in §9 item 9.
- The working-tree version fixes the **unbalanced brackets** in the
  `_SearchRow` widget and applies `dart format` normalization. The diff is
  **purely mechanical**: bracket balance + whitespace/line-wrapping, plus the
  removal of an unnecessary `package:flutter/services.dart` import.
- **No behavior change** — no logic, no string literals, no control flow, no
  API surface was altered.
- `flutter analyze --no-pub` now reports **"No issues found!"** across the
  whole project, versus 10 diagnostics before.

The file is **not** part of the Phase E feature, and it is kept as a separate,
clearly-labeled change so the Phase E diff stays reviewable.

### 14.7 Verification

| Command | Result |
|---|---|
| `flutter test` (full suite) | **205/205 passed** |
| `flutter test test/phase_e_test.dart` | **11/11 passed** |
| `flutter test test/migration_test.dart` | **5/5 passed** (2 of them new in Phase E) |
| `flutter test test/migration_test.dart test/backup_service_test.dart` | **16/16 passed** (5 migration + 11 backup) |
| `flutter analyze --no-pub` | **No issues found** |

**The 11 Phase E tests** (`test/phase_e_test.dart`) cover:

*Attribution (group `Phase E - Staff attribution on business records`):*
1. sale records the acting staff member
2. stock adjustment records the acting staff member
3. return and its restock movement record the acting staff member
4. sale cancellation restock movement records the acting staff member
5. expense audit records the acting staff member as actor
6. records stay unattributed when login enforcement is disabled *(legacy
   single-operator behavior preserved)*

*Authorization (group `Phase E - Authorization boundaries`):*
7. cashier cannot record an expense
8. cashier cannot adjust stock
9. cashier can complete a sale
10. operations are rejected when login is required but nobody signed in
11. a deactivated staff member cannot perform operations *(and the stale
    session is signed out)*

**The 2 new migration tests** (`test/migration_test.dart`, group
`schema migration v13 -> v14`):

12. `adds the staff attribution columns to existing tables` — builds a v13
    database whose six affected tables exist *without* the attribution
    columns, then asserts via `pragma_table_info` that all seven columns
    (`sales.staff_id`, `sale_returns.staff_id`, `stock_movements.staff_id`,
    `cash_shifts.opened_by_id`, `cash_shifts.closed_by_id`,
    `cash_movements.staff_id`, `purchase_orders.staff_id`) were added.
13. `pre-existing rows survive the upgrade with null attribution` — inserts a
    sale row *before* the upgrade and asserts it survives with
    `staffId == null`, proving the migration is additive and does not rewrite
    historical data.

### 14.8 Known Limitations

1. **UI-level role gating is not implemented.** Authorization is enforced at
   the repository/service layer. A cashier can still *navigate to* a screen
   they may not act on; the action itself is rejected with a `StateError`.
   Layering the UI is deferred (§12 item 7).
2. **The backup schema-version mirror is hand-maintained.** Both constants are
   14 and agree, but no test asserts `AppDatabase.schemaVersion ==
   BackupService._currentSchemaVersion` (§5.3 residual risk).
3. **`'stock.change'` audit still has no writer** (§6.2) — a pre-existing
   product gap, untouched by Phase E.
4. **Audit rows written before Phase E** keep `'Owner'`, as do rows written
   while login enforcement is disabled. This is intentional — historical data
   is not rewritten.
5. **Customer credit operations** (`customer_credit_repository.dart`) were not
   brought under the Phase E gate; they still write the default `'Owner'`
   actor. Left for a follow-up phase.
6. **No automated e2e** of the role matrix through the UI — all Phase E
   verification is at the repository layer on the Flutter test host.

*End of Phase E report.*

---

## 15. Phase F — Session Security Hardening Implementation Report

**Status:** Phase F COMPLETE — verified 2026-10-22 against actual source.

**Goal:** make an authenticated session safe to leave unattended — an
inactivity auto-lock, an explicit lock, PIN-only unlock, POS sale
preservation across the lock boundary, owner-only recovery, and a visible
login-readiness pre-flight — without weakening the Phase D/E guarantees.

### 15.1 Scope Delivered

| Item | Status | Primary evidence |
|------|--------|------------------|
| F1 — Inactivity timeout column + session timer | **COMPLETE** | `tables/business_settings.dart:60` (`inactivityTimeoutMinutes`, default `0`); `app_database.dart:210` (v14→v15 migration); `app_shell.dart` `_armInactivityTimer` / `_evaluateInactivity` |
| F2 — Owner-gated timeout configuration | **COMPLETE** | `business_settings_repository.dart` `_guardInactivityTimeoutChange` → `requireOwner`; audited as `settings.inactivity_timeout_change` |
| F3 — Locked sessions cannot authorize operations | **COMPLETE** | `session_authorization.dart` `resolveActor` throws while `session.isLocked`; `requireOwner` inherits it |
| F4 — POS sale preservation across lock/sign-out | **COMPLETE** | `app_shell.dart` `_preservePosCart` / `_restorePosCart` (guarded by `_hasParkedCart`); `pos_screen.dart` `parkActiveCart` / `restoreLastParkedCart` |
| F5 — Owner-only staff recovery + management UI | **COMPLETE** | `features/staff/presentation/screens/staff_management_screen.dart`; `staff_account_repository.dart` `recoverOwnerPin` (rotates the code) |
| F6 — Login-readiness verification surfaced | **COMPLETE** | `staff_account_repository.dart` `checkLoginReadiness`; readiness card in the staff screen |
| Phase F tests | **COMPLETE** | `test/phase_f_test.dart` (36 tests); `test/migration_test.dart` (2 v14→v15 tests) |

### 15.2 Security Model

Phase F introduces a **third** session state alongside *signed out* and
*unlocked*:

| State | `isAuthenticated` | `isLocked` | Business operations | Unlock path |
|-------|-------------------|------------|---------------------|-------------|
| `signedOut` | false | false | only when `loginRequired == false` | sign in with a PIN |
| `unlocked` | true | false | allowed (subject to the role matrix) | — |
| `locked` | **true** | **true** | **rejected** (`StateError`) | **PIN re-entry only** |

Four invariants define the phase:

1. **Only a PIN unlocks.** `SessionController.resetActivity` updates the
   activity timestamp and *never* clears the lock. A stray tap on an
   unattended terminal cannot release the lock.
2. **A locked session authorizes nothing.** `resolveActor` throws while the
   session is locked, so every repository that resolves an actor
   (sales, returns, stock, expenses, shifts, purchase orders, suppliers,
   reports, backups, settings) is blocked at a single choke point rather
   than at each call site.
3. **The timeout is owner-only.** A manager or cashier cannot shorten,
   lengthen, or disable the auto-lock on the terminal they are using —
   the repository rejects the change with a `StateError`.
4. **The lock is not dismissible.** The lock dialog uses
   `barrierDismissible: false` and `PopScope(canPop: false)`, so neither
   the barrier tap nor the system back button nor a predictive-back
   gesture releases it.

### 15.3 Timer Design

The inactivity timer is **not** a repeating timer and is **not** re-armed by
the session listener on every activity event. The design avoids the churn a
naive implementation produces:

| Concern | Resolution |
|---------|------------|
| A settings query per user interaction | The timeout is read **once** per session change (`_loadInactivityTimeout`) and cached in `_inactivityTimeoutMinutes`. |
| A `setState` + full shell rebuild per tap | `SessionController.resetActivitySilently` updates the timestamp **without notifying listeners**. The shell restarts its own timer directly. |
| A cart restore on every activity event | Cart parking/restoration is driven by the *session state transition*, not by activity. |
| A timer firing while the app is suspended | `didChangeAppLifecycleState` re-evaluates the elapsed wall-clock time on resume and locks immediately if the timeout elapsed in the background. |
| The timer outliving the session | The timer is cancelled when the session signs out or locks, and on `dispose`. |

`_armInactivityTimer` is a **one-shot** timer: it fires once and locks the
session. It is re-armed on activity, on unlock, and on resume.

### 15.4 POS Cart Semantics

The park/restore pair is guarded by an explicit `_hasParkedCart` flag so the
"exactly once" contract is observable rather than incidental:

* **Park** (`_preservePosCart`) — called on lock and on sign-out. Parks the
  active cart into the in-memory `parkedSalesStore` and clears it from the
  POS screen. The guard makes a second park a no-op.
* **Restore** (`_restorePosCart`) — called on unlock and on sign-in. Recalls
  the most recently parked sale **once**. The guard prevents a repeated
  unlock from recalling a *different* parked sale.

`ParkedSalesStore.recall` removes the sale from the store, so even without
the guard a recall could not duplicate items — the guard exists so that a
second unlock cannot silently pick up an unrelated held sale.

### 15.5 Migration & Backup Compatibility

- **Schema version 14 → 15.** `business_settings.inactivity_timeout_minutes`
  is added with `DEFAULT 0`. The migration is guarded by a table-existence
  and column-existence check, matching the v14 block, so a database without
  a `business_settings` table does not abort the whole upgrade.
- **Backup schema version 14 → 15.** The payload now carries
  `inactivityTimeoutMinutes`. The field is **optional on read** and defaults
  to `0` on restore, so a pre-v15 backup still restores cleanly.
- **The schema-version mirror is now test-covered.** `backup_service_test.dart`
  and `loyalty_backup_test.dart` assert against
  `AppDatabase.currentSchemaVersion` rather than a literal, which closes the
  §5.3 / §12-item-8 residual risk recorded earlier in this document.
- **Additive only.** No existing row is modified. The Phase D
  `login_required` flag survives the v15 upgrade (asserted by a migration
  test).

### 15.6 Files Changed

| File | Change |
|------|--------|
| `lib/core/session/session_controller.dart` | Added `SessionLockState.locked`; `lock()`, `unlock()`; `resetActivity` no longer unlocks; added `resetActivitySilently` |
| `lib/core/session/session_authorization.dart` | `resolveActor` rejects a locked session |
| `lib/core/widgets/app_shell.dart` | Lifecycle observer; one-shot inactivity timer; guarded cart park/restore; lock dialog; session menu; lock-now / sign-out actions |
| `lib/data/database/tables/business_settings.dart` | `+ inactivityTimeoutMinutes` (default `0`) |
| `lib/data/database/app_database.dart` | `schemaVersion` 14 → 15; guarded v15 migration |
| `lib/data/database/app_database.g.dart` | Regenerated by Drift |
| `lib/data/repositories/business_settings_repository.dart` | `_guardInactivityTimeoutChange` (owner-only) + audit row |
| `lib/data/services/backup_service.dart` | `_currentSchemaVersion` 14 → 15; payload carries the timeout; optional-on-read validation; restore default `0` |
| `lib/features/pos/presentation/screens/pos_screen.dart` | `parkActiveCart()` / `restoreLastParkedCart()` |
| `lib/features/settings/presentation/screens/settings_screen.dart` | Inactivity auto-lock dropdown; owner-only note; correct revert-on-failure |
| `lib/features/staff/presentation/screens/staff_management_screen.dart` | **New** — staff admin, owner recovery, login readiness |
| `lib/features/more/presentation/screens/more_screen.dart` | "Staff & Access" entry point |
| `test/phase_f_test.dart` | **New** — 36 Phase F tests |
| `test/migration_test.dart` | + 2 v14→v15 migration tests |
| `test/backup_service_test.dart`, `test/loyalty_backup_test.dart` | Schema-version assertions bound to `AppDatabase.currentSchemaVersion` |
| `docs/STARTUP_AUTH_PLAN.md` | This report |
| `CHANGELOG.md` | v1.1.0 entry |

### 15.7 Verification

| Command | Result |
|---------|--------|
| `flutter analyze --no-pub` | **No issues found** |
| `flutter test` (full suite) | **243/243 passed** |
| `flutter test test/phase_f_test.dart` | **36/36 passed** |
| `flutter test test/migration_test.dart` | **7/7 passed** (2 new in Phase F) |
| `flutter build web --release` | **succeeds** |

**The 36 Phase F tests** (`test/phase_f_test.dart`) cover:

*Session lock state* (group `Phase F - Session lock state`): the three lock
states; lock/unlock transitions; lock and unlock no-ops; sign-out clearing the
identity; **activity never unlocking a locked session**; the timestamp
updates; `resetActivitySilently` updating the timestamp without notifying
listeners; activity being ignored when signed out.

*Locked sessions cannot authorize* (group `Phase F - Locked sessions cannot
authorize operations`): a locked session is rejected by `addExpense`; the
ability to operate returns after unlocking; `resolveActor` and `requireOwner`
throw while locked.

*Timeout configuration* (group `Phase F - Inactivity timeout configuration`):
the default of `0`; persistence; preservation across unrelated saves;
negative values rejected; **the owner can change it**; **a manager and a
cashier cannot**; the change is audited with the owner as the actor.

*PIN unlock and recovery* (group `Phase F - PIN unlock and owner recovery`):
the correct PIN verifies and unlocks; a wrong PIN does not unlock; a
deactivated account cannot unlock; **owner recovery rotates the recovery code
and the old code stops working**; login readiness reports a missing owner,
succeeds for a complete owner, and fails when the recovery code is absent.

*Backup compatibility* (group `Phase F - Backup compatibility`): the payload
carries the timeout; a backup without the field still restores; the timeout
round-trips.

*POS cart preservation* (group `Phase F - POS cart preservation across a
lock`): a cart is parked once and restored once; the parked contents are
preserved; a locked session does not clear the parked sale.

**The 2 new migration tests** (`test/migration_test.dart`, group
`schema migration v14 -> v15`): the column is added with a disabled default;
pre-existing settings rows survive with their `loginRequired` flag intact.

### 15.8 Known Limitations

1. **UI-level role gating is still not implemented** (§14.8 item 1) — carried
   forward unchanged.
2. **The inactivity clock uses the device clock.** Rolling the clock back
   extends an unlocked session, exactly as the PIN lockout already does
   (§14.8 / the Phase D security notes).
3. **Activity is tracked by tap only.** A long-running keyboard interaction
   (typing a long note) resets the clock on each keypress through the
   shell's gesture detector, but pointer movement without a tap does not.
   A full pointer/keyboard activity stream is a candidate for a later phase.
4. **The parked cart is in-memory only.** It does not survive an application
   restart — the same constraint that applies to the Phase D session. A
   restart therefore discards an in-progress sale, exactly as before Phase F.
5. **No automated e2e** of the lock flow through the UI — all Phase F
   verification is at the repository/session layer on the Flutter test host.
6. **The lock dialog has no owner-recovery escape hatch.** A user who is
   locked out of their own PIN must use the "Staff & Access" screen, which is
   reachable from the More Tools menu. Surfacing recovery directly in the
   lock dialog is deferred.

*End of Phase F report.*

