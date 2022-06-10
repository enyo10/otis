import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otis/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/building.dart';
import '../models/lodging.dart';
import '../models/sql_helper.dart';
import 'lodging_details.dart';

class LodgingList extends StatefulWidget {
  final Building building;
  const LodgingList({Key? key, required this.building}) : super(key: key);

  @override
  _LodgingListState createState() => _LodgingListState();
}

class _LodgingListState extends State<LodgingList> {
  // All journals
  List<Map<String, dynamic>> _apartments = [];
  TextEditingController passwordController = TextEditingController();

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    final data = await SQLHelper.getApartments(widget.building.id);

    setState(() {
      _apartments = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals(); // Loading the diary when the app starts
  }

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Les appartements',
          style: TextStyle(fontSize: 25.0),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _apartments.length,
              itemBuilder: (context, index) => GestureDetector(
                onDoubleTap: () {
                  Map<String, dynamic> data = _apartments[index];
                  Lodging lodging = Lodging(
                      id: data['id'],
                      description: data['description'],
                      rent: data['rent'],
                      level: data['type']);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LodgingDetails(lodging: lodging),
                    ),
                  );
                },
                child: Card(
                  color: Colors.orange[100],
                  margin: const EdgeInsets.all(15),
                  child: ListTile(
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          _apartments[index]['address'],
                          style: const TextStyle(fontSize: 20.0),
                        ),
                      ),
                      subtitle: Text(
                        _apartments[index]['description'],
                        style: const TextStyle(fontSize: 15.0),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.all(0),
                        width: 100.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _showForm(_apartments[index]['id']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteItem(_apartments[index]['id']),
                            ),
                          ],
                        ),
                      )),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
          _apartments.firstWhere((element) => element['id'] == id);
      _addressController.text = existingJournal['address'];
      _descriptionController.text = existingJournal['description'];
      _rentController.text = existingJournal['rent'].toString();
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                // this will prevent the soft keyboard from covering the text fields
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(hintText: 'Address'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration:
                          const InputDecoration(hintText: 'Description'),
                    ),
                    TextField(
                      controller: _rentController,
                      // keyboardType: TextInputType.number,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'(^\d*\.?\d*)')),
                      ],
                      // Only numbers can be entered
                      decoration: const InputDecoration(hintText: 'rent'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Save new journal
                        if (id == null) {
                          await _addApartment();
                        }

                        if (id != null) {
                          await _updateItem(id);
                        }
                        // Clear the text fields
                        _addressController.text = '';
                        _descriptionController.text = '';

                        // Close the bottom sheet
                        Navigator.of(context).pop();
                      },
                      child: Text(id == null ? 'Create New' : 'Update'),
                    )
                  ],
                ),
              ),
            ));
  }

// Insert a new journal to the database
  Future<void> _addApartment() async {
    await SQLHelper.insertApartment(
        1,
        widget.building.id,
        _addressController.text,
        _descriptionController.text,
        double.parse(_rentController.text));

    _refreshJournals();
  }

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    double rent = double.parse(_rentController.text);
    await SQLHelper.updateApartment(
        id, 1, rent, _addressController.text, _descriptionController.text);
    _refreshJournals();
  }

  _checkPasswordAndDeleteItem(int id) async {
    _checkPassword().then((value) async {
      if (kDebugMode) {
        print(value);
      }
      if (value) {
        await SQLHelper.deleteApartment(id);
        if (kDebugMode) {
          print("Delete");
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully deleted a journal!'),
          ),
        );
        passwordController.clear();
        _refreshJournals();
      }
    });
  }

  // Delete an item
  void _deleteItem(int id) async {
    // _askedToDelete(id);
   //showAlertDialog(context);
    _showPasswordDialog();
  }

  Future<bool> _checkPassword() async {
    print("in check password");
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    final storedPass = prefs.get(kPassword);
    final password = passwordController.text;
    if (storedPass == password) {
      return true;
    }
    return false;
  }

   Future<void> _showPasswordDialog() async {
    await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Voulez vous supprimer?"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextField(
                    controller: passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Entrer le mot de pass',
                        hintText: 'Mot de pass'),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("annuler"),
                        ), // button 1
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(" Supprimer"),
                        ), // button 2
                      ])
                ],
              ),
            ),
          );
        });
  }
  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("Confirmer"),
      onPressed: () {},
    );

    Widget noButton = TextButton(
      child: const Text("Annuler"),
      onPressed: () {},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("My title"),
      content: TextField(
        controller: passwordController,
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Entrer le mot de pass',
            hintText: 'Mot de pass'),
      ),
      actions: [noButton, okButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> _askedToDelete(int id) async {
    switch (await showDialog<CheckedValue>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(" Suppression de donnée"),
            content:
                //   children: [

                SingleChildScrollView(
              child: Column(
                children: [
                  const Text("data"),
                  TextField(
                    controller: passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Entrer le mot de pass',
                        hintText: 'Mot de pass'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.of(context).pop(CheckedValue.no);
                        },
                        child: const Text("annuler"),
                      ), // button 1
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.of(context).pop(CheckedValue.yes);
                        },
                        child: const Text(" Supprimer"),
                      ), // button 2
                    ],
                  ),
                ],
              ),
            ),
/*
              TextField(
                controller: passwordController,
                keyboardType: TextInputType.visiblePassword,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Entrer le mot de pass',
                    hintText: 'Mot de pass'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.of(context).pop(CheckedValue.no);
                    },
                    child: const Text("annuler"),
                  ), // button 1
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.of(context).pop(CheckedValue.yes);
                    },
                    child: const Text(" Supprimer"),
                  ), // button 2
                ],
              ),*/
          );
        })) {
      case CheckedValue.yes:
        _checkPasswordAndDeleteItem(id);
        break;
      case CheckedValue.no:
        break;
      case null:
        break;
    }
  }

  /*Future<void> _askedToLead() async {
    switch (await showDialog<CheckedValue>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Select assignment'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, "Treasury");
                },
                child: const Text('Treasury department'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, "State");
                },
                child: const Text('State department'),
              ),
            ],
          );
        })) {
      case CheckedValue.yes:
        print("Treasure");
        break;
      case CheckedValue.no:
        // TODO: Handle this case.
        break;
      case null:
        // dialog dismissed
        break;
    }
  }*/
}
