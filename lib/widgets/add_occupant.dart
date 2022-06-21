import 'package:flutter/material.dart';
import 'package:otis/models/lodging.dart';

import '../models/rent_period.dart';
import '../models/sql_helper.dart';

class AddOccupantForm extends StatefulWidget {
  final Lodging lodging;
  const AddOccupantForm({
    Key? key,
    required this.lodging,
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
  late Lodging lodging;

  @override
  void initState() {
    lodging = widget.lodging;
    _loadRent(lodging.id);
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
          onPressed: () async {
            await _addOccupant();
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
    print("in add accupant");
    String firstname = _firstnameTextController.text;
    String lastname = _lastnameTextEditController.text;
    int lodgingId = widget.lodging.id;
    if (widget.lodging.occupantId != null) {
      _showMessage('Il y a déjà un occupant');
    } else {
      await SQLHelper.insertOccupant(
              firstname, lastname, selectedDate.toIso8601String(), lodgingId)
          .then((occupantId) async {
        await SQLHelper.updateApartment(lodging.id, lodging.floor, lodging.rent,
                lodging.address, lodging.description, occupantId)
            .then((value) {
          _showMessage(" Occupant ajouté avec succès");
        });
      });
    }
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

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _showMessage(
      String message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
