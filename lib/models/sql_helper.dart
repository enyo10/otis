import 'package:flutter/foundation.dart';
import 'package:otis/models/period.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLHelper {
  static const String _livingQuarters = "living_quarters";
  static const String _buildings = "buildings";
  static const String _apartments = "apartments";
  static const String _occupants = "occupants";
  static const String _payments = "payments";
  static const String _rents = "rents";

  static Future<void> _onCreateTables(Database database) async {
    await database.execute("""CREATE TABLE $_livingQuarters(
     id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
     name TEXT,
     desc TEXT,
     color TEXT  )
    """);

    await database.execute("""CREATE TABLE $_buildings(
     id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
     name TEXT,
     desc TEXT,
     color TEXT,
     quarter_id INTEGER,
      FOREIGN KEY (quarter_id)
        REFERENCES $_livingQuarters (id) 
        ON UPDATE CASCADE
        ON DELETE CASCADE  )
    """);

    await database.execute("""CREATE TABLE $_apartments(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        floor INTEGER,
        occupant_id INTEGER,
        address Text,
        description TEXT,
        rent REAL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        building_id INTEGER,
         FOREIGN KEY (building_id)
          REFERENCES $_buildings (id) 
          ON UPDATE CASCADE
          ON DELETE CASCADE )
      """);

    await database.execute("""CREATE TABLE $_rents(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    rent REAL,
    start_date TEXT NOT NULL,
    lodging_id INTEGER NOT NULL,
    FOREIGN KEY (lodging_id)
    REFERENCES $_apartments (id)
    ON UPDATE CASCADE
    ON DELETE CASCADE)
    """);

    await database.execute("""CREATE TABLE $_occupants( 
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
        firstname TEXT NOT NULL,
        lastname TEXT NOT NULL,
        entry_date TEXT NOT NULL,
        release_date TEXT,
        lodging_id INTEGER,
         FOREIGN KEY (lodging_id)
         REFERENCES $_apartments (id) 
         ON UPDATE CASCADE
         ON DELETE CASCADE )
         
        """);

    await database.execute("""CREATE TABLE $_payments(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    amount REAL,
    currency TEXT,
    rate REAL,
    payment_date TEXT,
    year INTEGER,
    month INTEGER,
    owner_id INTEGER,
    FOREIGN KEY(owner_id)
    REFERENCES $_occupants (id) 
         ON UPDATE CASCADE
         ON DELETE CASCADE ) 
    """);
  }

  static Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static Future<Database> db() async {

    return openDatabase(
      join(await getDatabasesPath(), 'otis.db'),
      version: 1,
      onConfigure: _onConfigure,
      onCreate: (Database database, int version) async {
        await _onCreateTables(database);
      },
    );
  }

  /*
   LiVing Quarter
    */
  static Future<List<Map<String, dynamic>>> getLivingQuarters() async {
    final db = await SQLHelper.db();
    return db.query(_livingQuarters, orderBy: "id");
  }

  static Future<int> insertLivingQuarter(
      String quarterName, String desc, String color) async {
    final db = await SQLHelper.db();

    final data = {'name': quarterName, 'desc': desc, 'color': color};

    final id = await db.insert(_livingQuarters, data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    if (kDebugMode) {
      print(" Quarter with $id inserted");
    }
    return id;
  }

  /*
                          BUILDING
   */
  static Future<int> insertBuilding(
      String buildingName, String desc, String color, int quarterId) async {
    final db = await SQLHelper.db();

    final data = {
      'name': buildingName,
      'desc': desc,
      'color': color,
      'quarter_id': quarterId
    };

    final id = await db.insert(_buildings, data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    if (kDebugMode) {
      print(" Building with $id inserted");
    }
    return id;
  }

  static Future<List<Map<String, dynamic>>> getBuildings(int quarterId) async {
    final db = await SQLHelper.db();
    return db.query(_buildings,
        where: "quarter_id = ?", whereArgs: [quarterId], orderBy: "id");
  }

  // Create new apartment(journal)
  static Future<int> insertApartment(int floor, int buildingId, String address,
      String? description, double rent) async {
    final db = await SQLHelper.db();

    final data = {
      'floor': floor,
      'building_id': buildingId,
      'address': address,
      'description': description,
      'rent': rent
    };
    final id = await db.insert(_apartments, data,
        conflictAlgorithm: ConflictAlgorithm.replace);
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
  static Future<int> updateApartment(int id, int floor, double rent,
      String title, String? description, int? occupantId) async {
    final db = await SQLHelper.db();

    final data = {
      'floor': floor,
      'address': title,
      'rent': rent,
      'description': description,
      'occupant_id': occupantId,
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
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getOccupants() async {
    final db = await SQLHelper.db();
    return db.query(_occupants, orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getOccupantById(
      int occupantId, int lodgingId) async {
    final db = await SQLHelper.db();
    return db.query(_occupants,
        where: "id =? AND lodging_id= ?", whereArgs: [occupantId, lodgingId]);
  }

  static Future<int> updateOccupant(int id) async {
    final db = await SQLHelper.db();
    var releaseDate = DateTime.now();
    final data = {
      "release_date": releaseDate.toIso8601String(),
    };

    final result =
        db.update(_occupants, data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<int> insertPayment(
      int ownerId,
      double amount,
      DateTime paymentDate,
      Period periodOfPayment,
      String currency,
      double rate) async {
    final db = await SQLHelper.db();

    final data = {
      'owner_id': ownerId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String(),
      'year': periodOfPayment.year,
      'month': periodOfPayment.month,
      'currency': currency,
      'rate': rate
    };
    final id = await db.insert(_payments, data,
        conflictAlgorithm: ConflictAlgorithm.replace);

    return id;
  }

  static Future<List<Map<String, dynamic>>> getCurrentYearPayment(
      int ownerId) async {
    var year = DateTime.now().year;
    final db = await SQLHelper.db();
    return db.query(_payments,
        where: "owner_id =? AND year= ?", whereArgs: [ownerId, year]);
  }

  static Future<List<Map<String, dynamic>>> getPayments(int ownerId) async {
    final db = await SQLHelper.db();
    return db.query(_payments, where: "owner_id=?", whereArgs: [ownerId]);
  }

  static Future<List<Map<String, dynamic>>> getPeriodPayments(
      int ownerId, int year, int month) async {
    final db = await SQLHelper.db();
    return db.query(_payments,
        where: "owner_id =? AND year =? AND month=?",
        whereArgs: [ownerId, year, month]);
  }

  static Future<List<Map<String, dynamic>>> getOccupantsWithLodgingId(
      int lodgingId) async {
    final db = await SQLHelper.db();
    return db.query(_occupants,
        where: "lodging_id = ?", whereArgs: [lodgingId], limit: 1);
  }

  static Future<int> insertRent(
      int lodgingId, DateTime from, double rent) async {
    final db = await SQLHelper.db();

    final data = {
      'lodging_id': lodgingId,
      'start_date': from.toIso8601String(),
      'rent': rent,
    };

    final id = await db.insert(_rents, data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    if (kDebugMode) {
      print(" Rent with $id inserted");
    }
    return id;
  }

  static Future<List<Map<String, dynamic>>> getRents(int lodgingId) async {
    final db = await SQLHelper.db();
    return db.query(_rents,
        where: "lodging_id = ?", whereArgs: [lodgingId], orderBy: "id");
  }
}
