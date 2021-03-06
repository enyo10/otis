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
      {required this.id,
      required this.lodgingId,
      required this.firstname,
      required this.lastname,
      required this.entryDate});

  void terminateLease(int year, int month) {
    releaseDate = DateTime(year = year, month = month);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lodging_id': lodgingId,
      'firstname': firstname,
      'lastname': lastname,
      'entry_data': entryDate.toIso8601String(),
      'release_date': releaseDate?.toIso8601String()
    };
  }

  Occupant.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        lodgingId = map['lodging_id'],
        firstname = map['firstname'],
        lastname = map['lastname'],
        entryDate = DateTime.parse(map['entry_date']),
        releaseDate = map['release_date']!=null? DateTime.parse(map['release_date']):null;
}
