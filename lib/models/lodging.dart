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

  @override
  String toString() {
    return 'Lodging{id: $id, description: $description, rent: $rent, type: $floor, occupantId: $occupantId}';
  }
}
