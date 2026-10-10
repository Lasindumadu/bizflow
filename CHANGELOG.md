# BizFlow — Changelog

All notable changes to the BizFlow source-code template are documented in this file.

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
