# BizFlow — Changelog

All notable changes to the BizFlow source-code template are documented in this file.

---

## [1.1.0] — Startup Login, Session Security & Owner Recovery

### Added

#### Session locking (F1–F2)

* **Inactivity auto-lock.** A new `business_settings.inactivity_timeout_minutes`
  column (default `0` = disabled) sets how long a terminal may sit idle before
  the session locks. The timeout is **owner-only**: managers and cashiers are
  rejected by the repository, and every change is audited.
* **Explicit lock.** A session menu in the app header offers *Lock now*,
  *Staff & access* and *Sign out*.
* **PIN-only unlock.** A locked session requires PIN re-entry through
  `StaffAccountRepository.verifyPin` — the bcrypt-verified path, including the
  existing failed-attempt throttling and account lockout. Touching the screen
  does **not** unlock: `SessionController.resetActivity` never clears a lock.
* **Locked sessions cannot authorize operations.** `resolveActor` and
  `requireOwner` throw a `StateError` while the session is locked, so no
  repository can act on behalf of a suspended session.
* **Lifecycle-aware timeout.** The shell observes app lifecycle changes, so a
  timeout that elapses while the app is backgrounded locks the session as soon
  as the app resumes.

#### POS sale preservation (F3)

* An in-progress POS cart is **parked** when the session locks or signs out and
  is **restored exactly once** when the session unlocks or a new user signs in.
  Parking and restoring are each guarded so a cart can never be duplicated or
  silently recalled twice.

#### Staff management, recovery & readiness (F4–F5)

* **New "Staff & Access" screen** (Settings → More Tools, and the session
  menu) for listing staff, creating accounts, changing roles, activating and
  deactivating accounts, and resetting a staff PIN.
* **Owner recovery.** The owner PIN can be recovered with the one-time recovery
  code issued when the owner account was created. Recovery rotates the code and
  the new code is displayed exactly once.
* **Login readiness.** The pre-flight check (active owner + PIN + recovery
  code) is surfaced in the UI so an owner can see, before enabling startup
  login, whether the business could be locked out.

#### Login-readiness verification (F6)

* `StaffAccountRepository.checkLoginReadiness` is now surfaced in the UI and
  covered by tests; enabling startup PIN login still refuses when the owner
  account is incomplete.

### Changed

* **Schema v14 → v15.** Adds `business_settings.inactivity_timeout_minutes`
  with a `0` default. The migration is additive: no existing row is modified,
  and the Phase D `login_required` flag survives the upgrade.
* **Backup schema version 14 → 15.** The backup payload now carries the
  inactivity timeout. The field is **optional on read**, so pre-v15 backups
  still restore (with the timeout defaulting to `0`).
* **The v15 migration is guarded** by a table-existence and column-existence
  check, matching the v14 block, so a database without a `business_settings`
  table no longer aborts the whole migration.
* **Backup schema-version assertions** in the test suite now compare against
  `AppDatabase.currentSchemaVersion` instead of a hard-coded number, closing
  the §5.3 mirror-drift risk recorded in the plan.

### Fixed

* **The inactivity lock can no longer be bypassed by a stray tap.** Previously
  `resetActivity()` also unlocked a locked session.
* **Activity tracking no longer causes listener/timer churn.** Activity updates
  the timestamp without notifying listeners; the shell restarts its timer
  directly. This removes a per-interaction database query, `setState`, and
  cart-restore cycle.
* **The lock dialog no longer leaks a `FocusNode`** — a fresh `FocusNode` was
  allocated on every rebuild and never disposed. It is now a single, disposed
  node, and the PIN field takes focus when the dialog appears.
* **The lock dialog is not dismissible** by the system back button
  (`PopScope(canPop: false)`) or a predictive-back gesture.

### Verification

* `flutter analyze --no-pub` — 0 issues
* `flutter test` — **243 tests passing** (36 new Phase F tests, 2 new v15
  migration tests)
* `flutter build web --release` — succeeds

### Known limitations

* UI-level role gating is still not implemented (authorization is enforced at
  the repository/service layer) — the same limitation carried from Phase E.
* The inactivity clock uses the device clock; rolling it back extends an
  unlocked session.
* The backup schema-version mirror is now covered by tests, but the
  `_currentSchemaVersion` constant itself is still hand-maintained.

---

## [1.5.0] — Polish, Reliability & Low-Stock Alerts

### Added

* **Low-stock alerts.** Completing a sale that pushes a product's stock at or
  below its low-stock threshold now raises an in-app notification ("Low stock"
  or "Out of stock"), with the product name and remaining units. The alert
  fires exactly once, on the crossing — restocking re-arms it.
* **Sale→cancel invariant tests** proving stock is restored exactly once and
  repeated cancellation is rejected.

### Changed

* `SaleRepository` accepts an optional `onLowStock` callback so any host app
  can surface the same alerts.
* Code-quality sweep: resolved all 21 analyzer findings (unused fields,
  deprecated APIs, async context-safety guards, widget ordering) — analyze
  is now fully clean with zero issues.

### Verification

* `flutter analyze` — 0 issues
* `flutter test` — 120 tests passing
* `flutter build web --release` — succeeds

---

## [1.0.0] — Initial Release

### Added

#### Dashboard

* Business overview dashboard
* Today's sales summary
* Today's profit summary
* Product count
* Low-stock overview
* Recent sales
* Quick actions
* Dynamic greeting
* Responsive dashboard layout

#### Products

* Product CRUD
* Product name
* SKU
* Category
* Purchase price
* Selling price
* Stock quantity
* Low-stock threshold
* Barcode field
* Product search
* Category filtering
* Alphabetical sorting
* Stock status indicators
* Product deletion without removing historical sales

#### Categories

* Category creation
* Category editing
* Category deletion
* Product category assignment

#### Point of Sale

* Product search
* Product selection
* Shopping cart
* Quantity adjustment
* Cart item removal
* Subtotal calculation
* Discount support
* Customer selection
* Payment amount
* Payment methods
* Change calculation
* Stock validation
* Sale completion
* Sale reference generation
* Responsive POS layout

#### Sales

* Sales history
* Sale search
* Date filtering
* Status filtering
* Sale details
* Customer information
* Payment information
* Sale cancellation
* Sale references
* Historical sale retention after product deletion
* Sale cancellation support when a related product has been deleted
* Stock restoration for products that still exist during sale cancellation

#### Customers

* Customer CRUD
* Name
* Phone
* Email
* Address
* Outstanding balance
* Customer search
* Alphabetical sorting
* Responsive layout

#### Inventory

* Current stock overview
* Low-stock indicators
* Stock adjustments
* Stock movement history
* Stock-in operations
* Stock-out operations
* Previous stock tracking
* New stock tracking
* Movement notes
* Inventory search
* Alphabetical sorting

#### Expenses

* Expense CRUD
* Expense categories
* Expense amount
* Expense date
* Notes
* Expense history
* Expense totals
* Newest-first sorting

#### Reports

* Sales summary
* Profit summary
* Expense summary
* Business overview
* Best-selling products
* Expenses by category
* Date-based reporting
* Report refresh
* Responsive reports

#### Settings

* Business name
* Business address
* Business phone
* Business email
* Currency selection
* Light theme
* Dark theme

#### Backup & Restore

* JSON backup
* JSON restore
* Backup validation
* Product backup
* Category backup
* Sales backup
* Sale item backup
* Customer backup
* Expense backup
* Stock movement backup
* Business settings backup
* Backup restoration replacing current application data

#### Data Reset & Recovery

* Reset All Data functionality
* Complete local data reset
* Product data reset
* Category data reset
* Sales data reset
* Sale item data reset
* Customer data reset
* Expense data reset
* Stock movement data reset
* Business settings reset
* Confirmation before destructive reset
* Clean-state recovery workflow
* Ability to load demo data again after a reset

#### Data Export

* CSV export
* PDF receipt generation

#### Demo Data

* Complete sample business dataset
* Sample categories
* Sample products
* Sample customers
* Sample sales
* Sample expenses
* Sample stock movements
* Demo business settings
* Load demo data
* Clear demo data

#### Architecture

* Feature-oriented Flutter structure
* Drift local database
* SQLite WASM web database support
* Repository-based data access
* Shared theme system
* Responsive UI helpers
* Material 3 interface
* Versioned database schema and migrations

#### Web

* Flutter web support
* Production web build
* Drift SQLite WASM support
* Local persistent web database
* Production server helper
* Persistent database storage across browser refreshes

#### UX

* Loading states
* Empty states
* Error states
* Validation messages
* Confirmation dialogs
* Success feedback
* Responsive layouts
* Light/dark theme support
* Destructive-operation confirmation
* Data reset/recovery workflow

---

## Release Information

**Version:** 1.0.0

**Build:** 1

**Status:** Initial commercial release

**Technology:** Flutter / Dart

**Database:** Drift / SQLite

---

## Notes

This is the initial release of the BizFlow Flutter source-code template.

The 1.0.0 release includes the complete core POS, inventory, customer, expense, reporting, backup, export, demo-data, and local data management workflows.

The application supports product deletion while retaining historical sales records. Sale cancellation handles cases where a product associated with a historical sale has subsequently been deleted.

A **Reset All Data** function is included for situations where the local application needs to be returned to a clean state. Users should create a backup before performing destructive data operations when the existing data may be needed later.

Future versions may introduce additional features, improvements, platform-specific enhancements, and bug fixes.


# BizFlow — Changelog

All notable changes to the BizFlow source-code template are documented in this file.

---

## [Unreleased]

### Added

#### Point of Sale — Barcode Scanning

* Barcode submission through the existing POS search field.
* Support for USB and Bluetooth barcode scanners that operate as keyboard input devices.
* Exact barcode matching against stored product barcodes.
* Automatic addition of the matching product to the shopping cart when a barcode is submitted.
* Automatic quantity increment when the same product is scanned repeatedly.
* Integration with existing stock validation to prevent adding unavailable quantities.
* Feedback when a submitted barcode does not match any product.
* Feedback when multiple products share the same barcode.
* Automatic clearing of the search field after a successful barcode addition.
* Support for numeric and alphanumeric barcode values, including leading zeros.

#### Products and Inventory — Barcode Workflow

* Duplicate barcode validation when creating products.
* Duplicate barcode validation when editing products.
* Allowing products to retain their own barcode during edits.
* Barcode search in the Inventory screen.
* Inline form validation feedback when a barcode is already assigned to another product.
* Repository-level validation to prevent duplicate barcode assignments through product creation and updates.


#### Testing

* Added automated product repository tests for barcode persistence.
* Added a test verifying that barcode values retain leading zeros.
* Added a test verifying that product barcode updates are persisted.
* Verified barcode submission behavior manually in the Flutter web application.

### Validation

* `flutter analyze` completed with no issues.
* All 14 automated tests passed.
* Manually verified barcode validation when creating and editing products.
* Manually verified that products can retain their existing barcode during edits.
* Manually verified saving a unique barcode and searching for a product by barcode in Inventory.
* Barcode workflow changes committed as `0416f7b`.
* Changes pushed to `feature/bizflow-1.1.0-foundation`.


---

## [1.0.0] — Initial Release

### Release Information

* **Version:** 1.0.0
* **Build:** 1
* **Status:** Initial commercial release
* **Technology:** Flutter / Dart
* **Database:** Drift / SQLite

The 1.0.0 release includes the core POS, inventory, customer, expense, reporting, backup, export, demo-data, and local data management workflows described below.

### Notes

The application supports product deletion while retaining historical sales records. Sale cancellation handles cases where a product associated with a historical sale has subsequently been deleted.

A **Reset All Data** function is included for situations where the local application needs to be returned to a clean state. Users should create a backup before performing destructive data operations when the existing data may be needed later.

Future versions may introduce additional features, improvements, platform-specific enhancements, and bug fixes.

---

## [1.2.0] — Modernization & Growth Features

### Added

#### Loyalty Programme

* Customer loyalty points earned automatically on every completed sale.
* Four tiers — Bronze, Silver, Gold and Platinum — derived from lifetime points.
* Tier multipliers (1.0×, 1.25×, 1.5×, 2.0×) applied to points earned.
* Configurable earn rate (points per currency unit) and redeem value.
* Animated tier-progress preview shown at checkout for the selected customer.
* Settings section to enable/disable loyalty and tune the rates.
* `LoyaltyService` (pure tier/points logic) and `LoyaltyRepository`.

#### Notification Center

* In-app notification feed for sales, stock, customer and system events.
* Live unread badge in the desktop sidebar and a floating bell on mobile.
* Swipe-to-dismiss, mark-all-read and welcome notifications on first run.
* Bounded 50-item feed with relative timestamps.

#### Advanced Reports

* Payment-method revenue breakdown with share bars and per-method sale counts.
* Top-customer insights (total spent, order count) leaderboard.

#### Modern UI Component Library (`modern_widgets.dart`)

* `GradientButton`, `SoftButton`, `GlassCard`, `HoverLiftCard`.
* `AnimatedCounter`, `ShimmerBox`, `SkeletonList`.
* `AppEmptyState`, `AppErrorState`, `AppLoadingState`.
* `StatusBadge`, `TrendPill`, `ProgressRing`, `IconTile`, `FilterPill`.
* `ModernSectionHeader`, `AuroraBlob`.

#### Premium Widgets

* `GradientPageHeader`, `PremiumKpiTile`, `PremiumListTile`.

### Changed

* **Design system** — expanded color palette (extended accents, chart gradient
  pairs, glass tokens, semantic soft containers) and refined typography with
  tabular-figure numeric/mono styles (`numericLarge/Medium/Small`, `priceHero`,
  `kpiLabel`, `badge`, `helper`).
* **Decor helpers** — added `subtleShadow`, `layeredShadow`, `glow`, `ring`,
  `surface`, teal/sky/pink/lime/orange gradients and `toneGradient(seed)`.
* **Dashboard** — gradient KPI cards with trend pills, tappable stats and a
  responsive quick-actions grid (POS, Products, Customers, Reports).
* **POS checkout** — the customer selector now surfaces loyalty points and a
  loyalty progress preview.
* **Shell navigation** — notification bell integrated into the desktop sidebar
  and a floating bell on mobile.

### Database

* Schema upgraded to **v5** with a safe migration adding
  `customers.loyalty_points`, `customers.loyalty_tier` and the
  `business_settings.loyalty_*` columns.

### Testing

* Added `test/loyalty_service_test.dart` — tier assignment, progress and point
  calculations (8 tests).
* `flutter analyze` completed with no issues.
* Full suite: **31 automated tests passing**.

### Release Information

* **Version:** 1.2.0
* **Build:** 2
* **Technology:** Flutter / Dart
* **Database:** Drift / SQLite

---

## [1.3.0] — Business Correctness & Value

### Fixed

#### Loyalty lifetime vs redeemable balance (business-correctness defect)
* **Before:** `customers.loyalty_points` was used for BOTH tier calculation and
  the spendable balance. Redeeming points would have lowered the value that
  determines the tier, incorrectly demoting customers.
* **Now:** points are split into:
  * `loyalty_points` — lifetime points earned (monotonic) → **sole** input to
    the tier.
  * `points_balance` — spendable/redeemable balance → reduced on redemption.
* Schema upgraded to **v6** with a safe migration that backfills
  `points_balance = loyalty_points` for existing customers.
* New `LoyaltyRepository.earnPoints`, `redeemPoints` and `adjustPoints`
  preserve tier on redemption. Covered by 9 regression tests.

### Added

#### Loyalty redemption at checkout
* Redeem a customer's points against a sale via a themed slider control with
  quick "None" / "Max" presets.
* Redemption is capped at both the spendable balance and the amount still owed
  after any manual discount.
* Loyalty (points) discount and manual discount are shown separately in the
  checkout summary; the sale records the combined discount.

#### Inventory intelligence
* `InventoryIntelligenceRepository` — computed from existing tables, no schema
  change:
  * **Reorder suggestions** ranked by urgency (out-of-stock first, then fewest
    days of cover) with a suggested reorder quantity.
  * **Dead stock** — stocked products with no sales in 60 days, sorted by
    capital tied up.
  * **Stock valuation** — cost value, retail value, potential profit, units.
* New **Inventory Intelligence** screen (reached from More) using the modern
  component library. Covered by 8 tests.

#### Advanced analytics
* **Period comparison** (7 / 30 / 90 days) with revenue change vs the previous
  equal-length period.
* **Profit & margin by category** and **profit by product** with margin
  percentages.
* Covered by 4 tests.

#### Notification tests
* Added 8 tests covering unread counts, mark-read, mark-all-read, removal,
  the 50-item bound and listener notifications.

### Changed

#### Responsive navigation (tablet & web)
* The shell now has three layouts:
  * **Phone (<600px):** bottom navigation bar (5 core destinations).
  * **Tablet (600–1024px):** expanded `NavigationRail` exposing **all nine**
    destinations, making use of the extra space.
  * **Desktop (>1024px):** full gradient sidebar with grouped destinations.
* Reuses the existing `modern_widgets.dart` / `premium_ui.dart` — no new
  component library.

#### Dark-mode correctness
* Report chart progress bars now use theme-aware backgrounds instead of a fixed
  light border colour, so they render correctly in dark mode.

### Database
* Schema **v6** — adds `customers.points_balance`; migration backfills existing
  rows.

### Verification
* `flutter analyze` — **no issues**.
* `flutter test` — **60 tests passing** (loyalty service 8, loyalty repository
  9, notifications 8, inventory intelligence 8, report analytics 4, sale
  cancellation 7, plus product/barcode/theme).
* `flutter build web --release` — **production web build succeeds**
  (`build/web/main.dart.js`).

### Release Information
* **Version:** 1.3.0
* **Build:** 3
* **Technology:** Flutter / Dart
* **Database:** Drift / SQLite
---

## [1.4.0] — Release-Readiness & Deferred Features

This release completes the previously deferred high-value features **and**
fixes real data-integrity defects found while auditing for release.

### Fixed

* **Backup restore dropped customer tier.** Restore wrote loyalty points and
  balance but not the cached tier, so a Gold customer came back as Bronze.
  The tier is now restored (or derived from lifetime points when absent).
* **Backup schema version was hard-coded to 4** while the schema had moved on,
  so valid backups could be rejected. Backups now record the real schema
  version and the validator accepts a supported range (v4+).
* **Loyalty programme settings were not backed up**, so restoring silently
  reset the earn rate, redeem value and enabled flag. They are now included,
  with safe defaults for older backups.
* Removed a stray development file (`lib/main.dart.backup`) and JVM crash logs
  from the source tree.

### Added

#### Sales returns & refunds (end-to-end)
* New `sale_returns` and `sale_return_items` tables.
* `ReturnRepository` — validates quantities against the original sale *and*
  prior returns, refunds money, optionally restocks (`RETURN` stock movement),
  and never mutates the original sale.
* Returns UI (More → Returns & Refunds) with per-line steppers, refund method,
  restock toggle and reason.
* Refunds feed reporting (`totalRefunded`) and the audit trail.
* 11 tests.

#### Cashier shifts & cash reconciliation
* New `cash_shifts` and `cash_movements` tables.
* `CashShiftRepository` — opening float, cash-in/out, and closing count with
  expected-cash derived from real cash sales and cash refunds.
* Shift UI with live reconciliation and discrepancy capture.
* 10 tests.

#### Audit log (Activity Log)
* New `audit_logs` table + `AuditRepository` (best-effort; never blocks a
  business action).
* Written by sale cancellation, refunds and shift open/close/movements.
* Read-only Activity Log screen.

#### Inventory intelligence
* `InventoryIntelligenceRepository` — reorder suggestions (urgency-ranked),
  dead stock, and stock valuation (cost/retail/potential profit).
* Inventory Intelligence screen. 8 tests.

#### Product CSV import
* `ProductCsvImporter` — tolerant headers, column-order independence,
  validation, duplicate detection (in-file and against existing products),
  and an import preview.
* Import screen with ready/error/duplicate badges and per-row problems.
* 11 tests.

#### Receipt branding
* Configurable receipt header, footer, note, and phone/address visibility in
  Settings, persisted and included in backups.

#### Release-readiness tests
* **Migration tests** proving a populated v5 database upgrades through to the
  latest schema with lifetime points preserved and balances backfilled.
* **Backup round-trip tests** proving loyalty values and settings survive.
* **Checkout edge-case tests** — combined discount + loyalty, negative-total
  clamping, rounding, insufficient points, and the "enough points but owes
  less" case.
* **Notification tests** — duplicates, read state, and dismissal safety.

### Changed

* Database schema → **v9** (returns, audit log, cash shifts, receipt branding),
  with safe migrations from every earlier version.
* Documentation: README now covers where data is stored, loyalty, returns,
  inventory intelligence, shifts, the audit trail and CSV import.

### Verification

* `flutter analyze` — **no issues**.
* `flutter test` — **115 tests passing**.
* `flutter build web --release` — production build succeeds.

### Release Information
* **Version:** 1.4.0
* **Build:** 4
* **Database:** Drift / SQLite (schema v9)