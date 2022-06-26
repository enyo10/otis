import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart' as sql;

class ShareData extends StatefulWidget {
  const ShareData({Key? key}) : super(key: key);

  @override
  State<ShareData> createState() => _ShareDataState();
}

class _ShareDataState extends State<ShareData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: ElevatedButton(
                    onPressed: () async {
                      await copyDBToStorage();
                    },
                    child: const Text("Partager DB")),
              ),
              ElevatedButton(
                  onPressed: () {
                    _pickFile();
                  },
                  child: const Text("Pick File")),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _exPath = [];
  late String _dbPath;
  late String _download;
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    getPath();
    getDBPath();
    getPublicDirectoryPath();
  }

  // Get storage directory paths
  // Like internal and external (SD card) storage path
  Future<void> getPath() async {
    List<String> paths;
    // getExternalStorageDirectories() will return list containing internal storage directory path
    // And external storage (SD card) directory path (if exists)
    paths = await ExternalPath.getExternalStorageDirectories();

    setState(() {
      _exPath = paths; // [/storage/emulated/0, /storage/B3AE-4D28]
      print("Print ext path $_exPath");
    });
  }

  // To get public storage directory path like Downloads, Picture, Movie etc.
  // Use below code
  Future<void> getPublicDirectoryPath() async {
    String path;

    path = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);

    setState(() {
      _download = path; // /storage/emulated/0/Download
    });
  }

  Future<void> getDBPath() async {
    String path = "";
    await sql.getDatabasesPath().then((value) {
      path = value;
    });
    setState(() {
      _dbPath = path;
      if (kDebugMode) {
        print(" db...$_dbPath");
      }
    });
  }

  Future<void> copyDBToStorage() async {
    File source1 = File("$_dbPath/otis.db");

    Directory copyTo = Directory(_download);
    if ((await copyTo.exists())) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
    } else {
      if (await Permission.storage.request().isGranted) {
        // Either the permission was already granted before or the user just granted it.
        await copyTo.create();
      } else {
        if (kDebugMode) {
          print('Please give permission');
        }
      }
    }

    String newPath = "${copyTo.path}/otis.db";

    await source1.copy(newPath).then((value) {
      value.length().then((value) => {print("$value")});
    });
  }

  void _pickFile() async {
    // opens storage to pick files and the picked file or files
    // are assigned into result and if no file is chosen result is null.
    // you can also toggle "allowMultiple" true or false depending on your need
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    // if no file is picked
    if (result == null) return;

    setState(() {
      _selectedFile = File(result.files.first.path!);

      print("Selected File path: ${_selectedFile?.path}");
    });
  }
}
