import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otis/models/living_quarter.dart';
import 'package:otis/widgets/add_building.dart';

import '../helper.dart';
import '../models/sql_helper.dart';

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
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black26,
      appBar: AppBar(
        title: const Text(" Immeubles"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => AddBuilding(livingQuarter: widget.livingQuarter),
                ),
              )
              .then((value) => value ? _loadData() : null);
        },
      ),
      body: _buildings.isEmpty
          ? const Center(
              child: Text(
                (" Pas de données"),
                style: TextStyle(
                  fontSize: 30.0,
                   color: Colors.white,
                ),
              ),
            )
          : ListView.builder(
              itemCount: _buildings.length,
              itemBuilder: (context, index) {
                var building = _buildings[index];
                var name = building['name'];
                var colorName = building['color'];
                var color = colorMap[colorName];

                return GestureDetector(
                  child: SizedBox(
                    height: 200,
                    child: Card(
                      elevation: 5,
                      margin: const EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      color: color,
                      child: ListTile(
                        title: Center(child: Text(name)),
                      ),
                    ),
                  ),
                );
              }),
    );
  }

  _loadData() async {
    final data = await SQLHelper.getBuildings(widget.livingQuarter.id);
    if (kDebugMode) {
      print(" buildings loaded and size is ${data.length}");
    }

    setState(() {
      _buildings = data;
    });
  }

  _getRequests() async {}
}
