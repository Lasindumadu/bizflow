# BizFlow — Installation Guide

## 1. Overview

BizFlow is a Flutter-based offline-first POS and inventory management application.

The project includes Flutter source code and platform configurations for:

* Android
* iOS
* Web
* Windows
* macOS
* Linux

The core application uses a local database and does not require a custom backend server.

---

# 2. Requirements

## Required

Install:

* Flutter SDK
* Dart SDK included with Flutter
* Git
* A Flutter-compatible IDE such as Visual Studio Code or Android Studio

Flutter should be configured and available from the command line.

Verify the installation with:

```bash
flutter --version
```

Then run:

```bash
flutter doctor
```

Resolve any environment issues relevant to your target platform.

---

# 3. Get the Project Ready

Extract the purchased BizFlow package.

Open the project directory in Visual Studio Code, Android Studio, or another compatible IDE.

The project root contains files such as:

```text
pubspec.yaml
pubspec.lock
analysis_options.yaml
lib/
android/
ios/
web/
windows/
macos/
linux/
test/
```

---

# 4. Install Dependencies

Open a terminal in the project root and run:

```bash
flutter pub get
```

Flutter will download the dependencies defined in `pubspec.yaml`.

---

# 5. Check the Project

Run:

```bash
flutter analyze
```

The project should complete analysis without errors.

---

# 6. Run on Chrome

Chrome can be used for development and testing.

Run:

```bash
flutter run -d chrome
```

The application will open in Google Chrome.

---

# 7. Run on Microsoft Edge

If Microsoft Edge is available as a Flutter device, run:

```bash
flutter run -d edge
```

---

# 8. Web Production Build

To create a production web build:

```bash
flutter build web --release
```

The generated application will be placed in:

```text
build/web
```

---

# 9. Running the Production Web Build Locally

The generated web application should be served through a local HTTP server rather than opened directly from the filesystem.

BizFlow includes:

```text
serve_bizflow.py
```

This helper serves the production `build/web` directory with the headers required by the web database configuration.

After creating the production build, run:

```bash
python serve_bizflow.py
```

The server will start at:

```text
http://localhost:8080
```

Open that address in your browser.

---

# 10. Web Database Storage

BizFlow uses Drift with SQLite WASM for web database functionality.

The production web build includes the required database assets:

```text
build/web/sqlite3.wasm

build/web/drift_worker.js
```

The included production server helper provides the required cross-origin headers for the web database environment.

Do not remove these files from the generated web build.

---

# 11. Android Setup

Android development requires the Android SDK.

Install Android Studio and configure:

* Android SDK
* Android SDK Platform
* Android SDK Build-Tools
* Android SDK Command-line Tools
* Android Emulator, if required

Then verify the environment:

```bash
flutter doctor
```

Connect a physical Android device or start an Android emulator.

Check available devices:

```bash
flutter devices
```

Then run:

```bash
flutter run
```

### Important

The source package includes the Android project configuration.

Before distributing a customized Android application, configure and test the Android environment on the development machine.

---

# 12. Building an Android APK

After configuring the Android SDK, a release APK can be generated with:

```bash
flutter build apk --release
```

The generated APK will normally be located under:

```text
build/app/outputs/flutter-apk/
```

For a Play Store App Bundle:

```bash
flutter build appbundle --release
```

The generated App Bundle will normally be located under:

```text
build/app/outputs/bundle/release/
```

Before publishing an Android application, configure the application's signing and package identity appropriately.

---

# 13. iOS Setup

iOS development requires macOS and Xcode.

Install:

* Xcode
* CocoaPods where required
* Apple development tools

Then run:

```bash
flutter doctor
```

Install dependencies:

```bash
flutter pub get
```

Run on an available iOS simulator or physical device:

```bash
flutter run
```

iOS development and release builds must be performed on a supported macOS environment.

---

# 14. Windows Setup

For Windows desktop development, install the required Visual Studio desktop development tools.

Check the environment with:

```bash
flutter doctor
```

Then verify Windows is available:

```bash
flutter devices
```

Run:

```bash
flutter run -d windows
```

Build a release version with:

```bash
flutter build windows --release
```

---

# 15. macOS Setup

macOS development requires macOS and Xcode.

After configuring the environment:

```bash
flutter run -d macos
```

A release build can be created with:

```bash
flutter build macos --release
```

---

# 16. Linux Setup

Linux desktop development requires the Flutter Linux development dependencies.

Check the environment:

```bash
flutter doctor
```

Then run:

```bash
flutter run -d linux
```

A release build can be created with:

```bash
flutter build linux --release
```

---

# 17. First Launch

After starting the application, the main navigation provides access to:

* Dashboard
* Products
* POS
* Sales
* Customers
* Inventory
* Expenses
* Reports
* Settings

The application can be configured with the business information required by the user.

---

# 18. Loading Demo Data

BizFlow includes sample data for demonstration.

Open:

**Settings → Demo Data**

Then select:

**Load Demo Data**

The demo dataset includes sample:

* Business information
* Categories
* Products
* Customers
* Sales
* Expenses
* Stock movements

This is useful for exploring the application before entering real business information.

Loading demo data applies the included demo business settings.

---

# 19. Clearing Demo Data

Use:

**Settings → Demo Data → Clear Demo Data**

This removes the records created by the BizFlow demo-data system.

The demo business settings are also applied when demo data is loaded.

If important business information already exists, create a backup before loading or clearing demo data.

---

# 20. Backup

BizFlow provides a local JSON backup system.

Open:

**Settings → Backup**

Create a backup and save the generated JSON file in a safe location.

Backups can contain:

* Products
* Categories
* Sales
* Sale items
* Customers
* Expenses
* Stock movements
* Business settings

Regular backups are recommended when using BizFlow with important business data.

---

# 21. Restore

To restore a BizFlow backup:

1. Open **Settings**.
2. Select the restore option.
3. Choose a BizFlow backup JSON file.
4. Confirm the operation.

The backup file is validated before restoration.

### Important

Restoring a backup replaces the current application data with the data contained in the selected backup.

Create a backup of the current data before performing a restore if the current data needs to be preserved.

---

# 22. Reset All Data

BizFlow provides a **Reset All Data** option for starting with a completely clean local database.

Use:

**Settings → Data Management / Development → Reset All Data**

The exact Settings section label may vary depending on the application configuration.

Reset All Data permanently removes:

* Products
* Categories
* Sales
* Sale items
* Customers
* Expenses
* Stock movements
* Business settings

The application requires confirmation before performing the reset.

### Important

Reset All Data is a destructive operation.

It is **not an undo function** and deleted data cannot be recovered through the application after the reset.

If the current data may be needed later:

1. Open **Settings**.
2. Create a backup.
3. Store the backup JSON file safely.
4. Perform Reset All Data only after confirming that the reset is required.

### Starting Fresh

After the reset, BizFlow can be used as an empty application.

Alternatively, load the demo dataset again:

**Settings → Load Demo Data**

This is useful for returning the application to a clean demonstration state.

---

# 23. CSV Export

Supported information can be exported as CSV files.

These files can be opened using:

* Microsoft Excel
* Google Sheets
* LibreOffice Calc
* Other spreadsheet applications

---

# 24. PDF Receipts

Completed sales can generate PDF receipts.

Receipt output includes the relevant business, sale, product, payment, and total information available for the transaction.

---

# 25. Customizing the Application

Before making significant changes:

1. Make a copy of the original project.
2. Create a database backup if working with application data.
3. Make one logical change at a time.
4. Run `flutter analyze`.
5. Test the affected feature.
6. Create a release build when the changes are complete.

See `CUSTOMIZATION.md` for more information.

---

# 26. Recommended Development Workflow

```text
Open project

     ↓

flutter pub get

     ↓

flutter doctor

     ↓

flutter analyze

     ↓

Run application

     ↓

Test features

     ↓

Customize

     ↓

flutter analyze

     ↓

Create release build

     ↓

Test release build

     ↓

Deploy
```

---

# 27. Troubleshooting

## Flutter command not found

Make sure the Flutter SDK is installed and its `bin` directory is included in the system PATH.

Verify:

```bash
flutter --version
```

---

## Dependencies are missing

Run:

```bash
flutter pub get
```

---

## Build problems after changing dependencies

Try:

```bash
flutter clean

flutter pub get
```

Then run the application again.

---

## No Flutter devices available

Run:

```bash
flutter devices
```

Then check:

```bash
flutter doctor
```

Install and configure the development platform required for your target device.

---

## Web application does not behave correctly when opening build files directly

Serve the production build through an HTTP server.

For BizFlow, use:

```bash
python serve_bizflow.py
```

Then open:

```text
http://localhost:8080
```

---

## Need to start with a clean database

If the application contains unwanted test or demonstration data:

1. Create a backup if the existing data may be needed later.
2. Open **Settings**.
3. Select **Reset All Data**.
4. Confirm the reset.
5. Start entering new business data or load the demo dataset again.

---

# 28. Recommended Release Checklist

Before distributing a customized version:

* [ ] Run `flutter pub get`
* [ ] Run `flutter doctor`
* [ ] Run `flutter analyze`
* [ ] Test Dashboard
* [ ] Test Products
* [ ] Test product deletion
* [ ] Verify historical sales remain after product deletion
* [ ] Test Categories
* [ ] Test POS
* [ ] Test Checkout
* [ ] Test Sales
* [ ] Test sale cancellation
* [ ] Test sale cancellation after deleting a related product
* [ ] Test Customers
* [ ] Test Inventory
* [ ] Test Expenses
* [ ] Test Reports
* [ ] Test Settings
* [ ] Test Backup
* [ ] Test Restore
* [ ] Test CSV export
* [ ] Test PDF receipts
* [ ] Test Reset All Data
* [ ] Verify data remains reset after application refresh/restart
* [ ] Test loading demo data after a reset
* [ ] Test light theme
* [ ] Test dark theme
* [ ] Test responsive layouts
* [ ] Test demo data
* [ ] Test target platform
* [ ] Create release build

---

# 29. Support Information

When reporting a technical issue, provide:

* Flutter version
* Dart version
* Operating system
* Target platform
* Device/browser
* Exact error message
* Console output
* Steps to reproduce the problem

This information helps identify environment-specific problems quickly.

---

# BizFlow

**Offline-first Flutter POS & Inventory Template**

Use the included source code as a customizable foundation for building small-business POS and inventory applications.
