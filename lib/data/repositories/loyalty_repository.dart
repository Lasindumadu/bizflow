import 'package:drift/drift.dart';

import '../../core/session/session_authorization.dart';
import '../database/app_database.dart';

/// Loyalty tier definition derived purely from lifetime points.
class LoyaltyTier {
  final String name;
  final int minPoints;
  final double multiplier;

  const LoyaltyTier({
    required this.name,
    required this.minPoints,
    required this.multiplier,
  });
}

/// Business logic for the customer loyalty programme.
///
/// Tiers are computed from lifetime points so they never need to be
/// stored separately — but a cached tier string is kept on the customer
/// row for fast list rendering.
class LoyaltyService {
  static const List<LoyaltyTier> tiers = [
    LoyaltyTier(name: 'Bronze', minPoints: 0, multiplier: 1.0),
    LoyaltyTier(name: 'Silver', minPoints: 500, multiplier: 1.25),
    LoyaltyTier(name: 'Gold', minPoints: 2000, multiplier: 1.5),
    LoyaltyTier(name: 'Platinum', minPoints: 5000, multiplier: 2.0),
  ];

  static LoyaltyTier tierFor(int points) {
    LoyaltyTier current = tiers.first;
    for (final tier in tiers) {
      if (points >= tier.minPoints && tier.minPoints >= current.minPoints) {
        current = tier;
      }
    }
    return current;
  }

  /// The next tier above [points], or null if already at the top.
  static LoyaltyTier? nextTierFor(int points) {
    for (final tier in tiers) {
      if (points < tier.minPoints) {
        return tier;
      }
    }
    return null;
  }

  /// Progress (0..1) toward the next tier.
  static double progressToNextTier(int points) {
    final next = nextTierFor(points);
    if (next == null) return 1.0;
    final current = tierFor(points);
    final span = next.minPoints - current.minPoints;
    if (span <= 0) return 1.0;
    return ((points - current.minPoints) / span).clamp(0.0, 1.0);
  }

  /// Points earned for spending [amount] with the given earn rate,
  /// scaled by the customer's current tier multiplier.
  static int pointsEarned(
    double amount, {
    required double earnRate,
    required int currentPoints,
  }) {
    final multiplier = tierFor(currentPoints).multiplier;
    return (amount * earnRate * multiplier).floor();
  }

  /// Currency value of [points] at the configured redeem value.
  static double redeemValue(int points, {required double redeemValue}) {
    return points * redeemValue;
  }

  /// Points needed to cover [amount] of currency at the redeem value.
  static int pointsForAmount(double amount, {required double redeemValue}) {
    if (redeemValue <= 0) return 0;
    return (amount / redeemValue).ceil();
  }

  /// Whether [points] can be redeemed given the customer's [balance].
  static bool canRedeem(int points, {required int balance}) {
    return points > 0 && points <= balance;
  }
}

/// Repository for reading/writing customer loyalty points.
///
/// Two distinct values are tracked on each customer:
///  * [Customer.loyaltyPoints] — lifetime points earned (monotonic). This is
///    the ONLY input to tier calculation, so redeeming never demotes a tier.
///  * [Customer.pointsBalance] — spendable/redeemable balance.
class LoyaltyRepository {
  final AppDatabase database;

  LoyaltyRepository(this.database);

  /// Resolves the acting staff and enforces session validity for loyalty
  /// earning/redemption triggered through checkout. No role restriction —
  /// these are called within an already-authorized sale flow. The session
  /// choke point rejects locked sessions, deactivated accounts, and missing
  /// sessions when `loginRequired=true`. In login-disabled mode the
  /// null-staff actor from [resolveActor] is accepted.
  Future<ResolvedActor> _authorizeLoyaltySession() async {
    return resolveActor(database);
  }

  /// Resolves the acting staff and enforces owner-only authorization for
  /// manual loyalty point adjustments (admin corrections that bypass normal
  /// sale/redemption flows).
  Future<ResolvedActor> _authorizeLoyaltyAdjustment() async {
    final actor = await resolveActor(database);
    requireRole(
      actor.staff,
      {StaffRole.owner},
      'loyalty adjustment',
    );
    return actor;
  }

  /// Total spendable points currently held across all customers.
  Future<int> totalPointsIssued() async {
    final rows = await database.select(database.customers).get();
    return rows.fold<int>(0, (sum, c) => sum + c.pointsBalance);
  }

  /// Customers with the highest lifetime points (leaderboard).
  Future<List<Customer>> topCustomers({int limit = 5}) async {
    final query = database.select(database.customers)
      ..orderBy([(t) => OrderingTerm.desc(t.loyaltyPoints)])
      ..limit(limit);
    return query.get();
  }

  /// Awards [points] for a completed sale. Raises BOTH the lifetime total and
  /// the spendable balance, then refreshes the cached tier from lifetime
  /// points only.
  Future<void> earnPoints(String customerId, int points) async {
    await _authorizeLoyaltySession();
    if (points <= 0) return;

    final customer = await (database.select(
      database.customers,
    )..where((t) => t.id.equals(customerId))).getSingleOrNull();

    if (customer == null) return;

    final newLifetime = customer.loyaltyPoints + points;
    final newBalance = customer.pointsBalance + points;
    final tier = LoyaltyService.tierFor(newLifetime).name;

    await (database.update(
      database.customers,
    )..where((t) => t.id.equals(customerId))).write(
      CustomersCompanion(
        loyaltyPoints: Value(newLifetime),
        pointsBalance: Value(newBalance),
        loyaltyTier: Value(tier),
      ),
    );
  }

  /// Redeems [points] from the spendable balance. Lifetime points and tier
  /// are intentionally left untouched. Throws when the request is invalid
  /// or exceeds the available balance.
  Future<void> redeemPoints(String customerId, int points) async {
    await _authorizeLoyaltySession();
    if (points <= 0) {
      throw ArgumentError('Points to redeem must be greater than zero.');
    }

    final customer = await (database.select(
      database.customers,
    )..where((t) => t.id.equals(customerId))).getSingleOrNull();

    if (customer == null) {
      throw StateError('Customer not found.');
    }

    if (points > customer.pointsBalance) {
      throw StateError(
        'Not enough points. Available balance: ${customer.pointsBalance}.',
      );
    }

    await (database.update(
      database.customers,
    )..where((t) => t.id.equals(customerId))).write(
      CustomersCompanion(pointsBalance: Value(customer.pointsBalance - points)),
    );
  }

  /// Manual adjustment (e.g. admin correction). Positive [delta] also raises
  /// the lifetime total; a negative [delta] only lowers the spendable balance
  /// so tiers are never affected.
  Future<void> adjustPoints(String customerId, int delta) async {
    await _authorizeLoyaltyAdjustment();
    if (delta >= 0) {
      await earnPoints(customerId, delta);
    } else {
      await redeemPoints(customerId, -delta);
    }
  }

  /// Recomputes and stores the tier for every customer (used after import).
  /// Requires a valid session (rejects locked sessions, deactivated accounts,
  /// and missing sessions when loginRequired=true). In login-disabled mode
  /// the null-staff actor is accepted, preserving legacy behavior.
  Future<void> refreshTiers() async {
    await _authorizeLoyaltySession();
    final rows = await database.select(database.customers).get();
    for (final row in rows) {
      final tier = LoyaltyService.tierFor(row.loyaltyPoints).name;
      if (tier != row.loyaltyTier) {
        await (database.update(database.customers)
              ..where((t) => t.id.equals(row.id)))
            .write(CustomersCompanion(loyaltyTier: Value(tier)));
      }
    }
  }
}
