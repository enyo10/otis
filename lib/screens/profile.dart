import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/helper.dart';

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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(
                  height: 30,
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "Changer mot de pass",
                      style: TextStyle(
                        fontSize: 25.0,
                      ),
                    ),
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
