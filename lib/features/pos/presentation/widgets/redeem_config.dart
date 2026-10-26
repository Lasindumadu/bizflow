/// Small value object holding the data needed by the checkout redemption
/// control: the customer's spendable balance and the configured point value.
class RedeemConfig {
  final int balance;
  final double redeemValue;

  const RedeemConfig({required this.balance, required this.redeemValue});
}
