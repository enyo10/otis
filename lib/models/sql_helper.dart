import 'package:flutter/foundation.dart';
import 'package:otis/models/payment_period.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';

class SQLHelper {
  static const String _apartments = "apartments";
  static const String _occupants = "occupants";
  static const String _payments = "payments";
  static const String _periods = "periods";
  static const String _livingQuarter = "living_quarter";
  static const String _building = "building";

  static Future<void> _onCreateTables(sql.Database database) async {
    await database.execute("""CREATE TABLE $_livingQuarter(
     id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
     name TEXT,
     color TEXT  )
    """);
    await database.execute("""CREATE TABLE $_building(
     id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
     name TEXT,
     color TEXT,
     quarter_id INTEGER,
      FOREIGN KEY (quarter_id)
        REFERENCES $_livingQuarter (id) 
        ON UPDATE CASCADE
        ON DELETE CASCADE  )
    """);

    await database.execute("""CREATE TABLE $_apartments(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        type INTEGER,
        occupant_id INTEGER,
        address Text,
        description TEXT,
        rent REAL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        building_id INTEGER,
         FOREIGN KEY (building_id)
          REFERENCES $_building (id) 
          ON UPDATE CASCADE
          ON DELETE CASCADE
        
        
      )
      """);
    await database.execute("""CREATE TABLE $_occupants( 
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
        firstname TEXT NOT NULL,
        lastname TEXT NOT NULL,
        entry_date TEXT NOT NULL,
        lodging_id INTEGER,
         FOREIGN KEY (lodging_id)
         REFERENCES $_apartments (id) 
         ON UPDATE CASCADE
         ON DELETE CASCADE )
         
        """);
    await database.execute("""CREATE TABLE $_payments(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    owner_id INTEGER,
    amount REAL,
    payment_date TEXT
    ) """);
    await database.execute("""CREATE TABLE $_periods(
     id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL
   )
    """);
  }

  static Future _onConfigure(sql.Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      join(await sql.getDatabasesPath(), 'otis.db'),
      version: 1,
      onConfigure: _onConfigure,
      onCreate: (sql.Database database, int version) async {
        await _onCreateTables(database);
      },
    );
  }

  // Create new apartment(journal)
  static Future<int> insertApartment(
      int type,int buildingId, String address, String? description, double rent) async {
    final db = await SQLHelper.db();

    final data = {
      'type': type,
      'building_id':buildingId,
      'address': address,
      'description': description,
      'rent': rent
    };
    final id = await db.insert(_apartments, data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getApartments(
      int buildingId) async {
    final db = await SQLHelper.db();
    return db.query(_apartments,
        where: "building_id = ?", whereArgs: [buildingId], orderBy: "id");
  }

  // Read a single apartment by id
  // The app doesn't use this method but I put here in case you want to see it
  static Future<List<Map<String, dynamic>>> getApartment(int id) async {
    final db = await SQLHelper.db();
    return db.query(_apartments, where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Update an apartment by id
  static Future<int> updateApartment(
      int id, int type, double rent, String title, String? description) async {
    final db = await SQLHelper.db();

    final data = {
      'type': type,
      'address': title,
      'rent': rent,
      'description': description,
      'createdAt': DateTime.now().toString()
    };

    final result =
        await db.update(_apartments, data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete
  static Future<void> deleteApartment(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete(_apartments, where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an apartment: $err");
    }
  }

  static Future<int> insertOccupant(String firstname, String lastname,
      String entryDate, int lodgingId) async {
    final db = await SQLHelper.db();

    final data = {
      'firstname': firstname,
      'lastname': lastname,
      'entry_date': entryDate,
      'lodging_id': lodgingId
    };
    final id = await db.insert(_occupants, data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<int> insertPayment(int ownerId, double amount,
      DateTime paymentDate, PaymentPeriod periodOfPayment) async {
    final db = await SQLHelper.db();

    final data = {'ownerId': ownerId, 'amount': amount};
    final id = await db.insert(_payments, data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getOccupants() async {
    final db = await SQLHelper.db();
    return db.query(_occupants, orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getOccupantsWithLodgingId(
      int lodgingId) async {
    final db = await SQLHelper.db();
    return db.query(_occupants,
        where: "lodging_id = ?", whereArgs: [lodgingId], limit: 1);
  }

  static Future<List<Map<String, dynamic>>> getLivingQuarters() async {
    final db = await SQLHelper.db();
    return db.query(_livingQuarter, orderBy: "id");
  }

  static Future<int> insertLivingQuarter(
      String quarterName, String color) async {
    final db = await SQLHelper.db();

    final data = {'name': quarterName, 'color': color};

    final id = await db.insert(_livingQuarter, data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    if (kDebugMode) {
      print(" Quarter with $id inserted");
    }
    return id;
  }

  static Future<int> insertBuilding(
      String buildingName, String color, int quarterId) async {
    final db = await SQLHelper.db();

    final data = {
      'name': buildingName,
      'color': color,
      'quarter_id': quarterId
    };

    final id = await db.insert(_building, data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    if (kDebugMode) {
      print(" Building with $id inserted");
    }
    return id;
  }

  static Future<List<Map<String, dynamic>>> getBuildings(int quarterId) async {
    final db = await SQLHelper.db();
    return db.query(_building,
        where: "quarter_id = ?", whereArgs: [quarterId], orderBy: "id");
  }
}
