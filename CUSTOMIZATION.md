# BizFlow — Customization Guide

## 1. Overview

BizFlow is provided as a Flutter source-code template so developers can adapt the application to their own business requirements.

This guide identifies the main areas that can be customized.

Before making major changes, create a backup of the original project.

---

# 2. Project Structure

The main source code is located under:

```text
lib/
```

The project is organized into several areas:

```text
lib/

├── core/

├── data/

├── features/

├── models/

└── main.dart
```

### `core/`

Contains reusable application-level functionality such as:

* Theme
* Utility functions
* Shared widgets
* Responsive UI helpers

### `data/`

Contains:

* Database definitions
* Database tables
* Database provider
* Repositories
* Demo data
* Data services

### `features/`

Contains the main application modules:

* Dashboard
* Products
* POS
* Sales
* Customers
* Inventory
* Expenses
* Reports
* Settings

### `models/`

Contains application data models where applicable.

### `main.dart`

Contains the application entry point and top-level application configuration.

---

# 3. Application Branding

The application's visual identity can be customized through the theme configuration.

The main theme files are located under:

```text
lib/core/theme/
```

The theme contains definitions for:

* Primary colors
* Background colors
* Surface colors
* Text colors
* Borders
* Dividers
* Success states
* Warning states
* Error states
* Information states
* Typography
* Dimensions
* Light theme
* Dark theme

---

# 4. Changing the Primary Color

The application's primary color is defined in the theme configuration.

Locate the `AppColors` definitions under:

```text
lib/core/theme/
```

Change the relevant color values to match the desired brand.

For example:

```dart id="h4x8xq"
static const Color primary = Color(0xFF2563EB);
```

A different brand color can be substituted.

After changing the theme:

```bash id="6nqz9m"
flutter analyze
```

Then run the application and verify:

* Buttons
* Navigation
* Cards
* Selected states
* Inputs
* Dialogs
* Other interactive elements

---

# 5. Typography

Typography is managed through the application's shared text-style definitions.

Locate:

```text
lib/core/theme/
```

and identify the application's text-style configuration.

Centralizing text styles makes it easier to maintain a consistent visual design.

When changing typography, test:

* Dashboard
* Tables
* Forms
* POS
* Reports
* Dialogs
* Mobile layouts

---

# 6. Responsive Dimensions

Shared dimensions are defined in the core theme configuration.

These include:

* Screen padding
* Spacing
* Border radii
* Input heights
* Button heights
* Card dimensions

Using shared dimensions rather than hard-coded values helps maintain consistent layouts.

---

# 7. Application Name

The application name appears in multiple places depending on the target platform.

The Flutter package name and application metadata are defined through:

```text
pubspec.yaml
```

The current package name is:

```text
bizflow
```

When creating a customized application, update the relevant platform-specific application metadata as required.

For Android, review the Android project configuration.

For iOS, review the iOS project configuration.

For web, review the web application metadata and manifest.

For desktop platforms, review the relevant platform project configuration.

---

# 8. Package / Application Identifier

The application identifier should be reviewed before publishing a customized application.

For Android, review the package/application identifier under the Android project.

For iOS, review the bundle identifier in the iOS project.

For web and desktop targets, review the relevant platform metadata.

Do not change identifiers without understanding the effect on an existing deployed application.

Changing an Android application identifier, for example, causes the resulting application to be treated as a different package by Android.

---

# 9. Business Information

Business information is configurable through the application's Settings screen.

Supported information includes:

* Business name
* Address
* Phone
* Email
* Currency

The settings are stored locally in the database.

This means the application can be customized for different businesses without changing the source code for ordinary business-information changes.

---

# 10. Currency

Currency can be changed from the Settings interface.

The selected currency is used by supported financial interfaces such as:

* Dashboard
* Products
* POS
* Sales
* Customers
* Expenses
* Reports
* Receipts

If additional currency behavior is required, review the relevant settings and financial display logic before modifying the database schema.

---

# 11. Product Fields

Product information is defined by the database and product feature.

Current product fields include:

* ID
* Name
* SKU
* Category
* Purchase price
* Selling price
* Stock quantity
* Low-stock threshold
* Barcode

Database table definitions are located under:

```text
lib/data/database/tables/
```

Product-related screens are located under:

```text
lib/features/products/
```

Product repository logic is located under:

```text
lib/data/repositories/
```

---

# 12. Adding Product Fields

Adding a new product field normally requires changes to several areas:

1. Drift table definition
2. Database schema version
3. Database migration
4. Generated Drift database code
5. Product repository
6. Product forms
7. Product display
8. Product search/filter logic where applicable
9. Backup and restore
10. CSV export where applicable
11. Reports where applicable
12. Demo data where applicable

Do not add a database column only to the UI.

A database schema change should include an appropriate Drift migration.

After modifying the schema, regenerate the Drift code using the project's build process.

---

# 13. Product Categories

Categories can be managed through the application.

Category-related functionality is located in the Products feature and database category table.

Categories can be customized for different business types.

Examples:

```text
Electronics

Groceries

Beverages

Household

Personal Care

Stationery
```

These are demonstration categories and can be replaced with categories appropriate for a customized application.

---

# 14. Product Deletion and Historical Sales

Products can be deleted from the application without automatically deleting historical sales records.

This allows historical transactions to remain available even when a product is no longer actively sold.

When customizing product deletion behavior, consider the relationship between:

* Products
* Sale items
* Sales
* Stock movements
* Reports
* Backup and restore

The current implementation allows a historical sale to remain accessible after its related product has been deleted.

Sale cancellation also handles deleted products safely. If a product from a historical sale no longer exists, the sale can still be cancelled. Stock is restored for products that still exist, while a deleted product cannot receive stock because its product record no longer exists.

If changing this behavior, test:

1. Create a sale.
2. Delete the related product.
3. Open the historical sale.
4. Cancel the sale.
5. Verify that the remaining products are handled correctly.
6. Verify the sale status.
7. Verify stock movements.
8. Verify reports.

---

# 15. POS Customization

The POS feature is located under:

```text
lib/features/pos/
```

Common customization areas include:

* Product search
* Cart behavior
* Quantity controls
* Discounts
* Customer selection
* Payment methods
* Payment calculations
* Checkout behavior
* Stock validation
* Receipt generation

When modifying checkout behavior, test the complete workflow from:

```text
Product

   ↓

Cart

   ↓

Checkout

   ↓

Sale

   ↓

Stock

   ↓

Customer balance

   ↓

Receipt

   ↓

Reports
```

Changes to one stage can affect later stages.

---

# 16. Payment Methods

Payment method handling is part of the sales/POS workflow.

Developers can extend payment options according to their requirements.

For example, a customized application could add additional payment methods.

When adding a payment method, review:

* POS interface
* Sale database fields
* Sale repository
* Sales screen
* Receipt output
* Reports

---

# 17. Discounts

The POS supports discounts as part of the sale calculation.

When modifying discount behavior, verify:

* Subtotal
* Discount
* Final total
* Paid amount
* Change
* Receipt
* Reports

Use consistent calculations throughout the application.

---

# 18. Customer Management

Customer functionality is located under:

```text
lib/features/customers/
```

Customer information includes:

* Name
* Phone
* Email
* Address
* Outstanding balance

Additional customer fields can be added by updating the database schema, repository, forms, screens, backup/restore logic, and any related reports.

---

# 19. Inventory Customization

Inventory functionality is located under:

```text
lib/features/inventory/
```

The database tracks stock movements with information such as:

* Product
* Movement type
* Quantity
* Previous stock
* New stock
* Note
* Date and time

When changing inventory logic, verify that stock quantities and stock movements remain consistent.

---

# 20. Expense Categories

Expense categories can be adapted for different businesses.

Examples include:

```text
Rent

Utilities

Transport

Supplies

Maintenance

Other
```

Customized applications can introduce additional categories or category management functionality.

---

# 21. Reports

Reports are located under:

```text
lib/features/reports/
```

The reporting system can be extended with additional business metrics.

Possible extensions include:

* Monthly sales
* Daily sales
* Product margins
* Customer sales
* Payment-method summaries
* Tax summaries
* Inventory valuation
* Additional expense analysis

When adding reports, use the existing repository/database layer rather than placing database queries directly into reusable UI components.

---

# 22. Dashboard

Dashboard functionality is located under:

```text
lib/features/dashboard/
```

Dashboard cards and summaries can be customized according to business requirements.

Possible additions include:

* Monthly revenue
* Outstanding customer balances
* Inventory valuation
* Top customers
* Payment summaries
* Additional KPIs

Keep dashboard calculations connected to the repository/data layer.

---

# 23. Receipt Customization

PDF receipt functionality can be customized to match a business's requirements.

Possible changes include:

* Business logo
* Business information
* Receipt title
* Product layout
* Customer information
* Payment information
* Footer
* Terms and conditions
* Contact information

When modifying receipt generation, test both:

* Receipt generation
* Receipt printing/sharing

---

# 24. Backup Format

The backup system stores application data in JSON format.

The backup includes:

* Products
* Categories
* Sales
* Sale items
* Customers
* Expenses
* Stock movements
* Business settings

The backup service is located under the data/service layer.

If database fields are added, the backup system should be updated accordingly.

A schema change should also consider compatibility with previously created backup files.

---

# 25. Database Changes

BizFlow uses Drift for database management.

Database files are located under:

```text
lib/data/database/
```

The main database contains tables for:

* Products
* Categories
* Sales
* Sale items
* Customers
* Expenses
* Stock movements
* Business settings

The database uses schema versioning.

---

# 26. Database Migration

When changing the database schema:

1. Increase the schema version.
2. Add the required migration.
3. Regenerate Drift code.
4. Run `flutter analyze`.
5. Test a fresh database.
6. Test an upgraded existing database.
7. Test backup creation.
8. Test backup restoration.
9. Test affected application features.
10. Test data persistence after application restart or browser refresh where applicable.

Never remove or modify an existing migration without understanding its effect on existing installations.

---

# 27. Demo Data

Demo data is located under:

```text
lib/data/demo/
```

The demo service provides sample:

* Business settings
* Categories
* Customers
* Products
* Sales
* Expenses
* Stock movements

Developers can customize the demo dataset to match their intended marketplace screenshots or business domain.

### Important

Loading demo data applies the demo business settings.

Create a backup before loading demo data if existing business information needs to be preserved.

---

# 28. Data Reset and Recovery

BizFlow includes a **Reset All Data** function for returning the local application database to a clean state.

The reset removes:

* Products
* Categories
* Sales
* Sale items
* Customers
* Expenses
* Stock movements
* Business settings

The reset requires user confirmation before the destructive operation is performed.

### Important

Reset All Data permanently deletes the current local application data.

If the data may be needed later, create a backup before performing the reset.

A recommended recovery workflow is:

```text
Create backup

     ↓

Reset All Data

     ↓

Start with empty database

     ↓

Configure business

     ↓

Add real data
```

For demonstration or testing:

```text
Reset All Data

     ↓

Load Demo Data

     ↓

Test application
```

When customizing the reset functionality, make sure newly added persistent tables are also considered. A new table should be included in the reset workflow if it represents application data that should be removed during a complete reset.

---

# 29. Navigation

The main application shell controls navigation between major sections.

The current application includes:

* Dashboard
* Products
* POS
* Sales
* More

Additional features are available through the More section, including:

* Customers
* Inventory
* Expenses
* Reports
* Settings

Navigation can be customized by adding or removing feature destinations.

When changing navigation, verify the layout on:

* Mobile
* Tablet
* Desktop

---

# 30. Adding a New Feature

For a new feature, a recommended structure is:

```text
lib/features/

└── new_feature/

    ├── presentation/

    │   ├── screens/

    │   └── widgets/

    └── ...
```

If the feature requires persistent data, also consider:

```text
lib/data/database/tables/

lib/data/repositories/
```

Keep feature-specific UI separate from database implementation where practical.

---

# 31. Adding a Repository

Repositories provide a useful separation between UI and database operations.

A repository can be used to:

* Query database records
* Insert records
* Update records
* Delete records
* Perform business-specific data operations

This keeps screens focused on presentation and user interaction.

---

# 32. Adding External Services

The current core application does not require a backend service.

A customized application can integrate external services if required.

Examples include:

* Cloud synchronization
* Authentication
* Online payments
* Cloud backup
* Remote analytics
* External APIs

When adding external services, consider:

* Offline behavior
* Error handling
* Authentication
* API failures
* Data synchronization
* Privacy
* Security
* Dependency maintenance

---

# 33. Changing the Web Server Configuration

The production web helper is:

```text
serve_bizflow.py
```

It serves:

```text
build/web
```

and supplies the cross-origin headers required by the web database environment.

If deploying BizFlow to another server, make sure the server configuration supports the requirements of the selected Drift web storage implementation.

Do not remove the SQLite WASM or Drift worker assets from the web build.

After changing the web database configuration, test:

* Initial database creation
* Adding data
* Browser refresh
* Browser restart
* Backup
* Restore
* Reset All Data

---

# 34. Adding Authentication

Authentication is not included in the current core application.

If authentication is added, the developer should design:

* User accounts
* Password handling
* Session management
* Authorization
* Logout
* Offline behavior
* Data ownership
* Recovery mechanisms

Authentication should not be implemented by simply storing plaintext passwords in the local database.

---

# 35. Testing After Customization

After modifying the application:

```bash id="d3zbrq"
flutter analyze
```

Then test the affected feature manually.

For larger changes, also test:

* Fresh installation
* Existing local data
* Database migration
* Backup
* Restore
* Demo data
* Reset All Data
* Product deletion
* Historical sales after product deletion
* Sale cancellation involving deleted products
* Data persistence after application restart
* Web browser refresh where applicable
* Responsive layouts
* Light theme
* Dark theme
* Target platform

For a web release:

```bash id="4gk7ti"
flutter build web --release
```

Then test the generated production build through an HTTP server.

---

# 36. Safe Customization Workflow

The recommended workflow is:

```text
Backup original project

        ↓

Make one logical change

        ↓

Run flutter analyze

        ↓

Run application

        ↓

Test changed feature

        ↓

Test related features

        ↓

Test data persistence

        ↓

Create release build

        ↓

Test release build

        ↓

Repeat
```

Avoid making many unrelated changes at once. Smaller changes make problems easier to identify.

---

# 37. Important Developer Notes

### Avoid unnecessary database changes

If a requirement can be implemented without changing the database schema, consider that approach first.

### Keep business logic out of `main.dart`

Application-wide configuration belongs in the appropriate architecture layer.

### Reuse existing theme definitions

Use the existing shared theme, dimensions, and text styles instead of introducing duplicate constants.

### Test responsive layouts

A change that looks correct on desktop may not work correctly on mobile.

### Preserve backup compatibility

When changing persistent data structures, consider existing backup files.

### Preserve destructive-operation safeguards

When modifying product deletion, sale cancellation, demo data, restore, or reset behavior, keep appropriate confirmation and recovery workflows.

### Do not remove web database assets

The production web build depends on the SQLite WASM and Drift worker assets. Changes to web hosting or build configuration should preserve the required files and server configuration.

---

# 38. Customization Checklist

Before delivering a customized application:

* [ ] Change application branding
* [ ] Review application identifiers
* [ ] Review theme colors
* [ ] Review typography
* [ ] Review business information
* [ ] Review currency
* [ ] Review product categories
* [ ] Review demo data
* [ ] Review receipt design
* [ ] Review dashboard
* [ ] Review reports
* [ ] Review navigation
* [ ] Test product deletion
* [ ] Verify historical sales after product deletion
* [ ] Test sale cancellation
* [ ] Test sale cancellation involving a deleted product
* [ ] Test POS
* [ ] Test sales
* [ ] Test inventory
* [ ] Test customers
* [ ] Test expenses
* [ ] Test backup
* [ ] Test restore
* [ ] Test Reset All Data
* [ ] Test demo data after reset
* [ ] Test data persistence
* [ ] Run `flutter analyze`
* [ ] Build the target platform
* [ ] Test the release build

---

# BizFlow

**Offline-first Flutter POS & Inventory Template**

Customize the source code according to your business requirements while preserving the application's database, backup, data-reset, and feature relationships.
