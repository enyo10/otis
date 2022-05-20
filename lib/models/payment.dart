import 'package:otis/models/period.dart';

class Payment {
  final int paymentId;
  final double amount;
  final int ownerId;
  final DateTime paymentDate;
  final Period paymentPeriod;

  Payment(
      {required this.paymentId,
      required this.amount,
      required this.ownerId,
      required this.paymentDate,
      required this.paymentPeriod});

  Payment.fromMap(Map<String, dynamic> map)
      : paymentId = map['id'],
        ownerId = map['owner_id'],
        paymentDate = DateTime.parse(map['payment_date']),
        paymentPeriod = Period(month: map['month'], year: map['year']),
        amount = map['amount'];
}
