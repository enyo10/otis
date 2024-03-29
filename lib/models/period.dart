import 'package:otis/models/payment.dart';

/// This class represent the period of payment.
class Period {
  final int month;
  final int year;
  List<dynamic> payments = [];

  Period({required this.month, required this.year});

  Period.fromMap(Map<String, dynamic> map)
      : month = map['month'],
        year = map['year'];

  void addPayment(Payment payment) => payments.add(payment);

  @override
  String toString() {
    return month < 10 ? '0$month/$year' : '0$month/$year';
  }
}
