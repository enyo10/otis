class Note {
  final int id;
  final int ownerId;
  final String comment;

  Note(this.ownerId, {required this.id, required this.comment});

  Note.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        ownerId = map['owner_id'],
        comment = map['comment'];
}
