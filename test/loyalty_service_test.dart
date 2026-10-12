import 'package:flutter_test/flutter_test.dart';

import 'package:bizflow/data/repositories/loyalty_repository.dart';

void main() {
  group('LoyaltyService tiers', () {
    test('assigns Bronze below the Silver threshold', () {
      expect(LoyaltyService.tierFor(0).name, 'Bronze');
      expect(LoyaltyService.tierFor(499).name, 'Bronze');
    });

    test('promotes correctly at each threshold', () {
      expect(LoyaltyService.tierFor(500).name, 'Silver');
      expect(LoyaltyService.tierFor(2000).name, 'Gold');
      expect(LoyaltyService.tierFor(5000).name, 'Platinum');
      expect(LoyaltyService.tierFor(999999).name, 'Platinum');
    });

    test('nextTierFor returns null at the top tier', () {
      expect(LoyaltyService.nextTierFor(0)?.name, 'Silver');
      expect(LoyaltyService.nextTierFor(500)?.name, 'Gold');
      expect(LoyaltyService.nextTierFor(5000), isNull);
    });
  });

  group('LoyaltyService progress', () {
    test('progress is 0 at a tier boundary and approaches 1 near the next', () {
      expect(LoyaltyService.progressToNextTier(0), 0.0);
      expect(LoyaltyService.progressToNextTier(250), closeTo(0.5, 0.001));
    });

    test('progress is complete at the highest tier', () {
      expect(LoyaltyService.progressToNextTier(5000), 1.0);
    });
  });

  group('LoyaltyService points', () {
    test('earns points at the base rate for a Bronze customer', () {
      final points = LoyaltyService.pointsEarned(
        100,
        earnRate: 1.0,
        currentPoints: 0,
      );
      expect(points, 100);
    });

    test('applies the tier multiplier for higher tiers', () {
      // Silver multiplier is 1.25 → floor(100 * 1 * 1.25) = 125
      final points = LoyaltyService.pointsEarned(
        100,
        earnRate: 1.0,
        currentPoints: 600,
      );
      expect(points, 125);
    });

    test('redeemValue converts points back to currency', () {
      expect(LoyaltyService.redeemValue(1000, redeemValue: 0.01), 10.0);
    });
  });
}
