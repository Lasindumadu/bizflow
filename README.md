# BizFlow — Offline Small Business POS & Inventory Flutter App

A professional, offline-first Flutter POS and inventory management template designed for small businesses, shops, kiosks, mini supermarkets, home businesses, and small retailers.

BizFlow provides the essential tools needed to manage products, inventory, sales, customers, expenses, reports, and business settings without requiring a backend server for its core functionality.

The application uses a local Drift/SQLite database and includes support for Flutter Web, with additional platform builds requiring the appropriate Flutter development toolchains and testing.

---

# Features

### Dashboard

* Business overview at a glance
* Today's sales
* Today's profit
* Total products
* Low-stock products
* Recent sales
* Quick access to common operations
* Responsive dashboard layout

### Product Management

* Add, edit, and delete products
* Product SKU
* Product categories
* Purchase price
* Selling price
* Current stock quantity
* Low-stock threshold
* Barcode field
* Category filtering
* Alphabetical sorting
* Stock status indicators
* Products can be deleted without removing historical sales records

### Point of Sale (POS)

* Product search
* Add products to cart
* Adjust quantities
* Remove products from cart
* Automatic subtotal calculation
* Discount support
* Payment amount
* Multiple payment methods
* Change calculation
* Customer selection
* Responsive POS interface
* Stock validation before checkout
* Barcode submission through the existing POS search field
* Exact matching against stored product barcodes
* Repeated barcode submissions increase cart quantity when stock allows
* Feedback for unknown or ambiguous barcode matches
* Barcode values stored as strings, supporting leading zeros

#### Barcode Scanning Compatibility

The POS barcode workflow is designed to support compatible USB and Bluetooth barcode scanners that operate as keyboard input devices and submit the scanned value with Enter.

A physical scanner is not required to test the basic workflow. In Flutter Web, a barcode can be typed into the POS search field and submitted with Enter.

**Testing note:** The workflow has been manually tested in Flutter Web using typed barcode values followed by Enter. Physical scanner compatibility should be verified using the actual scanner and target device before deployment.

### Sales Management

* View completed sales
* Search sales
* Filter by date
* Filter by status
* View sale details
* Sale cancellation
* Sale reference numbers
* Customer information
* Payment information
* Historical sales are retained when a related product is deleted
* Sale cancellation safely handles products that have already been deleted

### Customer Management

* Add, edit, and delete customers
* Customer phone
* Customer email
* Customer address
* Outstanding balance
* Customer search
* Alphabetical sorting
* Responsive customer interface

### Inventory Management

* Current stock overview
* Low-stock indicators
* Stock adjustments
* Stock movement history
* Stock-in and stock-out tracking
* Previous and new stock quantities
* Inventory search
* Alphabetical sorting

### Expense Management

* Add, edit, and delete expenses
* Expense categories
* Expense amount
* Expense date
* Optional notes
* Expense history
* Automatic expense totals
* Newest-first sorting

### Reports

* Sales summary
* Profit information
* Expense summary
* Business overview
* Best-selling products
* Expenses by category
* Date-based reporting
* Responsive report layouts

### Business Settings

* Business name
* Business address
* Business phone
* Business email
* Currency selection
* Light and dark themes

### Backup & Restore

* Export application data to JSON
* Restore data from a BizFlow backup
* Includes products
* Includes categories
* Includes sales
* Includes sale items
* Includes customers
* Includes expenses
* Includes stock movements
* Includes business settings
* Backup validation before restoration
* Restore replaces the current application data with the data contained in the selected backup

### Data Reset & Recovery

BizFlow includes a protected **Reset All Data** option for situations where the application needs to be returned to a clean state.

The reset operation removes:

* Products
* Categories
* Sales
* Sale items
* Customers
* Expenses
* Stock movements
* Business settings

Reset All Data is a destructive operation and cannot be undone through the application.

For important business data, create a backup before resetting.

After a reset, the application can be populated again with new business data or the included demo dataset.

### CSV Export

Export supported business information for use in spreadsheet applications and further analysis.

CSV files can be opened using Microsoft Excel, LibreOffice Calc, Google Sheets, and other compatible applications.

### PDF Receipts

Generate PDF receipts for completed sales.

Receipt information can include:

* Business details
* Sale reference
* Date and time
* Customer information
* Purchased products
* Quantities
* Unit prices
* Discounts
* Total
* Payment information

### Demo Data

A sample business dataset is included for demonstration and testing.

The demo dataset includes:

* Sample business information
* 6 product categories
* 10 products
* 4 customers
* 8 sales
* Sale items
* 8 expense records
* Stock movements
* Customer outstanding balances
* Business settings

Use **Load Demo Data** in Settings when you want to populate the application with sample information.

Use **Clear Demo Data** to remove sample records while preserving non-demo data, according to the application's demo-data behavior.

Use **Reset All Data** when you need to completely clear the local application database.

Loading the demo dataset applies the included demo business settings. Review those settings before using the application for real business operations.

### Responsive UI

The application is designed to adapt to:

* Desktop
* Tablet
* Mobile-sized layouts

Navigation and content layouts adapt to available screen space. Verify the customized application on the target screen sizes and platforms.

### Offline-First

BizFlow uses a local database and does not require a server or cloud backend for its core functionality.

Application data is stored locally on the device or browser.

Cloud synchronization, authentication, and server-based features can be added by developers as future customizations.

---

# Technology Stack

* **Flutter** — application framework
* **Dart** — programming language
* **Material 3** — user interface system
* **Drift** — local database layer
* **SQLite** — local database
* **SQLite WASM** — Web database support
* **Local persistent storage** — application data persistence
* **PDF generation** — receipt generation
* **CSV export** — spreadsheet-compatible data export
* **Responsive Flutter UI** — adaptive layouts

The barcode workflow uses the existing POS text-field input flow and does not require a separate scanning package for compatible keyboard-emulating scanners.

---

# Requirements

## Development

Recommended environment:

* Flutter 3.47.4 stable or a compatible Flutter version
* Dart 3.13.3 or a compatible Dart version
* Visual Studio Code or Android Studio
* Flutter and Dart extensions or plugins
* Git (optional)
* A supported Flutter development device or browser

Use versions compatible with the project's dependency constraints.

## Web development

* Google Chrome or another supported browser
* A compatible Flutter Web development environment

## Android development

* Android Studio or another suitable Android development environment
* Android SDK
* Android SDK command-line tools
* Compatible Java/JDK toolchain
* Android emulator or physical Android device

## iOS development

* macOS
* Xcode
* Flutter SDK
* CocoaPods where required
* Apple Developer account for relevant signing and distribution workflows

iOS builds and App Store distribution require macOS and Xcode.

---

# Installation

## 1. Extract the project

Extract the purchased project to a location of your choice.

Example:

```text
C:\Projects\bizflow
```

## 2. Open the project

Open the Flutter project directory in Visual Studio Code or Android Studio.

The project root is the directory containing `pubspec.yaml`.

If the marketplace archive includes a `source_code` directory, open that directory or the relevant nested Flutter project directory.

## 3. Install dependencies

Open a terminal in the project root and run:

```bash
flutter pub get
```

Wait for dependency resolution to complete successfully.

## 4. Check the Flutter environment

Run:

```bash
flutter doctor
```

Resolve the toolchain issues relevant to your intended platform.

## 5. Run the application

For Chrome:

```bash
flutter run -d chrome
```

For an available Android device:

```bash
flutter devices
flutter run
```

To select a particular device:

```bash
flutter run -d <device-id>
```

Replace `<device-id>` with a real device ID returned by Flutter.

---

# Building the Web Version

Run:

```bash
flutter build web --release
```

The production files will be generated in:

```text
build/web/
```

The generated `build/web` directory can be deployed to a compatible Web server.

Before publishing:

* Update the Web title and icons if required.
* Verify the hosting configuration.
* Test the production build.
* Verify that application data persists after refreshing or reopening the application.
* Confirm that the production server provides the resources and headers required by the project's Web database configuration.

A successful local build does not, by itself, verify that the deployed application will work correctly on every hosting provider.

---

# Project Structure

The project follows a feature-oriented structure designed to keep the application maintainable and easy to customize.

```text
lib/
├── core/
│   ├── theme/
│   ├── utils/
│   └── widgets/
│
├── data/
│   ├── database/
│   │   ├── tables/
│   │   ├── app_database.dart
│   │   └── database_provider.dart
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
│
└── main.dart
```

This is a high-level overview. The actual source tree may contain additional files, services, repositories, subdirectories, and presentation components.

---

# Local Database

BizFlow uses Drift for local database access.

The database contains information for:

* Products
* Categories
* Sales
* Sale items
* Customers
* Expenses
* Stock movements
* Business settings

The database schema is versioned to support migrations.

Product barcode values are stored with product information. The barcode-scanning workflow does not require a separate barcode database table.

---

# Product Deletion & Historical Sales

Products can be deleted when they are no longer needed.

Deleting a product does **not** remove historical sales or sale-item records associated with that product. This allows completed sales to remain available for reporting and historical reference.

If a historical sale contains a product that has subsequently been deleted, the sale remains accessible.

When such a sale is cancelled:

* The historical sale is marked as cancelled.
* Existing products included in the sale can have their stock restored.
* A product that has already been deleted cannot have stock restored because its product record no longer exists.

This keeps historical sales data independent of the current product catalog.

---

# Customization

The source code is structured so developers can customize the application according to their requirements.

Common customization areas include:

* Application name
* Application branding
* Colors
* Typography
* Business fields
* Product fields
* Categories
* Payment methods
* Currency
* Reports
* Receipt layout
* Navigation
* Dashboard cards
* Database tables
* Business logic
* Barcode input behavior
* POS workflow

For detailed branding and customization instructions, refer to `CUSTOMIZATION.md` or the equivalent documentation file included in the source package.

Back up important data before making changes to the database schema or business logic.

---

# Demo Data

BizFlow includes sample data to make it easier to demonstrate the application after installation.

The sample business is:

**BizFlow Demo Store**

The demo dataset contains products, customers, sales, expenses, inventory movements, and other related records.

Use **Load Demo Data** in Settings when you want to populate the application with sample information.

Use **Clear Demo Data** when you want to remove the sample records.

Use **Reset All Data** when you need to completely clear the local application database and start again from an empty state.

> Always create a backup before experimenting with important business data.

> Loading the demo dataset applies the included demo business settings. Review the settings before using the application with real business data.

---

# Backup & Restore

BizFlow provides a JSON backup system for the local database.

A backup contains:

* Products
* Categories
* Sales
* Sale items
* Customers
* Expenses
* Stock movements
* Business settings

## To create a backup

1. Open Settings.
2. Open the backup section.
3. Select the backup option.
4. Save the generated JSON file in a safe location.

## To restore a backup

1. Open Settings.
2. Select the restore option.
3. Choose a valid BizFlow backup JSON file.
4. Confirm the restoration.
5. Verify the restored data.

Restoring a backup replaces the current application data with the data contained in the backup.

Keep recent backup files in a safe location before performing destructive operations such as a full data reset.

---

# Reset All Data

The **Reset All Data** option is available in Settings under the data-management area.

It permanently removes all local BizFlow data, including:

* Products
* Categories
* Sales
* Sale items
* Customers
* Expenses
* Stock movements
* Business settings

The application asks for confirmation before performing the reset.

Use this feature when:

* Starting a fresh business setup
* Removing test data
* Recovering from an unwanted local data state
* Preparing the application for a new demonstration

For business data that may be needed later, create a backup before resetting.

After resetting, the application can be used as a clean installation or the demo dataset can be loaded again for testing.

---

# CSV Export

BizFlow provides CSV export functionality for supported business data.

CSV files can be opened using applications such as:

* Microsoft Excel
* LibreOffice Calc
* Google Sheets
* Other compatible spreadsheet applications

---

# PDF Receipts

Completed sales can be converted into PDF receipts.

Receipt information can include:

* Business information
* Sale reference
* Date and time
* Customer information
* Purchased products
* Quantities
* Prices
* Discounts
* Total
* Payment information

---

# Currency

The application supports configurable business currency settings.

The selected currency is used in supported financial interfaces, including relevant sales, inventory, expense, dashboard, and report views.

Review currency formatting and financial calculations when adapting the application for a new market.

---

# Theme

BizFlow supports:

* Light mode
* Dark mode

The theme can be changed from Settings.

---

# Validation & Error Handling

The application includes validation and user feedback for common operations, such as:

* Required fields
* Invalid numerical values
* Product stock availability
* Duplicate or invalid records
* Backup validation
* Restore errors
* Empty data states
* Loading states
* Operation failures
* Confirmation dialogs for destructive actions

The POS barcode workflow also provides feedback for unknown or ambiguous barcode matches and respects existing stock validation.

Destructive operations, including backup restoration and full data reset, require confirmation.

---

# Testing

Before distributing a customized version, run:

```bash
flutter analyze
```

Run the automated test suite:

```bash
flutter test
```

A release Web build can be generated with:

```bash
flutter build web --release
```

## Recommended barcode tests

* Create a product with a barcode.
* Submit the barcode using typed input followed by Enter.
* Confirm the correct product is added to the cart.
* Submit an unknown barcode.
* Test repeated submissions of the same barcode.
* Verify stock validation.
* Verify barcode values with leading zeros.
* Test a compatible physical scanner on the intended device, if required.

The basic workflow has been tested in Flutter Web using typed input and Enter. Physical scanner testing remains necessary when a real scanner is part of the intended deployment.

## Recommended data tests

* Test product creation, editing, and deletion.
* Verify historical sales remain after product deletion.
* Test sale cancellation with existing and deleted products.
* Test backup and restore.
* Test Reset All Data.
* Verify persistence after restarting or refreshing the application.
* Test loading demo data after a reset.

Repeat the relevant tests after significant database or business-logic changes.

---

# Important Notes

BizFlow is designed as an offline-first application.

The core application does not require:

* A custom backend server
* A hosted database
* User registration
* Cloud authentication

Additional cloud functionality can be added by developers if required for a particular business use case.

Application data is stored locally, so regular backups are recommended for important business data.

The barcode workflow targets compatible keyboard-emulating scanners. It does not automatically imply support for every camera-based scanner, scanner SDK, mobile device, or hardware configuration.

---

# Recommended Customization Workflow

After purchasing the source code:

1. Run the original application.
2. Load the demo data.
3. Explore the main features.
4. Create a backup before making major changes.
5. Customize branding and theme.
6. Customize business requirements.
7. Configure product barcodes if barcode scanning is required.
8. Test database operations.
9. Test product deletion and historical sales behavior.
10. Test barcode input and stock validation.
11. Test backup and restore.
12. Test the Reset All Data workflow.
13. Run `flutter analyze`.
14. Run `flutter test`.
15. Create a release build.
16. Test the customized application on the target platform.

---

# Support

For technical support, please provide:

* Flutter version
* Dart version
* Operating system
* Target platform
* Error message
* Relevant console output
* Steps required to reproduce the problem

Providing this information makes troubleshooting significantly easier.

---

# License

This project is provided according to the license and usage terms included with your purchase.

Please review the license terms before redistributing, reselling, sublicensing, or publishing modified versions of the source code.

---

# Credits

Built with:

* Flutter
* Dart
* Drift
* SQLite

---

# BizFlow

**Offline-first Flutter POS & Inventory Template for Small Businesses**

Designed for developers who want a customizable starting point for building POS and inventory applications.
