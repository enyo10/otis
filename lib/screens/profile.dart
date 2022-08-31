import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/helper.dart';
import '../helper/password_helper.dart';

class SettingsPages extends StatefulWidget {
  const SettingsPages({Key? key}) : super(key: key);

  @override
  State<SettingsPages> createState() => _SettingsPagesState();
}

class _SettingsPagesState extends State<SettingsPages> {
  TextEditingController actualPasswordController = TextEditingController();
  TextEditingController newPasswordFieldController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Container(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(padding: const EdgeInsets.all(20),
                  child: Row(
                    children: const [
                      Text("Nouveau mot de pass", style: TextStyle(
                        fontSize: 30.0,
                      ),),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: actualPasswordController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Le mot de passe actuel',
                        hintText: 'Mot de pass'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: newPasswordFieldController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Le nouveau mot de passe',
                        hintText: 'Nouveau'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: passwordConfirmController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Confirmation du nouveau mot de passe',
                        hintText: 'Confirmation'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _updatePassword();
                      Navigator.of(context).pop();
                    },
                    child: const Text(" Modifier"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _resetPassword() async {
    final SharedPreferences prefs = await _prefs;
    var actualPassword = prefs.get(kPassword);
    if (actualPassword == actualPasswordController.text) {
      final password = newPasswordFieldController.text;
      final passwordConfirm = passwordConfirmController.text;
      if (password == passwordConfirm && password.length > 4) {
        return prefs.setString("password", password);
      }
    }

    return false;
  }

  _updatePassword() {
    String message;
    _resetPassword().then((value) {
      if (value) {
        message = "Modification avec succes";
      } else {
        message = "Erreur lors de modification";
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    });
  }
}
