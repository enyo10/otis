import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helper.dart';

class PasswordChecker extends StatefulWidget {
  final String title;
  final String label;
  final String hint;
  const PasswordChecker(
      {Key? key, required this.title, required this.label, required this.hint})
      : super(key: key);

  @override
  State<PasswordChecker> createState() => _PasswordCheckerState();
}

class _PasswordCheckerState extends State<PasswordChecker> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final TextEditingController passwordController = TextEditingController();

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
                  labelText: widget.label,
                  hintText: widget.hint),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text("Annuler"),
                ), // button 1
                SimpleDialogOption(
                  onPressed: () async {
                    var value = await _checkPassword();

                    if (!mounted) return;
                    Navigator.of(context).pop(value);
                  },
                  child: const Text(" Check"),
                ), // button 2
              ],
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
