import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/password_helper.dart';

class PasswordController extends StatefulWidget {
  final String title;

  const PasswordController({Key? key, required this.title}) : super(key: key);

  @override
  State<PasswordController> createState() => _PasswordControllerState();
}

class _PasswordControllerState extends State<PasswordController> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final TextEditingController passwordController = TextEditingController();
  final String label = "Entrer le mot de pass";
  final String hint = "Mot de pass";
  final String breakButtonLabel = "Annuler";
  final String okButtonLabel = "Continuer";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: passwordController,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: label,
                  hintText: hint),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 0.0, right: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SimpleDialogOption(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text(breakButtonLabel),
                  ), // button 1
                  SimpleDialogOption(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      var value = await _checkPassword();

                      if (!mounted) return;
                      Navigator.of(context).pop(value);
                    },
                    child: Text(okButtonLabel),
                  ), // button 2
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _checkPassword() async {
    String password = passwordController.text;
    if (kDebugMode) {
      print("in check password");
    }
    SharedPreferences prefs = await _prefs;
    final storedPass = prefs.get(kPassword);

    if (storedPass == password) {
      return true;
    }
    return false;
  }
}
