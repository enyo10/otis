class Building {
  final int id;
  final String name;
  final int quarterId;
  final String colorName;

  Building(
      {required this.id,
      required this.quarterId,
      required this.name,
      required this.colorName});

  Building.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        quarterId = map['quarter_id'],
        colorName = map['color'];
}
