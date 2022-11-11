import 'package:otis/models/rent_period.dart';

class Lodging {
  final int id;
  String description;
  String address;
  double rent;
  int floor;
  int? occupantId;

  Lodging(
      {this.occupantId,
      required this.id,
      required this.description,
      required this.address,
      required this.rent,
      required this.floor});

  Lodging.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        description = map['description'],
        address = map['address'],
        rent = map['rent'],
        floor = map['floor'],
        occupantId = map['occupant_id'];

  /// This method to retrieve the actual rent.
 /* Rent rent(int year, int month) {
    var date = DateTime(year, month);
    for (Rent rent in rents) {
      if (rent.endDate == null) {
        if (date.isAfter(rent.startDate)) {
          return rent;
        }
      }
      if (date.isAfter(rent.startDate) && date.isBefore(rent.endDate!)) {
        return rent;
      }
    }

    return rents.first;
  }

  void modifyRent(Rent rent) {
    if (rents.isEmpty) {
      rents.add(rent);
      return;
    }
    for (Rent r in rents) {
      if (r.endDate == null) {
        r.endDate = rent.startDate;
        rents.add(rent);
        return;
      }
    }
  }

  Rent getActualRent() {
    Rent rent = rents.first;
    for (Rent r in rents) {
      if (r.endDate == null) {
        rent = r;
      }
    }
    return rent;
  }
*/

  @override
  String toString() {
    return 'Lodging{id: $id, description: $description, rent: $rent, type: $floor, occupantId: $occupantId}';
  }
}
