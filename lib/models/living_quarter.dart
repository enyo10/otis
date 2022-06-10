class LivingQuarter {
  final int id;
  final String name;
  final String description;
  final String colorName;

  LivingQuarter(
      {required this.id,
      required this.name,
      required this.description,
      required this.colorName});

  LivingQuarter.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        colorName = map['color'],
        description = map['desc'] ?? '',
        name = map['name'] ?? '';
}
