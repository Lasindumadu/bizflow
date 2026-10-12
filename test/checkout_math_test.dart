import 'package:flutter_test/flutter_test.dart';

import 'package:bizflow/data/repositories/loyalty_repository.dart';
import 'package:bizflow/features/pos/presentation/utils/checkout_helpers.dart';

/// End-to-end style coverage for checkout money math and the loyalty
/// redemption limits the checkout dialog enforces.
void main() {
  group('CheckoutHelpers.discountFor', () {
    test('returns 0 for non-positive subtotal or value', () {
      expect(CheckoutHelpers.discountFor(0, 10, false), 0);
      expect(CheckoutHelpers.discountFor(100, 0, false), 0);
      expect(CheckoutHelpers.discountFor(100, -5, false), 0);
    });

    test('amount mode never exceeds the subtotal', () {
      expect(CheckoutHelpers.discountFor(100, 40, false), 40);
      expect(
        CheckoutHelpers.discountFor(100, 500, false),
        100,
        reason: 'clamped to subtotal',
      );
    });

    test('percent mode is clamped to 0..100%', () {
      expect(CheckoutHelpers.discountFor(200, 10, true), 20);
      expect(
        CheckoutHelpers.discountFor(200, 150, true),
        200,
        reason: 'clamped to 100%',
      );
    });
  });

  group('checkout totals with discount + loyalty', () {
    // Mirrors the POS dialog math: total = subtotal - discount - loyaltyValue.
    double checkoutTotal({
      required double subtotal,
      double discount = 0,
      int redeemPoints = 0,
      double redeemValue = 0.01,
    }) {
      final loyalty = LoyaltyService.redeemValue(
        redeemPoints,
        redeemValue: redeemValue,
      );
      return (subtotal - discount - loyalty).clamp(0.0, double.infinity);
    }

    test('combines manual discount and loyalty discount', () {
      final total = checkoutTotal(
        subtotal: 100,
        discount: 10,
        redeemPoints: 500,
        redeemValue: 0.01, // 5.00
      );
      expect(total, closeTo(85.00, 0.0001));
    });

    test('total never goes negative when loyalty exceeds amount owed', () {
      final total = checkoutTotal(
        subtotal: 5,
        discount: 0,
        redeemPoints: 10000,
        redeemValue: 0.01, // 100.00 > 5.00 owed
      );
      expect(total, 0, reason: 'clamped at zero, never negative');
    });

    test('rounding stays stable at cent precision', () {
      // 3 × 33.33 = 99.99 subtotal.
      final total = checkoutTotal(
        subtotal: 99.99,
        discount: 0,
        redeemPoints: 333,
        redeemValue: 0.01, // 3.33
      );
      expect(total, closeTo(96.66, 0.0001));
    });

    test('zero redemption leaves the discounted total untouched', () {
      final total = checkoutTotal(subtotal: 250, discount: 25);
      expect(total, 225);
    });
  });

  group('loyalty redemption limits (business rules)', () {
    test('canRedeem is false for zero, negative or over-balance requests', () {
      expect(LoyaltyService.canRedeem(0, balance: 100), isFalse);
      expect(LoyaltyService.canRedeem(-10, balance: 100), isFalse);
      expect(LoyaltyService.canRedeem(150, balance: 100), isFalse);
    });

    test('canRedeem is true for a valid partial redemption', () {
      expect(LoyaltyService.canRedeem(50, balance: 100), isTrue);
      expect(LoyaltyService.canRedeem(100, balance: 100), isTrue);
    });

    test('pointsForAmount computes points to cover a currency amount', () {
      // To cover 5.00 at 0.01 per point → 500 points.
      expect(LoyaltyService.pointsForAmount(5.0, redeemValue: 0.01), 500);
      // Rounds up so the customer always covers the amount.
      expect(LoyaltyService.pointsForAmount(0.015, redeemValue: 0.01), 2);
      expect(LoyaltyService.pointsForAmount(5.0, redeemValue: 0), 0);
    });

    test('customer with enough points but owing less is capped by amount', () {
      const balance = 10000; // plenty of points (worth 100.00)
      const owed = 5.0; // only owes 5.00
      const redeemValue = 0.01;

      final byValue = LoyaltyService.pointsForAmount(
        owed,
        redeemValue: redeemValue,
      );
      final redeemable = byValue < balance ? byValue : balance;

      expect(redeemable, 500, reason: 'capped by the amount owed, not balance');
      expect(LoyaltyService.canRedeem(redeemable, balance: balance), isTrue);
    });
  });
}
