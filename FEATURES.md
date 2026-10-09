# BizFlow — Feature Specification

## Product Overview

**BizFlow** is an offline-first Flutter POS and inventory management application designed for small businesses.

It provides a local workflow for managing products, inventory, point-of-sale transactions, customers, expenses, reports, business settings, backups, receipts, and local data recovery and reset operations.

The POS supports barcode entry through compatible keyboard-emulating barcode scanners, alongside manual product search.

---

# 1. Dashboard

The dashboard provides a quick overview of the business.

### Included

* Today's sales
* Today's profit
* Total products
* Low-stock products
* Recent sales
* Business summary
* Quick navigation to common operations
* Responsive dashboard layout
* Dynamic greeting
* Currency-aware financial values

---

# 2. Product Management

Products can be managed directly from the application.

### Product Information

* Product name
* SKU
* Category
* Purchase price
* Selling price
* Stock quantity
* Low-stock threshold
* Barcode

### Product Operations

* Add product
* Edit product
* Delete product
* Search products
* Filter by category
* Sort alphabetically
* View stock status
* Detect low-stock products

Deleting a product does not delete historical sales or sale-item records associated with that product.

Product barcodes are stored as strings, allowing numeric or alphanumeric barcode values and preservation of leading zeros.

---

# 3. Category Management

Products can be organized into categories.

### Included

* Create categories
* Edit categories
* Delete categories
* Assign products to categories
* Category filtering

---

# 4. Point of Sale

The POS module provides the main sales workflow.

### Included

* Product search
* Product selection
* Barcode entry and scanning workflow
* Exact barcode matching against stored product barcodes
* Automatic addition of a matching product to the cart
* Repeated scans to increase cart quantity, subject to stock availability
* Feedback for unknown or ambiguous barcode matches
* Cart management
* Quantity adjustment
* Remove cart items
* Automatic subtotal calculation
* Discount calculation
* Customer selection
* Payment amount
* Payment method
* Change calculation
* Stock availability validation
* Sale completion
* Sale reference generation

### Barcode Scanning

The POS search field supports barcode submission. A compatible USB or Bluetooth barcode scanner that operates as a keyboard and submits the scanned value with Enter can be used.

The workflow is designed to:

* Match the submitted barcode against product barcode values.
* Add the matching product to the cart.
* Increase the quantity when the same product is scanned repeatedly, provided sufficient stock is available.
* Display feedback when no matching product is found.
* Handle ambiguous matches with feedback rather than silently choosing a product.
* Preserve existing cart and stock-validation behavior.
* Clear the search field after a successful barcode addition.

Barcode matching uses the stored barcode value. Numeric barcode values should be entered and stored as strings to preserve leading zeros.

**Testing note:** The workflow has been manually tested in Flutter Web using typed barcode values followed by Enter. Compatibility with a physical barcode scanner should be verified using the intended hardware before deployment.

### Responsive POS

The POS interface adapts to different screen sizes so the application can be used on desktop, tablet, and mobile-sized layouts.

---

# 5. Sales Management

Completed sales can be reviewed and managed.

### Included

* Sales history
* Sale search
* Date filtering
* Status filtering
* Sale details
* Customer information
* Payment information
* Sale cancellation
* Sale reference numbers
* Sale item details

### Historical Sales

Historical sales are retained independently of the current product catalog.

If a product is deleted after a sale has been completed:

* The historical sale remains available.
* The associated sale-item information remains available.
* The deleted product does not need to be recreated for the historical sale to remain accessible.
* The sale can still be cancelled.

When a sale containing a deleted product is cancelled:

* The sale is marked as cancelled.
* Stock is restored for products that still exist.
* No stock is restored for products that have already been deleted.

This allows product cleanup without removing historical transaction records.

---

# 6. Customer Management

Customer information can be maintained locally.

### Customer Information

* Name
* Phone
* Email
* Address
* Outstanding balance

### Included

* Add customers
* Edit customers
* Delete customers
* Search customers
* Alphabetical sorting
* Customer balance tracking
* Responsive customer interface

---

# 7. Inventory Management

Inventory provides visibility into current stock and stock changes.

### Included

* Current stock quantities
* Low-stock detection
* Stock adjustments
* Stock-in operations
* Stock-out operations
* Stock movement history
* Previous stock quantity
* New stock quantity
* Movement notes
* Movement timestamps
* Inventory search
* Alphabetical sorting

---

# 8. Expense Management

Business expenses can be recorded and managed.

### Included

* Add expenses
* Edit expenses
* Delete expenses
* Expense categories
* Expense amounts
* Expense dates
* Optional notes
* Expense history
* Expense totals
* Newest-first sorting

---

# 9. Reports

The reporting section provides business summaries based on locally stored data.

### Included

* Sales summary
* Profit summary
* Expense summary
* Business overview
* Best-selling products
* Expenses by category
* Date-based reporting
* Refreshable report data
* Responsive report layout

---

# 10. Business Settings

Business information can be customized from Settings.

### Included

* Business name
* Business address
* Business phone
* Business email
* Currency
* Theme selection

---

# 11. Currency Support

The application includes configurable currency settings.

The selected currency is reflected in supported financial interfaces throughout the application.

This allows the template to be adapted for different markets.

---

# 12. Dark Mode

BizFlow includes both:

* Light theme
* Dark theme

The theme can be changed from the application Settings.

---

# 13. Backup & Restore

The application provides local data backup and restoration.

### Backup

A complete JSON backup can contain:

* Products
* Categories
* Sales
* Sale items
* Customers
* Expenses
* Stock movements
* Business settings

### Restore

A valid BizFlow backup can be restored from a JSON file.

Restoring a backup replaces the current application data with the data contained in the selected backup.

Backup validation checks:

* JSON validity
* Application identity
* Backup format version
* Database schema version
* Required data sections

Create a backup before restoring another dataset or performing a destructive data operation.

---

# 14. CSV Export

Supported business information can be exported as CSV files.

CSV files can be opened using common spreadsheet applications.

Examples include:

* Microsoft Excel
* LibreOffice Calc
* Google Sheets

---

# 15. PDF Receipts

Completed sales can be represented as PDF receipts.

Receipt information can include:

* Business details
* Sale reference
* Date
* Customer
* Products
* Quantities
* Unit prices
* Discounts
* Total
* Payment information

---

# 16. Demo Data

The project includes a demonstration dataset.

### Demo Business

**BizFlow Demo Store**

### Demo Data Includes

* 6 product categories
* 10 products
* 4 customers
* 8 sales
* Sale items
* 8 expense records
* Stock movement records
* Customer outstanding balances
* Business settings

The demo data is designed to populate the application with sample information for demonstrations and screenshots.

### Demo Data Controls

The Settings screen provides:

* **Load Demo Data** — populates the application with the included demonstration dataset.
* **Clear Demo Data** — removes the sample records while preserving non-demo data.
* **Reset All Data** — completely clears the local application database.

Loading the demo dataset applies the included demo business settings.

---

# 17. Data Validation

The application validates common user inputs.

### Examples

* Required fields
* Numeric values
* Product stock quantities
* Prices
* Customer information
* Expense information
* Backup files

---

# 18. User Feedback

The interface provides feedback for important operations.

### Included

* Loading states
* Empty states
* Error states
* Success messages
* Validation messages
* Confirmation dialogs
* Operation progress indicators

Destructive operations such as restoring a backup and resetting all data require confirmation.

The POS barcode workflow also provides feedback for unknown or ambiguous barcode matches and respects existing stock validation.

---

# 19. Responsive Design

BizFlow supports multiple screen sizes.

### Target Layouts

* Desktop
* Tablet
* Mobile

The navigation system adapts according to the available screen size.

The customized application should be tested on the actual screen sizes and platforms targeted for release.

---

# 20. Local Database

The application uses **Drift** for local database management.

### Database Tables

* Products
* Categories
* Sales
* Sale items
* Customers
* Expenses
* Stock movements
* Business settings

The database uses schema versioning and migration support.

Product barcode values are stored with product information. The barcode-scanning workflow does not require a separate barcode database table.

---

# 21. Offline-First Architecture

The core application is designed around local data storage.

### Core Characteristics

* No custom backend required for core functionality
* No cloud database required for core functionality
* Local database
* Local business data
* Local backup and restore
* Local data reset
* Suitable for offline workflows

Cloud synchronization or authentication can be added by developers as a future customization.

---

# 22. Technology

| Technology     | Purpose               |
| -------------- | --------------------- |
| Flutter        | Application framework |
| Dart           | Programming language  |
| Material 3     | UI system             |
| Drift          | Local database layer  |
| SQLite         | Local database        |
| SQLite WASM    | Web database support  |
| PDF generation | Receipt generation    |
| CSV            | Data export           |

Barcode input uses the existing POS text-field workflow and does not require a separate barcode-scanning package for compatible keyboard-emulating scanners.

---

# 23. Architecture

The application uses a feature-oriented structure separating major responsibilities.

```text
lib/
├── core/
│   ├── theme/
│   ├── utils/
│   └── widgets/
│
├── data/
│   ├── database/
│   ├── demo/
│   └── repositories/
│
├── features/
│   ├── dashboard/
│   ├── products/
│   ├── pos/
│   ├── sales/
│   ├── customers/
│   ├── inventory/
│   ├── expenses/
│   ├── reports/
│   └── settings/
│
├── models/
└── main.dart
```

This is a high-level overview of the project structure. The actual source tree may contain additional files, subdirectories, repositories, services, and presentation components.

This structure makes individual features easier to locate and customize.

---

# 24. Customization Areas

Developers can customize:

* Branding
* Application name
* Colors
* Typography
* Business fields
* Product fields
* Categories
* Payment methods
* Currency
* Dashboard
* Reports
* Receipt design
* Navigation
* Database structure
* Business rules
* Barcode input behavior
* Product barcode validation
* POS workflow

Changes to database fields or business rules should be accompanied by appropriate migration and regression testing where necessary.

---

# 25. Platform

The current project includes Flutter Web support.

The same Flutter source architecture can be extended to supported Flutter platforms.

Before deployment to a specific platform, developers should test the customized application on that target platform.

Hardware compatibility, including physical barcode scanners, should be verified on the target device.

---

# 26. Intended Users

BizFlow is designed as a starting point for applications serving:

* Small retail shops
* Mini supermarkets
* Kiosks
* Convenience stores
* Home businesses
* Small retailers
* Independent sellers
* Micro-businesses

---

# 27. Product Positioning

**Short description:**

> Offline-first Flutter POS & Inventory Template designed for small businesses, with no server required for core functionality.

**Primary value:**

A ready-made Flutter foundation for developers who need a professional POS and inventory application that can be customized for different small-business use cases.

---

# 28. Included Source Code

The source package includes the Flutter application source code and project configuration required to open, customize, and build the application.

The exact contents of a marketplace package should be checked against the final release package before publishing.

---

# 29. Recommended Buyer Workflow

```text
Install Flutter
      ↓
Open BizFlow
      ↓
flutter pub get
      ↓
Run application
      ↓
Load demo data
      ↓
Explore features
      ↓
Customize branding
      ↓
Customize business requirements
      ↓
Test
      ↓
Build release
      ↓
Deploy
```

For important business data, create a backup before performing destructive operations.

If a clean local state is required:

```text
Create Backup
      ↓
Reset All Data
      ↓
Start Fresh
      ↓
Load Demo Data if required
```

For barcode scanning, configure products with barcode values and test the workflow using typed values before connecting a compatible physical scanner.

---

# 30. Quality Checklist

Before releasing a customized version:

* [ ] Run `flutter pub get`
* [ ] Run `flutter analyze`
* [ ] Test product management
* [ ] Test product deletion
* [ ] Verify historical sales remain after product deletion
* [ ] Test sale cancellation
* [ ] Test sale cancellation after deleting a related product
* [ ] Test categories
* [ ] Test POS
* [ ] Test barcode entry using a typed value followed by Enter
* [ ] Test a known barcode
* [ ] Test an unknown barcode
* [ ] Test ambiguous barcode matches where applicable
* [ ] Test repeated scans and cart quantity increments
* [ ] Verify stock validation when scanning products
* [ ] Verify barcodes with leading zeros
* [ ] Test a physical barcode scanner on the target hardware, if required
* [ ] Test checkout
* [ ] Test sales
* [ ] Test customers
* [ ] Test inventory
* [ ] Test expenses
* [ ] Test reports
* [ ] Test settings
* [ ] Test backup
* [ ] Test restore
* [ ] Test CSV export
* [ ] Test PDF receipt
* [ ] Test Reset All Data
* [ ] Verify data remains reset after restarting or refreshing the application
* [ ] Test loading demo data after a reset
* [ ] Test light mode
* [ ] Test dark mode
* [ ] Test responsive layouts
* [ ] Test demo data
* [ ] Run `flutter test`
* [ ] Test the target platform
* [ ] Create a release build

---

# BizFlow

**Offline-first Flutter POS & Inventory Template**

Flutter source code for building customizable small-business POS and inventory applications.
