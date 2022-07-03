import 'dart:async';
import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var p = join(await getDatabasesPath(), 'doggie_database.db');
  //await  deleteDatabase(p);

  final database = openDatabase(
    join(await getDatabasesPath(), 'doggie_database.db'),
    version: 1,
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)',
      );
    },
    // version: 1,
  );
  //_initDB();

  // var database = openDB();

  Future<void> insertDog(Dog dog) async {
    final db = await database;

    await db.insert(
      'dogs',
      dog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Dog>> dogs() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('dogs');

    return List.generate(maps.length, (i) {
      return Dog(
        id: maps[i]['id'],
        name: maps[i]['name'],
        age: maps[i]['age'],
      );
    });
  }

  Future<void> updateDog(Dog dog) async {
    final db = await database;

    await db.update(
      'dogs',
      dog.toMap(),
      where: 'id = ?',
      whereArgs: [dog.id],
    );
  }

  Future<void> deleteDog(int id) async {
    final db = await database;

    await db.delete(
      'dogs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  var fido = Dog(
    id: 0,
    name: 'Fido',
    age: 35,
  );

  await insertDog(fido);

  print(await dogs());

  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String copyToPath = join(documentsDirectory.path, 'doggie_database.db');
  var f = await File(p).copy(copyToPath);
  print("after copy : ${f.path}");

  fido = Dog(
    id: fido.id,
    name: fido.name,
    age: fido.age + 7,
  );
  await updateDog(fido);

  print(await dogs());

  // await deleteDog(fido.id);

  print(await dogs());

  print(await File(p).length());
  Directory documentsDirectory1 = await getApplicationDocumentsDirectory();
  Directory? libraryDirectory = await getLibraryDirectory();
  print(" library directory : ${libraryDirectory.path}");
  //print(downloadDirectory!.path);
  String copyToPath1 = join(libraryDirectory.path, 'doggie_database.db');
  var copy = await File(p).copy(copyToPath1);
  print(copy.path);
}

class Dog {
  final int id;
  final String name;
  final int age;

  Dog({
    required this.id,
    required this.name,
    required this.age,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
    };
  }

  @override
  String toString() {
    return 'Dog{id: $id, name: $name, age: $age}';
  }
}

Future<void> _initDB() async {
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String newPath = join(documentsDirectory.path, 'doggie_database.db');
  final exists = await databaseExists(newPath);
  if (!exists) {
    try {
      final dbPath = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOCUMENTS);
      final path = join(dbPath, 'doggie_database.db');
      File(path).copySync(newPath);
    } catch (_) {}
  }
}

Future<Database> openDB() async {
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String path = join(documentsDirectory.path, 'doggie_database.db');
  await _initDB();
  Database db = await openDatabase(path);
  return db;
}

/*class DatabaseHelper {
  final String _databaseName = "my_data_base.db";
  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)',
    );
  }
}*/
