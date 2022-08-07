import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otis/screens/import-export.dart';

import 'package:otis/screens/living_quarter_list.dart';
import 'package:otis/screens/profile.dart';
import 'package:otis/screens/share_data.dart';
import 'package:otis/widgets/password_controller.dart';

import '../helper/helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const colorizeColors = [
    Colors.purple,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  static const colorizeTextStyle = TextStyle(
    fontSize: 50.0,
    fontFamily: 'Horizon',
  );

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
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
        ),
        drawer: Drawer(
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
                  "",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SettingsPages(),
                      ),
                    );
                  },
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
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const LivingQuarterList()));
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250.0,
                  child: TextLiquidFill(
                    text: 'F.K.Otis',
                    waveColor: Colors.blueAccent,
                    boxBackgroundColor: Colors.red,
                    textStyle: const TextStyle(
                      fontSize: 50.0,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                    boxHeight: 300.0,
                  ),
                ),
                const Text(
                  "Developed with ❤️ by Enyo",
                  //style: TextStyle(fontStyle: FontStyle.italic),
                  style: kLabelTextStyle,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
