import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Sqflite DB backup/Restore'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String message = '';

 late String _dataBasePath;


  @override
  void initState() {
    super.initState();
    _getDataBasePath();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(message),
            ElevatedButton(
              onPressed: () async {
                final dbFolder = await getDatabasesPath();
                File source1 = File('$dbFolder/doggie_database.db');

                Directory? copyTo  = await getDownloadsDirectory();

               // Directory("storage/emulated/0/Sqlite Backup");
                if ((await copyTo!.exists())) {
                  // print("Path exist");
                  var status = await Permission.storage.status;
                  if (!status.isGranted) {
                    await Permission.storage.request();
                  }
                } else {
                  print("not exist");
                  if (await Permission.storage.request().isGranted) {
                    // Either the permission was already granted before or the user just granted it.
                    await copyTo.create();
                  } else {
                    print('Please give permission');
                  }
                }

                String newPath = "${copyTo.path}/doggie_database.db";
                await source1.copy(newPath);

                setState(() {
                  message = 'Successfully Copied DB';
                });
              },
              child: const Text('Copy DB'),
            ),
            ElevatedButton(
              onPressed: () async {
                var databasesPath = await getDatabasesPath();
                var dbPath = join(databasesPath, 'doggie_database.db');
                await deleteDatabase(dbPath);
                setState(() {
                  message = 'Successfully deleted DB';
                });
              },
              child: const Text('Delete DB'),
            ),
            ElevatedButton(
              onPressed: () async {
                var databasesPath = await getDatabasesPath();
                var dbPath = join(databasesPath, 'doggie_database.db');

                FilePickerResult? result =
                await FilePicker.platform.pickFiles();

                if (result != null) {
                  File source = File(result.files.single.path!);
                  await source.copy(dbPath);
                  setState(() {
                    message = 'Successfully Restored DB';
                  });
                } else {
                  // User canceled the picker

                }
              },
              child: const Text('Restore DB'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getDataBasePath() async {
    String path;
    path = await getDatabasesPath();

    getApplicationDocumentsDirectory().then((value) {
      if (kDebugMode) {
        print(" App Doc dir: ${value.path}");
      }
    });

    setState(() {
      _dataBasePath = path;
    });
    if (kDebugMode) {
      print("DataBase path $_dataBasePath");
    }
  }

  Future<void> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String newPath = join(documentsDirectory.path, '/backup.db');
    final exists = await databaseExists(newPath);
    if (!exists) {
      try {

        final dbPath = await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_DOCUMENTS);
        final path = join(dbPath, '/backup.db');
        File(path).copySync(newPath);
      } catch (_) {}
    }
  }

  Future<Database> openDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, '/backup.db');
    await _initDB();
    Database db = await openDatabase(path);
    return db;
  }

}