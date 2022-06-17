import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/rent_period.dart';
import '../models/sql_helper.dart';

class AddOccupantForm extends StatefulWidget {
  final int lodgingId;
  const AddOccupantForm({
    Key? key,
    required this.lodgingId,
  }) : super(key: key);

  @override
  State<AddOccupantForm> createState() => _AddOccupantFormState();
}

class _AddOccupantFormState extends State<AddOccupantForm> {
  final TextEditingController _firstnameTextController =
      TextEditingController();

  final TextEditingController _lastnameTextEditController =
      TextEditingController();
  String date = "";
  DateTime selectedDate = DateTime.now();
  late DateTime lodgingCreation;

  @override
  void initState() {
    _loadRent(widget.lodgingId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      height: MediaQuery.of(context).size.height * 0.60,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        /* resizeToAvoidBottomInset: false,*/
        bottomNavigationBar: FloatingActionButton.extended(
          onPressed: () {
            _addOccupant();
            // Close the bottom sheet
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.send),
          label: const Text(' Ajouter'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Center(
                child: Text(' Ajouter un locataire',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30.0, color: Colors.red)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _firstnameTextController,
                  decoration: const InputDecoration(
                    labelText: "Nom",
                    border: OutlineInputBorder(),
                    hintText: 'Nom du locataire',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _lastnameTextEditController,
                  decoration: const InputDecoration(
                    labelText: "Premon ",
                    border: OutlineInputBorder(),
                    hintText: 'Prénom du locataire',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _selectDate(context);
                      },
                      child: const Text("Date d'entrée"),
                    ),
                    const SizedBox(
                      width: 40.0,
                    ),
                    Text(
                      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _addOccupant() async {
    String firstname = _firstnameTextController.text;
    String lastname = _lastnameTextEditController.text;
    int lodgingId = widget.lodgingId;
    var id = await SQLHelper.insertOccupant(
        firstname, lastname, selectedDate.toIso8601String(), lodgingId);
  }

  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: lodgingCreation,
      lastDate: DateTime(2040),
    );
    if (selected != null && selected != selectedDate) {
      setState(() {
        selectedDate = selected;
        if (kDebugMode) {
          print(selected.toString());
        }

        DateTime? dt = DateTime.now();
        if (kDebugMode) {
          print(" dt: $dt");
        }

// String
        var dtStr = dt.toIso8601String();
        if (kDebugMode) {
          print(" dtStr: $dtStr");
        }
        dt = DateTime.tryParse(dtStr);
        if (kDebugMode) {
          print(" dt after reconversion : $dt");
        }

// Int
        var dtInt = dt?.millisecondsSinceEpoch;
        if (kDebugMode) {
          print("dtInt : $dtInt");
        }
        dt = DateTime.fromMillisecondsSinceEpoch(dtInt!);
        if (kDebugMode) {
          print(" dt after reconvert from $dt");
        }
      });
    }
  }

  _loadRent(int lodgingId) async {
    List<Rent> list = [];

    await SQLHelper.getRents(lodgingId).then((value) {
      list = value.map((e) => Rent.formMap(e)).toList();
    });
    setState(() {
      lodgingCreation = list.elementAt(0).startDate;
    });
  }
}
