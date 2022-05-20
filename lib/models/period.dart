import 'package:otis/models/payment.dart';

/// This class represent the period of payment.
class Period {
  final int month;
  final int year;
  Payment? payment;

  Period({this.payment,required this.month, required this.year});

 /* PaymentPeriod.fromMap(Map<String, dynamic> map)
      : month = map['month'],
        year = map['year'];
  */
}
