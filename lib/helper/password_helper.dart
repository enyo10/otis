import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helper.dart';

const kPassword = "password";

Future<void> askedToDelete(
    BuildContext context,
    TextEditingController passwordController,
    int id,
    Function deleteFunction) async {
  switch (await showDialog<CheckedValue>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text("Suppression de donnée",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Entrer le mot de pass',
                      hintText: 'Mot de pass'),
                ),
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: <Widget>[
                    SimpleDialogOption(
                      onPressed: () {
                        Navigator.of(context).pop(CheckedValue.no);
                      },
                      padding: const EdgeInsets.only(left: 8.0),
                      child: const Text(
                        "Annuler",
                        style: TextStyle(color: Colors.blue),
                        textAlign: TextAlign.left,
                      ),
                    ), // button 1
                    SimpleDialogOption(
                      padding: const EdgeInsets.only(right: 8.0),
                      onPressed: () {
                        Navigator.of(context).pop(CheckedValue.yes);
                      },
                      child: const Text(
                        " Continuer",
                        style: TextStyle(color: Colors.red),
                      ),
                    ), // button 2
                  ],
                ),
              ],
            ),
          ),
        );
      })) {
    case CheckedValue.yes:
      _checkPasswordAndDeleteItem(
          context, passwordController, id, deleteFunction);
      break;
    case CheckedValue.no:
      break;
    case null:
      break;
  }
}

Future<void> _checkPasswordAndDeleteItem(
    BuildContext context,
    TextEditingController passwordController,
    int id,
    Function deleteFunction) async {
  await _checkPassword(passwordController.text).then((value) async {
    if (value) {
      await deleteFunction(id);

      /* ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully deleted a journal!'),
        ),
      );*/
      passwordController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Echec, Vérifier les données'),
        ),
      );
    }
  });
}

Future<bool> _checkPassword(String passWord) async {
  final Future<SharedPreferences> p = SharedPreferences.getInstance();
  SharedPreferences prefs = await p;
  final storedPass = prefs.get(kPassword);
  final password = passWord;
  if (storedPass == password) {
    return true;
  }
  return false;
}
