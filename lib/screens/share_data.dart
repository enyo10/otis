import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';

import '../helper/helper.dart';

class ShareData extends StatefulWidget {
  const ShareData({Key? key}) : super(key: key);

  @override
  State<ShareData> createState() => _ShareDataState();
}

class _ShareDataState extends State<ShareData> {
  List<String> _exPath = [];
  late String _dbPath;
  late String _download;
  String? selectedFilePath;
  File? selectedFile;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stockage de base de donnée"),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50.0),
              child: ElevatedButton(
                onPressed: () async {
                  String message;
                  await _copyDBToStorage().then((value) {
                    if (value.existsSync()) {
                      message = " DB copiée dans fichier téléchargement réussi";
                    } else {
                      message = " Erreur lors de la copie";
                    }
                    showMessage(context, message);
                  });
                },
                child: const Text(
                  "Partager DB",
                  style: TextStyle(fontSize: 30.0),
                ),
              ),
            ),
            _fileSelected()
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: ListTile(
                      title: Text(
                        basename(selectedFile!.path),
                        style: const TextStyle(fontSize: 30),
                      ),
                      trailing: IconButton(
                        onPressed: _deleteSelectedFile,
                        icon: const Icon(Icons.delete, size: 30.0,),
                      ),
                      tileColor: Colors.red,
                      textColor: Colors.white,
                      iconColor: Colors.white,
                    ),
                  )
                : const Center(
                    child: Text(
                      "Pas de selection",
                      style: TextStyle(fontSize: 30.0),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50.0),
              child: ElevatedButton(
                  onPressed: () {
                    _pickFile();
                  },
                  child: const Text(
                    "Pick File",
                    style: TextStyle(fontSize: 30.0),
                  )),
            ),
            Visibility(
              visible: _fileSelected(),
              child: ElevatedButton(
                onPressed: () async {
                  String message;
                  await _copyToDB().then((value) {
                    if (value != null) {
                      message = " Restauration avec réussite. Bravo";
                    } else {
                      message = " Erreur lors de la restauration";
                    }
                    showMessage(context, message);
                  });
                },
                child: const Text(
                  "Tranférer  donnée",
                  style: TextStyle(fontSize: 30.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Future<File> _copyDBToStorage() async {
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

    return await source1.copy(newPath);
  }

  Future<File?> _copyToDB() async {
    if (_fileSelected()) {
      return await selectedFile?.copy("$_dbPath/otis.db");
    }
    return null;
  }

  void _pickFile() async {
    // opens storage to pick files and the picked file or files
    // are assigned into result and if no file is chosen result is null.
    // you can also toggle "allowMultiple" true or false depending on your need
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    // if no file is picked
    if (result == null) return;

    setState(() {
      selectedFilePath = result.files.first.path;
      selectedFile = File(selectedFilePath!);
    });
  }

  void _deleteSelectedFile() {
    setState(() {
      selectedFilePath = null;
      selectedFile = null;
    });
  }

  bool _fileSelected() => selectedFilePath != null && selectedFile != null;
}
