class Rent {
  int? id;
  final int lodgingId;
  final DateTime startDate;
  final DateTime? endDate;
  final double rent;

  Rent(
      {this.id,
      required this.lodgingId,
      required this.startDate,
      this.endDate,
      required this.rent});

  Rent.formMap(Map<String, dynamic> map)
      : id = map['id'],
        rent = map['rent'],
        lodgingId = map['lodging_id'],
        startDate = DateTime.parse(map['start_date']),
        endDate =
            map['end_date'] != null ? DateTime.parse(map['end_date']) : null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rent': rent,
      'lodging_id': lodgingId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }
}
