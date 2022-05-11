import 'package:otis/models/payment.dart';

class Occupant {
  final int id;
  final int lodgingId;
  final String firstname;
  final String lastname;
  final DateTime entryDate;
  DateTime? releaseDate;
  final List<Payment> payments = [];

  Occupant(
      {required this.id, required this.lodgingId,
      required this.firstname,
      required this.lastname,
      required this.entryDate});

  void terminateLease(int year, int month) {
    releaseDate = DateTime(year = year, month = month);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lodging_id':lodgingId,
      'firstname': firstname,
      'lastname': lastname,
      'entry_data':entryDate.toIso8601String()
    };
  }
}


