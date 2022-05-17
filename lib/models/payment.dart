import 'package:otis/models/payment_period.dart';

class Payment {
  final int paymentId;
  final double amount;
  final int ownerId;
  final DateTime paymentDate;
  final PaymentPeriod paymentPeriod;

  Payment(
      {required this.paymentId,
      required this.amount,
      required this.ownerId,
      required this.paymentDate,
      required this.paymentPeriod});
}
