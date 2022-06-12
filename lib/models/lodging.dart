class Lodging {
  final int id;
  String description;
  String address;
  double rent;
  int level;
  int? occupantId;

  Lodging(
      {this.occupantId,
      required this.id,
      required this.description,
      required this.address,
      required this.rent,
      required this.level});

  @override
  String toString() {
    return 'Lodging{id: $id, description: $description, rent: $rent, type: $level, occupantId: $occupantId}';
  }
}
