import 'package:flutter/material.dart';
import 'package:otis/models/building.dart';
import 'package:otis/models/living_quarter.dart';
import 'package:otis/screens/lodgings_list.dart';
import 'package:otis/widgets/add_building.dart';

import '../helper/helper.dart';
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
      // backgroundColor: Colors.black26,
      appBar: AppBar(
        title: const Text(
          " Les immeubles",
          style: TextStyle(fontSize: 25.0),
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
                          builder: (context) => LodgingList(building: building),
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
                  ),
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
}
