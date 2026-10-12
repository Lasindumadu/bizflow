import 'package:drift/drift.dart';

class Customers extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get phone => text().withDefault(const Constant(''))();

  TextColumn get email => text().withDefault(const Constant(''))();

  TextColumn get address => text().withDefault(const Constant(''))();

  RealColumn get outstandingBalance =>
      real().withDefault(const Constant(0.0))();

  /// Loyalty programme — lifetime points EARNED by this customer.
  /// This value is monotonic (only ever grows) and is the sole source
  /// for tier calculation, so redeeming points never demotes a tier.
  IntColumn get loyaltyPoints => integer().withDefault(const Constant(0))();

  /// Loyalty programme — spendable (redeemable) point balance.
  /// Earned points raise this; redeeming points lowers it. It never
  /// affects [loyaltyTier].
  IntColumn get pointsBalance => integer().withDefault(const Constant(0))();

  /// Cached tier name derived from [loyaltyPoints] (kept for fast display).
  TextColumn get loyaltyTier =>
      text().withDefault(const Constant('Bronze'))();

  @override
  Set<Column> get primaryKey => {id};
}
