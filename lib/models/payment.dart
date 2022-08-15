import 'package:otis/models/period.dart';

class Payment {
  final int paymentId;
  final double amount;
  final int ownerId;
  final DateTime paymentDate;
  final Period paymentPeriod;
  final String currency;
  final double rate;
   final String desc;

  Payment(
      {required this.paymentId,
      required this.amount,
      required this.rate,
      required this.ownerId,
      required this.paymentDate,
      required this.currency,
      required this.paymentPeriod,
      required this.desc});

  Payment.fromMap(Map<String, dynamic> map)
      : paymentId = map['id'],
        ownerId = map['owner_id'],
        paymentDate = DateTime.parse(map['payment_date']),
        paymentPeriod = Period(month: map['month'], year: map['year']),
        amount = map['amount'],
        rate = map['rate'],
        currency = map['currency'],
        desc = map['desc']?? '';

  String stringValue() {
    return '${paymentPeriod.toString()}, $amount, $currency,';
  }

  @override
  String toString() {
    return 'Payment{paymentId: $paymentId, amount: $amount, ownerId: $ownerId, paymentDate: $paymentDate, paymentPeriod: $paymentPeriod, currency: $currency}';
  }
}
