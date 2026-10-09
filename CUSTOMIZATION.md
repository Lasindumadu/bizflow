# BizFlow — Customization & Reskin Guide

## 1. Overview

BizFlow is a Flutter POS and inventory management template designed to be customized and rebranded for your own business or application.

This guide explains the main customization points, including:

* Application name
* Android application ID
* iOS bundle identifier
* Application icons
* Splash screen
* Application colors and theme
* Business information
* Currency
* Demo data
* Barcode scanning
* Application text and labels
* Android release preparation
* iOS release preparation

> **Important:** Replace the BizFlow branding and identifiers with values belonging to your own application before distributing a customized production build.

The original application identifiers are:

```text
Android namespace:
com.bizflow.app

Android application ID:
com.bizflow.app

iOS Runner bundle identifier:
com.bizflow.app
```

Do not publish an application using these identifiers if you are creating your own branded application.

---

## 2. Recommended Customization Order

For a new branded application, use this order:

1. Back up the original project.
2. Change the application name.
3. Change the Android application ID.
4. Change the iOS bundle identifier.
5. Replace the application icon.
6. Replace the splash screen/launch assets.
7. Update colors and theme.
8. Update business information and currency.
9. Review application text.
10. Configure and test barcode scanning if required.
11. Run the application and test the customized branding.
12. Configure buyer-owned release signing.
13. Create the release build.
14. Test the release build before publishing.

Keep the original source unchanged until the customized version has been verified.

---

## 3. Change the Application Name

The application display name is the name shown to users.

### Android

Open:

```text
android/app/src/main/AndroidManifest.xml
```

Look for the application label.

Depending on the Flutter project configuration, it may reference a string resource or contain the application name directly.

If the manifest contains a value such as:

```xml
android:label="BizFlow"
```

change it to your application name:

```xml
android:label="My Business App"
```

If it references a string resource, for example:

```xml
android:label="@string/app_name"
```

open:

```text
android/app/src/main/res/values/strings.xml
```

and change the corresponding value:

```xml
<string name="app_name">My Business App</string>
```

If `strings.xml` does not contain an `app_name` value, keep the existing manifest configuration and follow the value already used by the project.

### iOS

Open:

```text
ios/Runner/Info.plist
```

The display name can be configured through the application's display-name entry.

If the project contains:

```xml
<key>CFBundleDisplayName</key>
```

change its value to your application name.

For example:

```xml
<key>CFBundleDisplayName</key>
<string>My Business App</string>
```

If the project uses another existing display-name configuration, update that existing value rather than adding duplicate keys.

### Flutter/Web

Search the project for:

```text
BizFlow
```

Review the application title and visible branding locations.

Do not blindly replace every occurrence of `BizFlow`, because some occurrences may belong to documentation, database/demo content, or package metadata.

---

## 4. Change the Android Application ID

The original Android application ID is:

```text
com.bizflow.app
```

The value is defined in:

```text
android/app/build.gradle.kts
```

The relevant configuration is similar to:

```kotlin
android {
    namespace = "com.bizflow.app"

    defaultConfig {
        applicationId = "com.bizflow.app"
    }
}
```

### Step 1 — Choose your new ID

Use a unique reverse-domain identifier.

Example:

```text
com.mycompany.mybusiness
```

Avoid spaces, uppercase letters, and special characters.

A common format is:

```text
com.companyname.appname
```

### Step 2 — Change the namespace

In:

```text
android/app/build.gradle.kts
```

change:

```kotlin
namespace = "com.bizflow.app"
```

to your new namespace.

Example:

```kotlin
namespace = "com.mycompany.mybusiness"
```

### Step 3 — Change the application ID

In the same file, change:

```kotlin
applicationId = "com.bizflow.app"
```

to:

```kotlin
applicationId = "com.mycompany.mybusiness"
```

Use the same identifier consistently unless your project intentionally requires different values.

### Step 4 — Check for additional references

Search the entire project for:

```text
com.bizflow.app
```

Review every result.

Do not change unrelated documentation examples automatically. Change project configuration references that identify the Android application.

### Important

Changing the application ID creates a different Android application identity.

If you are publishing an update to an application that already exists in Google Play, the application ID must remain the same as the existing published application.

---

## 5. Change the iOS Bundle Identifier

The original iOS Runner bundle identifier is:

```text
com.bizflow.app
```

The main iOS configuration is stored in:

```text
ios/Runner.xcodeproj/project.pbxproj
```

The existing Runner configuration uses:

```text
PRODUCT_BUNDLE_IDENTIFIER = com.bizflow.app;
```

### Recommended method — Xcode

On macOS, open the iOS project:

```text
ios/Runner.xcworkspace
```

in Xcode.

Select:

```text
Runner
```

in the project navigator.

Then select the:

```text
Runner target
```

Open:

```text
Signing & Capabilities
```

Set the Team to your Apple Developer team.

Set the Bundle Identifier to your own identifier.

Example:

```text
com.mycompany.mybusiness
```

Xcode will maintain the appropriate project configuration.

### Manual configuration

The main Runner bundle identifier can also be found in:

```text
ios/Runner.xcodeproj/project.pbxproj
```

Search for:

```text
PRODUCT_BUNDLE_IDENTIFIER
```

Change the **Runner application** entries to your own bundle identifier.

Do not change the separate RunnerTests identifier to the application's bundle identifier unless you specifically intend to rename the test target.

### Important

If you are updating an existing App Store application, keep the existing bundle identifier.

A new bundle identifier represents a different iOS application identity.

---

## 6. Replace the Android Launcher Icon

Android launcher icons are stored under:

```text
android/app/src/main/res/
```

Typical launcher resource directories include:

```text
mipmap-mdpi
mipmap-hdpi
mipmap-xhdpi
mipmap-xxhdpi
mipmap-xxxhdpi
```

Depending on the Flutter/Android project configuration, adaptive icons may also use:

```text
mipmap-anydpi-v26
```

and related drawable resources.

### Recommended process

1. Prepare your new application icon.
2. Generate appropriately sized Android launcher assets.
3. Replace the existing BizFlow launcher resources.
4. Preserve the existing resource filenames referenced by the Android manifest.
5. If adaptive icons are used, replace both the foreground/background resources and the adaptive icon definition as appropriate.
6. Clean and rebuild the application.

From the project root:

```powershell
flutter clean
flutter pub get
```

Then test:

```powershell
flutter run
```

For production:

```powershell
flutter build appbundle --release
```

Do not replace the launcher icon with a single arbitrary image if the Android configuration expects multiple density resources.

---

## 7. Replace the iOS App Icon

The iOS application icon assets are located under:

```text
ios/Runner/Assets.xcassets/
```

The application icon asset is normally:

```text
AppIcon.appiconset
```

### Using Xcode

On macOS:

1. Open `ios/Runner.xcworkspace`.
2. Select `Runner`.
3. Open `Assets.xcassets`.
4. Select `AppIcon`.
5. Replace the supplied icon images with your own correctly sized assets.
6. Make sure all required icon slots are populated.
7. Build and test the application.

Do not remove the AppIcon asset itself unless you also update the project to use a different asset name.

---

## 8. Replace the Splash / Launch Screen

### Android

Flutter Android projects can use Android launch resources and/or Flutter launch configuration depending on the project version.

Review:

```text
android/app/src/main/res/
```

for launch-screen resources.

Also review:

```text
android/app/src/main/AndroidManifest.xml
```

for the activity and theme configuration.

When replacing launch assets:

* Preserve the existing resource names when possible.
* Preserve the existing theme structure.
* Replace only the branding/assets you need.
* Test both cold launch and normal application startup.

### iOS

Review:

```text
ios/Runner/
```

and:

```text
ios/Runner/Assets.xcassets/
```

for the launch-screen resources used by the project.

If a launch storyboard is used, it is commonly located at:

```text
ios/Runner/Base.lproj/LaunchScreen.storyboard
```

Open the project in Xcode and inspect the Runner target's launch-screen configuration.

Replace the branding/images while preserving the existing launch-screen structure.

### Important

Do not remove the launch-screen configuration simply to change the logo.

---

## 9. Change Application Colors and Theme

BizFlow's main theme files are under:

```text
lib/core/theme/
```

Review:

```text
lib/core/theme/app_colors.dart
lib/core/theme/app_dimensions.dart
lib/core/theme/app_text_styles.dart
```

The main BizFlow colors include:

```text
Primary:       #2563EB
Primary Dark:  #1D4ED8
Primary Light: #3B82F6
Background:    #F6F8FC
Text:          #0F172A
Secondary:     #475569
Muted:         #64748B
Border:        #E2E8F0
```

Change the centralized color definitions rather than replacing colors throughout individual screens.

This makes future branding changes easier to maintain.

After changing the theme, test:

* Dashboard
* Products
* POS
* Sales
* Customers
* Expenses
* Inventory
* Reports
* Settings
* Dialogs
* Buttons
* Tables/cards
* Light mode
* Dark mode

---

## 10. Change Business Information

Open the application's Settings screen.

Business information can be customized through the application's business settings.

Typical values include:

* Business name
* Address
* Phone number
* Email
* Currency

These settings are stored in the local database and are also used by application features such as receipts.

For a production application, replace the demonstration business information with your own business information.

Do not publish the demo business identity as your own business unless that is intentional.

---

## 11. Change Currency

BizFlow supports business/currency configuration through the application settings.

Before using the application for a different market:

1. Open Settings.
2. Select the desired currency.
3. Save the settings.
4. Test products and prices.
5. Test checkout.
6. Test sales history.
7. Test reports.
8. Generate a receipt and verify the currency.

Always verify calculations after changing currency settings.

Changing the displayed currency does not automatically convert existing prices or historical financial records. Review your data and pricing before using a customized application in production.

---

## 12. Barcode Scanning Setup

BizFlow supports barcode entry through the existing Point of Sale (POS) search field.

The barcode workflow supports compatible USB and Bluetooth barcode scanners that operate as keyboard input devices. A dedicated barcode-scanning package is not required for this workflow.

### Product Barcode Setup

1. Open the Products section.
2. Create a product or edit an existing product.
3. Enter the product's barcode in the barcode field.
4. Save the product.
5. Open the POS screen and test the barcode.

Barcode values are stored as strings, allowing numeric and alphanumeric values, including leading zeros.

Each product should have a unique barcode. Duplicate barcode values can cause ambiguous matches and prevent automatic product selection.

### Scanning at the POS

1. Open the POS screen.
2. Focus the product search field.
3. Scan the product barcode using a compatible scanner configured to send an Enter key after the barcode.
4. Verify that the matching product is added to the cart.
5. Scan the same barcode again and verify that the quantity increases when sufficient stock is available.

The search field is cleared after a successful barcode addition.

### Barcode Validation

BizFlow checks the submitted barcode against stored product barcodes.

* **Matching barcode:** Adds the matching product to the cart.
* **Unknown barcode:** Displays a message indicating that no product was found.
* **Duplicate barcode:** Displays a message indicating that multiple products use the barcode.
* **Insufficient stock:** Uses the existing stock-validation behavior to prevent adding an unavailable quantity.

The barcode workflow uses the existing cart and stock-validation logic. It does not bypass the application's stock limits.

### Testing Without a Physical Scanner

You can test the workflow in the Flutter web application without purchasing a scanner:

1. Create a test product with a known barcode.
2. Open the POS screen.
3. Type the exact barcode into the search field.
4. Press Enter.
5. Confirm that the product is added to the cart.

Repeat the test with an unknown barcode and an out-of-stock product. Also test scanning the same barcode more than once.

### Physical Scanner Compatibility

For production use, test the actual USB or Bluetooth scanner on the target device.

Confirm that:

* The scanner sends the barcode as keyboard input.
* The scanner is configured to send Enter after the barcode.
* The POS search field receives the complete barcode.
* The expected product is added to the cart.
* Repeated scans update the quantity correctly.
* Stock validation prevents quantities exceeding available stock.

Scanner behavior can vary by device, connection method, keyboard layout, and scanner configuration. Physical hardware should be tested separately before deployment.

---

## 13. Demo Data

BizFlow includes demonstration data so buyers can immediately explore the application.

The demo data is intended for demonstration and testing.

Before publishing a customized production application:

* Review the demo products.
* Review categories.
* Review customers.
* Review sales.
* Review expenses.
* Review stock movements.
* Review product barcodes.
* Replace or remove demonstration information as appropriate.

Do not use demonstration customer information as real customer information.

If you load or clear demo data, verify the resulting application state before using the application with real business data.

---

## 14. Change Visible Application Text

Search the source code for the text you want to customize.

From the project root, PowerShell can be used to search for text:

```powershell
Get-ChildItem lib -Recurse -File | Select-String -Pattern "BizFlow"
```

You can search for other visible text in the same way.

Review each result before changing it.

Avoid global replacement because a word may appear in:

* Documentation
* Database/demo data
* Code identifiers
* Comments
* Package metadata
* Application UI

Change only the occurrences that are intended to be visible in your branded application.

Review the POS search field and barcode validation messages if you want to customize the wording of barcode-related feedback.

---

## 15. Web Branding

BizFlow can also be built for Flutter Web.

Review the web project for branding and browser metadata:

```text
web/
```

Check:

```text
web/index.html
web/manifest.json
web/icons/
```

Update:

* Browser title
* Web application name
* Web icons
* Manifest name
* Manifest short name
* Any branding images

Then build:

```powershell
flutter build web --release
```

Test the generated web application before deployment.

### Barcode Scanning on Web

The barcode workflow uses the POS search field and supports keyboard-style scanner input.

For a compatible USB or Bluetooth scanner:

1. Connect the scanner to the target computer.
2. Open the deployed web application.
3. Focus the POS search field.
4. Scan a product barcode.
5. Confirm that the matching product is added to the cart.

Ensure that the scanner sends Enter after the barcode. Test the workflow in the actual browser and deployment environment before production use.

BizFlow's existing web database configuration and hosting requirements must also be preserved when deploying a customized build.

---

## 16. Android Release Signing

A production Android application must be signed with the buyer's own release credentials.

**Never use another developer's keystore or signing credentials.**

Create or obtain your own Android upload/release keystore.

A typical keystore can be generated with:

```powershell
keytool -genkeypair -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Store the keystore securely.

Do not commit private signing credentials to source control or distribute them with the application source.

For a Flutter Android project, the signing configuration can be connected through:

```text
android/key.properties
```

and:

```text
android/app/build.gradle.kts
```

Follow the signing instructions in the Installation & Release section of this package.

Before distributing a release, build and test the signed application using the buyer's own release configuration.

---

## 17. iOS Release Signing

iOS release signing requires:

* macOS
* Xcode
* An Apple Developer account
* A buyer-owned Apple development/distribution identity
* The correct App ID/bundle identifier

Open:

```text
ios/Runner.xcworkspace
```

in Xcode.

Then:

1. Select the `Runner` target.
2. Open `Signing & Capabilities`.
3. Select your Apple Developer Team.
4. Confirm your Bundle Identifier.
5. Enable automatic signing if appropriate for your project.
6. Select a valid signing certificate/profile.
7. Build and test the application.
8. Create an archive when ready for distribution.

Never distribute another developer's Apple signing credentials.

---

## 18. Production Branding Checklist

Before releasing the customized application, verify the following items.

### Identity

* [ ] Application name changed
* [ ] Android application ID changed
* [ ] iOS bundle identifier changed
* [ ] Web title/manifest updated if publishing Web

### Branding

* [ ] Android launcher icon replaced
* [ ] iOS AppIcon replaced
* [ ] Splash/launch branding replaced
* [ ] Logos replaced where applicable
* [ ] Application colors reviewed
* [ ] Visible BizFlow branding reviewed

### Business

* [ ] Business name updated
* [ ] Address updated
* [ ] Phone/email updated
* [ ] Currency configured
* [ ] Demo data reviewed
* [ ] Demo barcodes reviewed or replaced as appropriate

### Barcode Scanning

* [ ] Product barcodes can be saved and edited
* [ ] Barcode submission adds the correct product to the POS cart
* [ ] Leading zeros are preserved in barcode values
* [ ] Repeated barcode scans update the cart quantity correctly
* [ ] Unknown barcodes display appropriate feedback
* [ ] Duplicate barcodes display appropriate feedback
* [ ] Stock validation works during barcode entry
* [ ] Physical barcode scanner tested on the target device, if applicable

### Android

* [ ] Own keystore created or selected
* [ ] `key.properties` configured locally
* [ ] Release signing configured
* [ ] Release APK tested
* [ ] Release AAB tested/validated

### iOS

* [ ] Own Apple Developer Team selected
* [ ] Bundle identifier configured
* [ ] Signing configuration verified
* [ ] Release archive tested

### Final Testing

* [ ] App launches correctly
* [ ] Navigation works
* [ ] Product management works
* [ ] POS checkout works
* [ ] Sales work
* [ ] Inventory works
* [ ] Reports work
* [ ] Backup/restore works
* [ ] Receipts work
* [ ] Light mode works
* [ ] Dark mode works
* [ ] Customized branding appears consistently
* [ ] Barcode workflow tested in the target environment

---

## 19. Important Release Notes

The source package is a reusable template.

The buyer is responsible for:

* Their own application identity
* Their own Android signing credentials
* Their own Apple Developer account
* Their own Apple signing credentials
* Store accounts
* Store listings
* Screenshots for their customized application
* Legal requirements for their application
* Third-party services or accounts they independently add
* Testing any additional hardware or integrations used by their customized application

Never publish using the original BizFlow application identity:

```text
com.bizflow.app
```

unless you are intentionally maintaining the original application identity.

Barcode scanners and other peripheral devices should be tested for compatibility with the target operating system, browser, and deployment configuration before production distribution.

---

## 20. Safe Customization Principle

When customizing BizFlow:

> Change branding and configuration first. Preserve the working application architecture unless you intentionally need to modify functionality.

Keep backups before making significant changes.

After customization, run:

```powershell
flutter analyze
```

Then run the automated tests:

```powershell
flutter test
```

Finally, test the application on the target platform before creating a production release.

Verify all customized branding, business settings, POS workflows, inventory operations, backups, reports, and barcode scanning behavior before distributing the application.
