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

`lib/data/database/app_database.dart` (class `AppDatabase`):

- `int get schemaVersion => 12;` (line 64) and mirror constant
  `static const int currentSchemaVersion = 12;` (line 66).
- `MigrationStrategy` (line 69):
  - `onCreate` (71–73): `m.createAll()` — a fresh install gets the full v12
    schema directly.
  - `onUpgrade` (75–156): a **sequential `if (from < N)` ladder** v2 → v12,
    each block idempotent by guard and strictly additive:
    - v2 `sales.status` (76–78) · v3 `saleItems.purchasePrice` (80–82) ·
      v4 `businessSettings` table (84–86) · v5 loyalty columns (88–98) ·
      v6 `customers.pointsBalance` + data backfill via `customStatement`
      `UPDATE customers SET points_balance = loyalty_points` (100–110) ·
      v7 returns + audit tables (112–117) · v8 shifts + cash movements
      (119–123) · v9 receipt branding columns (125–138) · v10 suppliers/POs
      (140–145) · v11 credit tables (147–151) · **v12 `staffAccounts`**
      (153–156).
  - No `beforeOpen` hook — Drift defaults apply.
- **Convention for future changes:** bump `schemaVersion` by 1, append one more
  `if (from < N)` block (additive `addColumn`/`createTable`, data backfills via
  guarded `customStatement`), regenerate `app_database.g.dart`, and add a raw
  `user_version` upgrade test.
- Existing installations upgrade **automatically on first open** (the gate's
  `SELECT 1`) — old `user_version` is below 12, Drift runs `onUpgrade` from
  that version to 12 in one transaction.

### 5.2 Migration tests (executed this session)

`test/migration_test.dart` — 3 tests in 3 groups, built on `prepareRawDb()`
that writes `user_version` with raw SQL before opening `AppDatabase`:

- group `schema migration v5 -> v6` → `backfills points_balance from existing loyalty_points` (83–84)
- group `schema migration v11 -> v12` → `creates staffAccounts table when upgrading from v11` (125–126)
- group `schema migration v5 -> v12` → `applies every migration from v5 through v12` (300–301)

Run: `flutter test test/migration_test.dart test/backup_service_test.dart`
→ **14/14 passed** (3 migration + 11 backup).

### 5.3 The known gap: DB `schemaVersion = 12` vs `BackupService._currentSchemaVersion = 9`

**Finding: same concept, one stale mirror value — not two different version
concepts.**

Evidence in `lib/data/services/backup_service.dart`:

- line 15: `static const int _currentSchemaVersion = 9;`
- line 18: `static const int _oldestSupportedSchemaVersion = 4;`
- line 38: export writes `'databaseSchemaVersion': _currentSchemaVersion`
- lines 185–197: restore validates the declared version against the accepted
  window `[4, 9]` and rejects anything outside.

`_currentSchemaVersion` is intended to mirror `AppDatabase.schemaVersion`
(it is the schema version *declared inside backup JSON*, written at export and
checked at restore). History confirms drift: `docs/PLAN_v1.4.0.md:24` records
the earlier “backups record `databaseSchemaVersion: 4` while the schema is v6”
defect; the fix raised the constant to 9 **when the schema was 9**. The schema
then advanced to v10 (suppliers/POs), v11 (credit), v12 (staff) while the
backup constant stayed at 9 — it was never re-synced.

**Why nothing breaks today (verified):**

1. Export *always writes* the constant 9, so any backup this build produces
   passes its own `[4, 9]` restore check — round trip is self-consistent.
2. Tables introduced in v10–v12 (suppliers, POs, credit, staff) are **not part
   of backup export/restore**, so restoring a “9”-labelled backup into a v12
   database copies exactly the tables it contains; migration state of the
   target DB is untouched by restore.
3. Staff are deliberately excluded from backups (see §6.4) — restore preserves
   existing staff rows (verified by tests), so login state survives restore.

**Risk carried forward:** the metadata understates the producer's real schema.
The moment any v10+ table is added to the export payload, `_currentSchemaVersion`
and the accepted window **must** be raised together (with an export/restore
test), or restore validation starts lying/rejecting. Deferred by constraint —
**neither value is changed in Phase A.**

---

## 6. A5 — Business records and attribution

### 6.1 Schema: no staff-identity columns on business records

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
9. **Analyzer baseline:** the only pre-existing diagnostics are 10 in
   `lib/core/features/search/universal_search.dart` (forbidden file — never
   touched). All other files are clean; keep it that way.
10. **Test-runner constraint:** `flutter test` is required (tests use
    `dart:ui`); plain `dart test` fails. Do not “fix” tests to pass — earlier
    fixes corrected genuinely wrong assertions (`throwsA` on enums,
    non-awaited `returnsNormally`), not desired outcomes.

---

## 10. Smallest safe implementation plan for the remaining phases

> Phase B is already implemented and verified (StartupGate + 4 tests) — no
> further B work beyond the additive initializer step in D1 if/when Phase D
> lands. Phases below are plans only; none is started.

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

1. **Real-device/web runtime behavior** of the gate (WASM worker open path) was
   not exercised here — all verification ran on the Flutter test host. Web
   build compiles (verified in earlier phases) but has no automated e2e.
2. **Drift downgrade path** (opening a DB whose `user_version` > 12) is not
   covered by tests; Drift is expected to refuse — untested, low risk.
3. **`'stock.change'` audit** has no writer (§6.2) — noted as a pre-existing
   product gap, not touched.
4. **Full role matrix** (exact manager vs cashier capabilities per screen) is
   intentionally left to Phase E; §10 proposes a conservative starting matrix.
5. **Backup schema-version sync (9→12)** and adding any new table to backup
   payloads: deferred by this phase's constraints (§5.3, §9.4).
6. Whether `loginRequired` should also gate **app resume after backgrounding**
   (mobile) vs only cold start: product decision for Phase F.

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




