# BizFlow — Installation, Build & Release Guide

## 1. Overview

This guide explains how to install, configure, run, customize, and prepare BizFlow for production builds.

BizFlow is an offline-first Flutter application using a local Drift/SQLite database. No server or online backend is required for its core functionality.

The package contains the Flutter source code and documentation required to continue development and customization.

The current project includes Flutter Web support. Android and iOS release instructions are provided for developers who configure and validate the required platform toolchains.

---

# 2. Requirements

## Development

Recommended environment:

* Flutter 3.47.4 stable or a compatible Flutter 3.x release
* Dart 3.13.3 or a compatible Dart 3.x release
* Visual Studio Code or Android Studio
* Flutter/Dart extensions or plugins
* Git is optional

Use the Flutter and Dart versions compatible with the project's dependency constraints. Avoid upgrading dependencies or changing the Flutter toolchain unnecessarily when first validating the source package.

## Android release

For Android production builds:

* Flutter SDK
* Android SDK
* Android Studio or another Android development environment
* Java/JDK compatible with the selected Flutter/Android toolchain
* Android signing keystore for production releases

## iOS release

For iOS production builds:

* macOS
* Xcode
* Flutter SDK
* CocoaPods where required by the Flutter/iOS toolchain
* Apple Developer account
* Buyer-owned Apple signing credentials

> iOS application builds and App Store distribution require macOS and Xcode.

## Barcode-scanning hardware

For the POS barcode workflow:

* A compatible USB or Bluetooth barcode scanner that operates as a keyboard can be used.
* The scanner should submit the scanned value with Enter, unless the input workflow is customized.
* Products must have their barcode values configured in the application before scanning.
* Test the intended scanner and target device before deploying the customized application.

A physical scanner is not required to test the basic workflow in Flutter Web: a barcode can be typed into the POS search field and submitted with Enter.

---

# 3. Extract the Project

Extract the purchased ZIP file.

Open the Flutter source directory:

```text
source_code/
```

Open that directory in Visual Studio Code or Android Studio.

The directory containing `pubspec.yaml` is the Flutter project root.

Run Flutter commands from that directory, not from the outer marketplace package directory.

---

# 4. Verify Flutter

Open a terminal in the project root.

Run:

```powershell
flutter --version
```

Then:

```powershell
flutter doctor
```

Resolve the required toolchain issues for your intended target platform before creating production builds.

Warnings for platforms you do not intend to build for may not prevent builds for your selected target. Check the actual command output and the requirements of your intended platform.

---

# 5. Install Dependencies

From the project root, run:

```powershell
flutter pub get
```

Wait for dependency resolution to complete successfully.

Do not manually edit generated dependency files unless you understand the effect of the change.

Do not upgrade packages automatically simply because newer versions are available. First verify the project's existing dependencies and compatibility requirements.

---

# 6. Run the Application

## Flutter Web

Run:

```powershell
flutter run -d chrome
```

The application should open in Chrome.

If Chrome is not detected, check the Flutter device list:

```powershell
flutter devices
```

## Android

After the Android SDK and a device or emulator are configured:

```powershell
flutter devices
```

Confirm that an Android device is available.

Then run:

```powershell
flutter run
```

Or specify a device:

```powershell
flutter run -d <device-id>
```

Replace `<device-id>` with an actual device ID returned by `flutter devices`.

## iOS

On macOS, make sure the iOS development environment is configured.

From the project root:

```bash
flutter pub get
```

If CocoaPods dependencies are required:

```bash
cd ios
pod install
cd ..
```

Then run:

```bash
flutter devices
```

And:

```bash
flutter run -d <ios-device-id>
```

Replace `<ios-device-id>` with an actual device ID returned by Flutter.

---

# 7. Project Structure

Important directories include:

```text
lib/
android/
ios/
web/
documentation/
```

Application source code is primarily under:

```text
lib/
```

Android platform configuration is under:

```text
android/
```

iOS platform configuration is under:

```text
ios/
```

Web configuration is under:

```text
web/
```

Documentation is under:

```text
documentation/
```

The actual project may contain additional directories, generated files, configuration files, and feature-specific subdirectories.

---

# 8. First Customization Step

Before creating a production release, read:

```text
documentation/CUSTOMIZATION.md
```

The customization guide explains how to change:

* Application name
* Android application ID
* iOS bundle identifier
* Application icons
* Splash/launch branding
* Application colors
* Business information
* Currency
* Demo data
* Visible application branding
* Release signing
* Barcode-related POS behavior

Do not publish the original project under the original BizFlow identity.

The original Android/iOS application identifier is:

```text
com.bizflow.app
```

Use your own application identity for a new branded application.

---

# 9. Android Application Configuration

Open:

```text
android/app/build.gradle.kts
```

The original configuration contains:

```kotlin
namespace = "com.bizflow.app"
```

And:

```kotlin
applicationId = "com.bizflow.app"
```

For a new application, replace these with your own identifier.

Example:

```kotlin
namespace = "com.mycompany.mybusiness"

defaultConfig {
    applicationId = "com.mycompany.mybusiness"
}
```

Use a unique reverse-domain identifier that you own or are authorized to use.

After changing the identifier, run:

```powershell
flutter clean
flutter pub get
```

Then test the application again.

**Important:** The example is illustrative. Preserve the existing Gradle structure, SDK settings, plugins, and other project configuration when making changes.

---

# 10. iOS Application Configuration

Open:

```text
ios/Runner.xcworkspace
```

in Xcode on macOS.

Select:

```text
Runner
```

Then select the Runner target.

Open:

```text
Signing & Capabilities
```

Set:

* Team
* Bundle Identifier
* Signing configuration

The original bundle identifier is:

```text
com.bizflow.app
```

For a new application, use your own identifier, for example:

```text
com.mycompany.mybusiness
```

The project file containing the Runner bundle identifier configuration is:

```text
ios/Runner.xcodeproj/project.pbxproj
```

Search for:

```text
PRODUCT_BUNDLE_IDENTIFIER
```

The main Runner entries use the original BizFlow identifier.

Do not accidentally replace test-target identifiers with the application identifier. Verify the target and configuration before making changes.

---

# 11. Application Name and Branding

Follow:

```text
documentation/CUSTOMIZATION.md
```

for the detailed reskin process.

At minimum, update:

* Application name
* Android launcher icon
* iOS AppIcon
* Splash/launch branding
* Colors
* Logos
* Visible BizFlow branding
* Web title and icons, if publishing Web

After customization, run:

```powershell
flutter analyze
```

Fix real analyzer errors before release.

Also run the automated tests:

```powershell
flutter test
```

Investigate test failures before creating a production release.

---

# 12. Android Debug Build

After configuring the Android development environment, test a debug build:

```powershell
flutter build apk --debug
```

The generated APK is normally under:

```text
build/app/outputs/flutter-apk/
```

Install the APK on a test device and verify the customized application.

Do not use a debug APK as a substitute for a properly signed production release.

---

# 13. Android Release Signing

A release build intended for distribution must use the buyer's own signing credentials.

**Do not use another developer's private keystore or signing credentials.**

## Step 1 — Create a release keystore

A typical example is:

```powershell
keytool -genkeypair -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Choose secure passwords.

Store the keystore outside public source control.

Back up the keystore securely.

If you lose the signing credentials for an existing published application, future updates may be affected, depending on the signing and key-management arrangements.

## Step 2 — Create `key.properties`

Create this file locally:

```text
android/key.properties
```

Example structure:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=C:\\path\\to\\upload-keystore.jks
```

Use your actual local values.

The `storeFile` value must point to the actual keystore location. Verify the path format against the Gradle configuration and operating system.

Do not publish real passwords or private keystore files.

## Step 3 — Configure Gradle signing

Open:

```text
android/app/build.gradle.kts
```

Configure the release signing configuration to read the values from:

```text
android/key.properties
```

A typical Kotlin DSL configuration follows this structure:

```kotlin
import java.io.FileInputStream
import java.util.Properties

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // Preserve the existing Android configuration.

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

**Important:** Merge this configuration into the existing `build.gradle.kts`. Do not replace the entire file with this example.

The existing Flutter/Android configuration must remain intact.

If your installed Flutter/Android Gradle configuration uses a different structure, preserve the existing structure and add the signing configuration accordingly.

Check that release builds cannot silently proceed with missing or incorrect signing configuration. Validate the final signing setup before distribution.

## Step 4 — Protect signing files

Do not upload:

```text
android/key.properties
```

Or:

```text
*.jks
*.keystore
```

to a public repository or distribute your private signing credentials.

---

# 14. Build an Android Release APK

After release signing is configured:

```powershell
flutter build apk --release
```

The release APK is normally generated under:

```text
build/app/outputs/flutter-apk/
```

Install the APK on a test device and verify:

* Application name
* Icon
* Splash screen
* Application ID
* Navigation
* Products
* POS
* Barcode entry, if used
* Sales
* Inventory
* Reports
* Settings
* Backup/restore
* Receipts

---

# 15. Build an Android App Bundle

For Google Play distribution, build an Android App Bundle:

```powershell
flutter build appbundle --release
```

The resulting bundle is normally generated under:

```text
build/app/outputs/bundle/release/
```

Look for:

```text
app-release.aab
```

Before uploading it to Google Play:

1. Confirm the application ID.
2. Confirm the release signing configuration.
3. Test the release build.
4. Confirm the application name.
5. Confirm the launcher icon.
6. Confirm the version number.
7. Confirm the app opens correctly.
8. Confirm production branding is present.
9. Verify that required platform permissions and configuration are appropriate.
10. Validate the bundle using the intended distribution workflow.

---

# 16. Android Release Checklist

Before publishing an Android application:

* [ ] Own application ID configured
* [ ] Own application name configured
* [ ] Own launcher icon installed
* [ ] Splash/launch branding updated
* [ ] Own release keystore created
* [ ] `key.properties` configured locally
* [ ] Signing configuration enabled
* [ ] `key.properties` excluded from source distribution
* [ ] Keystore excluded from source distribution
* [ ] `flutter analyze` passes
* [ ] Automated tests pass
* [ ] Release APK tested
* [ ] Release AAB generated
* [ ] Release AAB validated
* [ ] Application identity checked
* [ ] POS and barcode workflow tested, if used

---

# 17. iOS Release Signing

iOS production distribution requires Apple's signing system.

You need:

* macOS
* Xcode
* Apple Developer account
* Appropriate Apple signing credentials

## Step 1 — Open the workspace

Open:

```text
ios/Runner.xcworkspace
```

in Xcode.

Do not use the wrong project/workspace if CocoaPods is part of the project.

## Step 2 — Select the Runner target

In Xcode:

```text
Runner
→ Runner target
→ Signing & Capabilities
```

Select your Apple Developer Team.

Set your Bundle Identifier.

Example:

```text
com.mycompany.mybusiness
```

## Step 3 — Configure signing

For a normal application release, Xcode can manage signing automatically when the appropriate Apple Developer account/team is configured.

Alternatively, configure manual signing if your Apple Developer distribution workflow requires it.

Use only your own:

* Apple Developer team
* Certificates
* Provisioning profiles
* Signing credentials

---

# 18. Test an iOS Release Build

After signing is configured, test the application on an appropriate iOS device.

You can build from the Flutter command line when the required Apple development environment is configured:

```bash
flutter build ios --release
```

For an App Store distribution package, Flutter can also create an IPA:

```bash
flutter build ipa --release
```

The generated files are placed under the Flutter build output directories.

Always test the release configuration before submission.

---

# 19. Archive and Publish Through Xcode

For App Store distribution:

1. Open `ios/Runner.xcworkspace`.
2. Select the `Runner` scheme.
3. Select an appropriate generic iOS device destination.
4. Choose **Product → Archive**.
5. Wait for the archive to complete.
6. Open Xcode Organizer.
7. Select the archive.
8. Choose the distribution workflow appropriate for your Apple Developer account.
9. Validate the archive.
10. Upload to App Store Connect.
11. Complete the App Store listing and review requirements.

Apple's requirements may change. Check the current App Store Connect and Xcode guidance before final submission.

---

# 20. iOS Release Checklist

* [ ] macOS available
* [ ] Xcode installed
* [ ] Apple Developer account configured
* [ ] Own Bundle Identifier configured
* [ ] Apple Team selected
* [ ] Own signing credentials configured
* [ ] AppIcon replaced
* [ ] Splash/launch branding reviewed
* [ ] Application name updated
* [ ] Release build tested
* [ ] POS workflow tested
* [ ] Physical scanner tested if required by the deployment
* [ ] Archive created
* [ ] Archive validated
* [ ] App Store Connect configuration completed

---

# 21. Flutter Web Release

To create a production Web build:

```powershell
flutter build web --release
```

The output is generated under:

```text
build/web/
```

Before deployment, review:

```text
web/index.html
web/manifest.json
web/icons/
```

Update application branding as described in:

```text
documentation/CUSTOMIZATION.md
```

Test the production Web build before deployment.

## Web deployment considerations

* Deploy the contents of the generated `build/web/` directory using a hosting configuration compatible with Flutter Web.
* Test the deployed build, not just the development server.
* Verify that local database persistence works after refreshing or reopening the application.
* If the production build requires specific web server headers or resources for SQLite WASM and Drift, preserve the deployment configuration required by the project.
* Confirm that browser security policies, caching, and hosting settings do not prevent the application from loading or persisting data.

Do not assume that a successful local build alone verifies production hosting behavior.

---

# 22. Backup and Restore

BizFlow provides backup and restore functionality using its local database.

Before a production deployment:

1. Configure your business information.
2. Add test products.
3. Create test transactions.
4. Create a backup.
5. Reset or otherwise clear the test data as appropriate.
6. Restore the backup.
7. Confirm the restored data.
8. Verify that the restored information remains available after restarting or refreshing the application, where applicable.

Do not use real customer or business data during initial product testing unless appropriate safeguards are in place.

Always create a backup before performing destructive operations on important business data.

---

# 23. Production Testing Checklist

Before publishing a customized application, test the following.

### Dashboard

* [ ] Dashboard loads
* [ ] Summary values are displayed correctly

### Products

* [ ] Add product
* [ ] Edit product
* [ ] Delete product
* [ ] Category management
* [ ] Stock quantities
* [ ] Barcode values can be saved and edited

### POS

* [ ] Add products to cart
* [ ] Change quantities
* [ ] Checkout
* [ ] Stock decreases correctly
* [ ] Submit a known barcode using typed input followed by Enter
* [ ] Confirm the matching product is added to the cart
* [ ] Test an unknown barcode
* [ ] Test ambiguous barcode matches where applicable
* [ ] Test repeated barcode submissions
* [ ] Verify cart quantity increases when stock allows
* [ ] Verify stock validation is enforced
* [ ] Verify barcode values containing leading zeros
* [ ] Test a compatible physical scanner if required

### Sales

* [ ] Sales history
* [ ] Sale details
* [ ] Sale cancellation
* [ ] Stock restoration behavior
* [ ] Historical sales remain accessible after product deletion
* [ ] Cancellation handles previously deleted products correctly

### Customers

* [ ] Customer creation
* [ ] Customer editing
* [ ] Customer balances

### Expenses

* [ ] Add expense
* [ ] Edit/delete expense
* [ ] Reports reflect expenses

### Inventory

* [ ] Stock movements
* [ ] Low-stock information
* [ ] Inventory quantities

### Reports

* [ ] Sales information
* [ ] Profit information
* [ ] Expense information
* [ ] Inventory information

### Settings

* [ ] Business name
* [ ] Business information
* [ ] Currency
* [ ] Theme

### Backup

* [ ] Backup
* [ ] Restore
* [ ] Data verification after restore

### Receipts

* [ ] Receipt generation
* [ ] Business information
* [ ] Currency
* [ ] PDF output

### General

* [ ] `flutter analyze` passes
* [ ] `flutter test` passes
* [ ] Light and dark themes tested
* [ ] Responsive layouts tested
* [ ] Target platform tested
* [ ] Production build tested

---

# 24. Troubleshooting

## `flutter pub get` fails

Run:

```powershell
flutter doctor
```

Check your Flutter/Dart installation and network connection.

Then retry:

```powershell
flutter pub get
```

If dependency resolution still fails, inspect the error message before changing package versions.

## Application does not start

Try:

```powershell
flutter clean
flutter pub get
flutter run
```

Check the terminal output for the actual error.

`flutter clean` removes generated build artifacts; it does not replace a diagnosis of the underlying problem.

## Android build fails

Run:

```powershell
flutter doctor
```

Then verify:

* Android SDK
* Java/JDK
* Android Gradle configuration
* Android SDK licenses
* Release signing configuration

For release signing errors, verify:

```text
android/key.properties
```

and the signing configuration in:

```text
android/app/build.gradle.kts
```

Never share private passwords or signing credentials when asking for help.

## iOS build fails

Verify:

* macOS
* Xcode
* Apple Developer account
* Bundle Identifier
* Team
* Signing certificates
* Provisioning profiles
* CocoaPods dependencies

Open:

```text
ios/Runner.xcworkspace
```

in Xcode and inspect the first reported build or signing error.

## Branding does not change

Search the source for the old value:

```powershell
Get-ChildItem lib -Recurse -File | Select-String -Pattern "BizFlow"
```

Also search platform files:

```powershell
Get-ChildItem android -Recurse -File | Select-String -Pattern "BizFlow"
```

And:

```powershell
Get-ChildItem ios -Recurse -File | Select-String -Pattern "BizFlow"
```

Review each result before changing it. Not every occurrence of `BizFlow` should necessarily be replaced; some may be internal identifiers, documentation, or historical references.

## Barcode scanning does not work

Check the following:

1. Confirm the product has a barcode saved in its product information.
2. Confirm the submitted barcode exactly matches the stored barcode.
3. In Flutter Web, try typing the barcode into the POS search field and pressing Enter.
4. Confirm the scanner submits Enter after the barcode.
5. Test a barcode without leading zeros and one with leading zeros, where applicable.
6. Check the displayed feedback for unknown or ambiguous matches.
7. Confirm the product has sufficient stock.
8. Test a physical scanner on the intended device and browser.
9. Inspect the application output if the issue persists.

Some scanners can be configured to append Tab or another suffix instead of Enter. Configure the scanner appropriately or customize the input workflow for the hardware being used.

Do not assume every scanner, mobile camera, or Bluetooth device is supported automatically. The documented workflow targets scanners that behave like a keyboard.

---

# 25. Final Release Procedure

Use this order for a production release:

1. Install dependencies.

2. Customize application identity.

3. Customize branding.

4. Configure business information.

5. Configure currency.

6. Review demo data.

7. Test the customized application.

8. Run:

   ```powershell
   flutter analyze
   ```

9. Run the automated tests:

   ```powershell
   flutter test
   ```

10. Configure Android release signing if releasing Android.

11. Configure iOS signing if releasing iOS.

12. Build the required release package.

13. Install and test the release build.

14. Verify application identity and branding.

15. Test barcode scanning if it is part of the intended deployment.

16. Prepare store assets.

17. Submit the application to the appropriate store.

---

# 26. Important Security Rules

Never distribute:

```text
android/key.properties
```

with real passwords.

Never distribute:

```text
*.jks
*.keystore
```

containing private release credentials.

Never commit private signing credentials to a public repository.

Never use another developer's signing credentials.

Never publish an application using another company's package or bundle identity without authorization.

Keep production credentials separate from the source-code template.

Back up signing credentials securely and restrict access to them.

---

# 27. Buyer Release Responsibility

The buyer is responsible for obtaining and maintaining:

* Android/Google Play developer accounts
* Apple Developer accounts
* Signing credentials
* Certificates
* Provisioning profiles
* Store listing information
* Store screenshots
* Application privacy and legal information
* Any third-party services they add
* Compliance with applicable store requirements
* Testing on the intended hardware and target platforms

BizFlow provides the editable Flutter source and configuration guidance. Production publishing requires the buyer's own platform accounts and credentials.

---

# 28. Final Pre-Publication Checklist

### Project

* [ ] `flutter pub get` succeeds
* [ ] `flutter analyze` succeeds
* [ ] Automated tests pass
* [ ] Customized application launches
* [ ] No unwanted BizFlow branding remains

### Android

* [ ] Application ID changed
* [ ] Application name changed
* [ ] Launcher icon replaced
* [ ] Splash/launch branding replaced
* [ ] Release signing configured
* [ ] Release APK tested
* [ ] Release AAB generated and validated

### iOS

* [ ] Bundle identifier changed
* [ ] Application name changed
* [ ] AppIcon replaced
* [ ] Launch branding reviewed
* [ ] Apple Team configured
* [ ] Release signing configured
* [ ] Archive tested and validated

### Web

* [ ] Web title updated
* [ ] Web manifest updated
* [ ] Web icons updated
* [ ] Release Web build tested
* [ ] Production hosting configuration verified
* [ ] Local database persistence verified after refresh/reopening

### Application

* [ ] Products tested
* [ ] Product deletion tested
* [ ] Historical sales tested
* [ ] POS tested
* [ ] Barcode workflow tested
* [ ] Repeated scans tested
* [ ] Stock validation tested
* [ ] Sales tested
* [ ] Inventory tested
* [ ] Customers tested
* [ ] Expenses tested
* [ ] Reports tested
* [ ] Backup/restore tested
* [ ] Receipts tested
* [ ] Currency tested
* [ ] Light/dark themes tested
* [ ] Responsive layouts tested

The customized application should only be published after the relevant platform release checklist has been completed.

---

# BizFlow

**Offline-first Flutter POS & Inventory Template**

A customizable Flutter foundation for small-business point-of-sale and inventory workflows.
