import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otis/models/building.dart';
import 'package:otis/models/living_quarter.dart';
import 'package:otis/screens/lodgings_list.dart';
import 'package:otis/widgets/add_building.dart';

import '../helper/helper.dart';
import '../models/sql_helper.dart';
import '../widgets/password_controller.dart';

class BuildingsList extends StatefulWidget {
  final LivingQuarter livingQuarter;
  const BuildingsList({Key? key, required this.livingQuarter})
      : super(key: key);

  @override
  State<BuildingsList> createState() => _BuildingsListState();
}

class _BuildingsListState extends State<BuildingsList> {
  List<Map<String, dynamic>> _buildings = [];

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black26,
      appBar: AppBar(
        title: Text(
          " Les immeubles",
          style: GoogleFonts.charmonman(
              textStyle:
                  const TextStyle(fontSize: 25, fontWeight: FontWeight.w600)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) =>
                      AddBuilding(livingQuarter: widget.livingQuarter),
                ),
              )
              .then((_) => {_loadData()});
        },
      ),
      body: _buildings.isEmpty
          ? const Center(
              child: Text(
                ("La liste est vide"),
                style: TextStyle(
                  fontSize: 25.0,
                ),
              ),
            )
          : ListView.builder(
              itemCount: _buildings.length,
              itemBuilder: (context, index) {
                var building = Building.fromMap(_buildings[index]);
                var name = building.name;
                var desc = building.desc;
                var colorName = building.colorName;
                var color = colorMap[colorName];

                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  color: color,
                  child: ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                LodgingList(building: building),
                          ),
                        );
                      },
                      title: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            name,
                            style: const TextStyle(fontSize: 30.0),
                          ),
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(desc),
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
                                icon: const Icon(Icons.delete,
                                    color: Colors.black),
                                onPressed: () {
                                  _deleteBuilding(building.id);
                                })
                          ],
                        ),
                      )),
                );
              }),
    );
  }

  _loadData() async {
    final data = await SQLHelper.getBuildings(widget.livingQuarter.id);
    setState(() {
      _buildings = data;
    });
  }

  Future<void> _deleteBuilding(int id) async {
    var title = "Suppression";

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return PasswordController(title: title);
        }).then((value) async {
      if (value!) {
        await SQLHelper.deleteBuilding(id).then((value) {
          showMessage(context, " L'immeuble est supprimée");
        });
      } else {
        showMessage(context, "Saisir mot de passe correcte");
      }
    });

    await _loadData();

    if (!mounted) return;
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => super.widget));
  }
}
