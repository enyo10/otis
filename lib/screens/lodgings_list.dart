import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:otis/helper/helper.dart';
import 'package:otis/widgets/add_lodging.dart';
import 'package:otis/widgets/password_controller.dart';
import '../models/building.dart';
import '../models/lodging.dart';
import '../models/sql_helper.dart';
import 'lodging_details.dart';

class LodgingList extends StatefulWidget {
  final Building building;
  const LodgingList({Key? key, required this.building}) : super(key: key);

  @override
  State<LodgingList> createState() => _LodgingListState();
}

class _LodgingListState extends State<LodgingList> {
  // All journals
  List<Map<String, dynamic>> _apartments = [];
  TextEditingController passwordController = TextEditingController();
  String date = "";

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshData() async {
    final data = await SQLHelper.getApartments(widget.building.id);

    setState(() {
      _apartments = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData(); // Loading the diary when the app starts
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Les appartements',
          style: GoogleFonts.charmonman(
              textStyle:
                  const TextStyle(fontSize: 25, fontWeight: FontWeight.w600)),
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
                                  }),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  var id = element['id'];
                                  var passwordController =
                                      const PasswordController(
                                          title: "Suppression");
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return passwordController;
                                      }).then((value) async {
                                    if (value) {
                                      await _deleteItem(id);
                                    } else {
                                      showMessage(
                                          context, "Mot de passe erroné");
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          Lodging lodging = Lodging.fromMap(element);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    LodgingDetails(lodging: lodging)),
                          ).then((value) => _refreshData());
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showForm(null);
        },
      ),
    );
  }

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(Lodging? lodging) async {
    _updateModalBottomSheet(context, lodging);
  }

  _updateModalBottomSheet(context, lodging) {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
        context: context,
        builder: (BuildContext bc) {
          return AddLodging(building: widget.building, lodging: lodging);
        }).then((value) => _refreshData());
  }

  Future<void> _deleteItem(int id) async {
    var successMessage = 'Successfully deleted a journal!';
    await SQLHelper.deleteApartment(id)
        .then((value) => showMessage(context, successMessage))
        .then((value) => _refreshData());
  }
}
