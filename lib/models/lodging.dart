class Lodging {
  final int id;
  String address;
  String description;
  double rent;
  int type;
  int? occupantId;

  Lodging(
      {this.occupantId,
      required this.id,
      required this.address,
      required this.description,
      required this.rent,
      required this.type});

  @override
  String toString() {
    return 'Lodging{id: $id, address: $address, description: $description, rent: $rent, type: $type, occupantId: $occupantId}';
  }
}
