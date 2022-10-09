import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OtisAddFloatingButton extends StatelessWidget {
  const OtisAddFloatingButton({
    Key? key,
    required this.callback,
  }) : super(key: key);
  final VoidCallback callback;
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: callback,
      child: const Icon(Icons.add),
    );
  }
}

class OtisListTile extends StatelessWidget {
  const OtisListTile(
      {Key? key,
      required this.callback,
      required this.delete,
      required this.title,
      required this.description})
      : super(key: key);
  final VoidCallback callback;
  final VoidCallback delete;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        contentPadding: const EdgeInsets.all(0.0),
        onTap: callback,
        title: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 30),
            ),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(description),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(0),
          width: 100.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              /* IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  Lodging lodging = Lodging.fromMap(element);
                                  var passChecker = const PasswordController(
                                      title: "Actualisation de donnée");
                                  await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return passChecker;
                                    },
                                  ).then((value) {
                                    if (value) {
                                      _showForm(lodging);
                                    }
                                  });

                                  // _showForm(lodging);
                                }),*/
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.black),
                onPressed: delete,
              )
            ],
          ),
        ));
  }
}
