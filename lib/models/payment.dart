class Payment {
  final int paymentId;
  final double amount;
  final int ownerId;
  final DateTime paymentDate;

  Payment(
      {required this.paymentId,
        required this.amount,
        required this.ownerId,
        required this.paymentDate});
}