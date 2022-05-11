
import 'package:otis/models/payment.dart';

class PaymentPeriod {
  final int id;
  final int month;
  final int year;
  Payment? payment;

   PaymentPeriod({required this.id, required this.month, required this.year});


}