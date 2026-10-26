import 'package:drift/drift.dart';

class BusinessSettings extends Table {
  TextColumn get id => text()();

  TextColumn get businessName =>
      text().withDefault(const Constant('My Business'))();

  TextColumn get address => text().withDefault(const Constant(''))();

  TextColumn get phone => text().withDefault(const Constant(''))();

  TextColumn get email => text().withDefault(const Constant(''))();

  TextColumn get currency => text().withDefault(const Constant('USD'))();

  /// Loyalty programme settings.
  BoolColumn get loyaltyEnabled =>
      boolean().withDefault(const Constant(true))();

  /// Points earned per unit of currency spent (e.g. 1 point per 1.0).
  RealColumn get loyaltyEarnRate =>
      real().withDefault(const Constant(1.0))();

  /// Currency value of a single point when redeemed.
  RealColumn get loyaltyRedeemValue =>
      real().withDefault(const Constant(0.01))();

  /// Receipt branding: text shown as the receipt header line.
  TextColumn get receiptHeader =>
      text().withDefault(const Constant('Thank you for your purchase!'))();

  /// Receipt branding: footer note (returns policy, contact, etc.).
  TextColumn get receiptFooter =>
      text().withDefault(const Constant(''))();

  /// Whether to print the business phone on the receipt.
  BoolColumn get receiptShowPhone =>
      boolean().withDefault(const Constant(true))();

  /// Whether to print the business address on the receipt.
  BoolColumn get receiptShowAddress =>
      boolean().withDefault(const Constant(true))();

  /// Optional note printed under the receipt total (e.g. tax info).
  TextColumn get receiptNote =>
      text().withDefault(const Constant(''))();

  /// Phase D: when true, the startup gate requires staff PIN login before
  /// the app shell is shown. Defaults to false so existing installations
  /// keep today's no-login behavior after the v13 migration.
  BoolColumn get loginRequired =>
      boolean().withDefault(const Constant(false))();

  /// Phase F: inactivity auto-lock timeout in minutes. `0` means the
  /// inactivity lock is disabled. When non-zero and the session is
  /// authenticated, the app shell locks the session after this many minutes
  /// of no user activity, requiring PIN re-entry via [SessionController.unlock].
  /// Defaults to 0 (off) so existing installations keep today's behavior.
  IntColumn get inactivityTimeoutMinutes =>
      integer().withDefault(const Constant(0))();

  /// Phase G: tax / VAT rate (e.g. 15.0 for 15%).
  RealColumn get taxRate => real().withDefault(const Constant(0.0))();

  /// When true, prices entered in the POS already include tax.
  BoolColumn get taxInclusive =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
