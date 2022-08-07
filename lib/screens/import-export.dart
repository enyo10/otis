import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

import '../helper/helper.dart';

class ImportExportDB extends StatefulWidget {
  const ImportExportDB({Key? key}) : super(key: key);

  @override
  State<ImportExportDB> createState() => _ImportExportDBState();
}

class _ImportExportDBState extends State<ImportExportDB> {
  String? selectedFilePath;
  File? selectedFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  await _copyDatabaseFileToStorage().then((value) {
                    if (value != null && value.existsSync()) {
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
                        icon: const Icon(
                          Icons.delete,
                          size: 30.0,
                        ),
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
                  await _copyDatabaseFromStorage().then((value) {
                    if (value != null && value.existsSync()) {
                      message = " Restauration avec réussite. Bravo";
                      if (kDebugMode) {
                        print(" Value path ${value.path}");
                      }
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

  Future<File?> _copyDatabaseFileToStorage() async {
    File? file;
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);

    var databasePath = join(await getDatabasesPath(), 'otis.db');
    File databaseFile = File(databasePath);

    var status = await Permission.storage.status;
    if (!status.isGranted) {
      Permission.storage.request();
    } else {
      if (databaseFile.existsSync()) {
        var newPath = join(downloadPath, 'otis.db');
        await _deleteFile(File(newPath));
        file = databaseFile.copySync(newPath);
        print(" File path: ${file.path}");
      }
    }
    return file;
  }

  Future<File?> _copyDatabaseFromStorage() async {
    await Permission.manageExternalStorage.request();

    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);
    File? file;
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
      await Permission.manageExternalStorage.request();
    } else {
      if (selectedFile != null && selectedFile!.existsSync()) {
        var fileName = basename(selectedFilePath!);
        var copyFromPath = join(downloadPath, fileName);
        var copyToPath = join(await getDatabasesPath(), fileName);
        // deleteDatabase(copyToPath);
        file = File(copyFromPath).copySync(copyToPath);

        print("Database path : ${file.path}");
      }
    }
    return file;
  }

  void _pickFile() async {
    // opens storage to pick files and the picked file or files
    // are assigned into result and if no file is chosen result is null.
    // you can also toggle "allowMultiple" true or false depending on your need
    final FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: false);
    print(" result path ${result!.paths.first}");
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

  Future<void> _deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print(e);
    }
  }
  //deleteFile(File(your file path))

  Future<void> _requestPermission() async {
    Map<Permission, PermissionStatus> status =
        await [Permission.manageExternalStorage, Permission.storage].request();
  }

  bool _fileSelected() => selectedFilePath != null && selectedFile != null;
}

void main() {
  runApp(const ImportExportDB());
}
