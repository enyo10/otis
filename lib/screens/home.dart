import 'package:path/path.dart';
import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otis/screens/import-export.dart';
import 'package:otis/screens/living_quarter_list.dart';
import 'package:otis/screens/profile.dart';
import 'package:otis/widgets/password_controller.dart';
import '../helper/helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: const Color(0xFFEFFFFD),
            elevation: 0.0,
            iconTheme: const IconThemeData(
              color: Colors.red,
            ),
            actions: [
              Theme(
                data: Theme.of(context).copyWith(
                    textTheme: const TextTheme().apply(bodyColor: Colors.black),
                    dividerColor: Colors.white,
                    iconTheme: const IconThemeData(color: Colors.red)),
                child: PopupMenuButton<int>(
                  color: Colors.black,
                  itemBuilder: (context) => [
                    const PopupMenuItem<int>(
                        value: 0, child: Text("Enrégister BD")),
                    const PopupMenuDivider(
                      height: 10,
                    ),
                    const PopupMenuItem<int>(
                        value: 1, child: Text("Actualiser DB")),
                  ],
                  onSelected: (item) => _selectedItem(context, item),
                ),
              ),
            ]),
        drawer: Drawer(
          elevation: 5,
          width: MediaQuery.of(context).size.width * 0.9,
          child: ListView(
            padding: const EdgeInsets.all(4.0),
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.red,
                  image: DecorationImage(
                      image: AssetImage("assets/icons/ic_launcher.png"),
                      fit: BoxFit.cover),
                ),
                child: Text(
                  "Otis",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                leading: IconButton(
                  onPressed: () async {
                    var passwordController = const PasswordController(
                        title: "Modifier mot de passe");

                    await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return passwordController;
                        }).then((value) {
                      if (value) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SettingsPages(),
                          ),
                        );
                      } else {
                        showMessage(context, "Saisir mot de passe correcte");
                      }
                    });
                  },
                  /*onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SettingsPages(),
                      ),
                    );
                  },*/
                  icon: const Icon(Icons.person),
                ),
                title: const Text("Profile"),
                onTap: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SettingsPages(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: IconButton(
                  onPressed: () {
                    var passwordController =
                        const PasswordController(title: "Partage de données");
                  },
                  icon: const Icon(Icons.share),
                ),
                title: const Text("Partager données"),
                onTap: () async {
                  var passwordController =
                      const PasswordController(title: "Partage de données");

                  await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return passwordController;
                      }).then((value) {
                    if (value) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ImportExportDB(),
                        ),
                      );
                    } else {
                      showMessage(context, "Saisir mot de passe correcte");
                    }
                  });
                },
              ),
            ],
          ),
        ),
        body: GestureDetector(
          onDoubleTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const LivingQuarterList(),
              ),
            );
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextLiquidFill(
                  text: 'F.K.Otis',
                  // waveColor: Colors.blueAccent,
                  boxBackgroundColor: Colors.deepOrange,
                  textStyle: GoogleFonts.charmonman(
                      fontSize: 60,
                      fontWeight: FontWeight.w900,
                      color: Colors.blue),
                  boxWidth: 250,
                  boxHeight: 300.0,
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Developed with ❤️ by Enyo",
                    style: kLabelTextStyle,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadImages() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    List<Map<String, dynamic>> files = [];

    final ListResult result = await storage.ref().child("db/").list();

    final List<Reference> allFiles = result.items;

    await Future.forEach<Reference>(allFiles, (file) async {
      final String fileUrl = await file.getDownloadURL();

      final FullMetadata fileMeta = await file.getMetadata();
      files.add({
        "url": fileUrl,
        "path": file.fullPath,
        "uploaded_by": fileMeta.customMetadata?['uploaded_by'] ?? 'Nobody',
        "description":
            fileMeta.customMetadata?['description'] ?? 'No description'
      });
    });

    return files;
  }

  void _selectedItem(BuildContext context, item) {
    switch (item) {
      case 0:
        () async {
          var passwordController =
              const PasswordController(title: "Partage de données");

          await showDialog(
              context: context,
              builder: (BuildContext context) {
                return passwordController;
              }).then((value) {
            if (value) {
              _storeSqliteToFireStore(context);
            } else {
              showMessage(context, "Saisir mot de passe correcte");
            }
          });
        };

        break;
      case 1:
        _restoreSqliteFromFireStore(context);
        break;
    }
  }

  Future<void> _storeSqliteToFireStore(BuildContext context) async {
    final databasePath = join(await getDatabasesPath(), 'otis.db');
    File sqliteFile = File(databasePath);
    var fileName = basename(sqliteFile.path);
    FirebaseStorage storage = FirebaseStorage.instance;
    final fileStorage = storage.ref("dataBase").child(fileName);
    try {
      await fileStorage.putFile(sqliteFile).then(
            (p0) => showMessage(context, "Sauvagarde réussi 👍"),
          );
    } on FirebaseException catch (error) {
      //if (!context.mounted) return;
      showMessage(context, "Une erreur est survenue,😞");
    }
  }

  Future<void> _restoreSqliteFromFireStore(BuildContext context) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    final fileStorage = storage.ref("dataBase").child('otis.db');
    final databasePath = join(await getDatabasesPath(), 'otis.db');
    File sqlFile = File(databasePath);

    final downloadTask = fileStorage.writeToFile(sqlFile);
    downloadTask.snapshotEvents.listen((taskSnapshot) {
      switch (taskSnapshot.state) {
        case TaskState.running:
          print("----- running -----");
          break;
        case TaskState.paused:
          print("----- Pause -----");
          break;
        case TaskState.success:
          showMessage(context, "Actualisation réussie 👍");
          break;
        case TaskState.canceled:
          print("----- Cancelled -----");
          break;
        case TaskState.error:
          showMessage(context, "une erreur est survenue 😞");
          break;
      }
    });
  }
}
