import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:otis/helper.dart';
import 'package:otis/widgets/add_lodging.dart';
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
  String date = "";

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
                                  onPressed: () {
                                    Lodging lodging = Lodging(
                                        id: element['id'],
                                        description: element['description'],
                                        rent: element['rent'],
                                        level: element['floor'],
                                        address: element['address']);

                                    _showForm(lodging);
                                  }),
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
                              level: element['floor'],
                              address: element['address']);

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
  void _showForm(Lodging? lodging) async {
    //await _showModalBottomSheet(id);
    _moreModalBottomSheet(context, lodging);
  }

  _moreModalBottomSheet(context, lodging) {
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
        context: context,
        builder: (BuildContext bc) {
          return AddLodging(building: widget.building, lodging: lodging);
        }).then((value) => _refreshJournals());
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

  Future<void> _askedToDelete(int id) async {
    switch (await showDialog<CheckedValue>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(" Suppression de donnée"),
            content: SingleChildScrollView(
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
