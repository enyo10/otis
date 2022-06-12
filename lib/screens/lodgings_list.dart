import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grouped_list/grouped_list.dart';
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
  final TextEditingController _floorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Les appartements',
          style: TextStyle(fontSize: 25.0),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : GroupedListView<dynamic, String>(
                elements: _apartments,
                groupBy: (element) => element['floor'].toString(),
                groupComparator: (value1, value2) => value2.compareTo(value1),
                itemComparator: (item1, item2) =>
                    item1['address'].compareTo(item2['address']),
                order: GroupedListOrder.DESC,
                useStickyGroupSeparators: true,
                groupSeparatorBuilder: (String value) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                itemBuilder: (c, element) {
                  return Card(
                    elevation: 8.0,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 6.0),
                    child: SizedBox(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        title: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            element['address'],
                            style: const TextStyle(fontSize: 20.0),
                          ),
                        ),
                        subtitle: Text(element['description']),
                        trailing: Container(
                          padding: const EdgeInsets.all(0),
                          width: 100.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showForm(element['id']),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteItem(element['id']),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          if (kDebugMode) {
                            print("on tap");
                          }

                          Lodging lodging = Lodging(
                              id: element['id'],
                              description: element['description'],
                              rent: element['rent'],
                              level: element['floor']);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  LodgingDetails(lodging: lodging),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
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
      _floorController.text = existingJournal['floor'].toString();
      _rentController.text = existingJournal['rent'].toString();
    }

    //await _showModalBottomSheet(id);
    _moreModalBottomSheet(context, id);
  }

  /* _showModalBottomSheet(int? id) async {
    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        // color: Colors.transparent,
        padding: EdgeInsets.only(
          top: 0,
          left: 0,
          right: 0,
          // this will prevent the soft keyboard from covering the text fields
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),

        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _floorController,
                    decoration:
                        const InputDecoration(hintText: 'Numéro d\'étage'),
                  ),
                ),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(hintText: 'Address'),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(hintText: 'Description'),
                ),
                TextField(
                  controller: _rentController,
                  // keyboardType: TextInputType.number,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)')),
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
        ),
      ),
    );
  }*/

  _moreModalBottomSheet(context, id) {
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
        context: context,
        builder: (BuildContext bc) {
          return Container(
            height: size.height * 0.5,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(40.0),
                topLeft: Radius.circular(40.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: ListView(
                physics: const ClampingScrollPhysics(),
                children: [
                  //content of modal bottom
                  // sheet
                  const Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 8.0),
                    child: Center(
                      child: Text(
                        'Appartement',
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 60),
                    child: Divider(
                      thickness: 5, // thickness of the line
                      indent: 20, // empty space to the leading edge of divider.
                      endIndent:
                          20, // empty space to the trailing edge of the divider.
                      color: Colors
                          .red, // The color to use when painting the line.
                      height: 20, // The divider's height extent.
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _floorController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: 'Numéro d\'étage',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        hintText: 'Address',
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        hintText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _rentController,
                      // keyboardType: TextInputType.number,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'(^\d*\.?\d*)')),
                      ],
                      // Only numbers can be entered
                      decoration: const InputDecoration(
                        hintText: 'rent',
                        border: OutlineInputBorder(),
                      ),
                    ),
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
                  ),
                ],
              ),
            ),
          );
        });
  }

  _checkPasswordAndDeleteItem(int id) async {
    if (kDebugMode) {
      print("check password ");
    }
    _checkPassword().then((value) async {
      if (value) {
        await SQLHelper.deleteApartment(id);
        if (kDebugMode) {
          print("in delete $value");
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully deleted a journal!'),
          ),
        );
        passwordController.clear();
        _refreshJournals();
      } else {
        if (kDebugMode) {
          print("value $value");
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Echec, Vérifier les données'),
          ),
        );
      }
    });
  }

  // Delete an item
  Future<void> _deleteItem(int id) async {
    _askedToDelete(id);
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

  /* Future<void> _showPasswordDialog() async {
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
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }*/

  _showAlertDialog(BuildContext context) {
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

  bool _apartmentHasData() {
    if (_floorController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _rentController.text.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  // Insert a new journal to the database
  Future<void> _addApartment() async {
    if (_apartmentHasData()) {
      await SQLHelper.insertApartment(
              int.parse(_floorController.text),
              widget.building.id,
              _addressController.text,
              _descriptionController.text,
              double.parse(_rentController.text))
          .then((value) async {
        await SQLHelper.insertRent(
            value, DateTime.now(), double.parse(_rentController.text));
      });
      _refreshJournals();
    }

    //  _refreshJournals();
  }

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    double rent = double.parse(_rentController.text);
    int floor = int.parse(_floorController.text);
    await SQLHelper.updateApartment(
        id, floor, rent, _addressController.text, _descriptionController.text);
    _refreshJournals();
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
}
