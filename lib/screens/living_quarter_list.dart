import 'package:flutter/material.dart';
import 'package:otis/helper/helper.dart';
import 'package:otis/models/living_quarter.dart';
import 'package:otis/models/sql_helper.dart';
import 'package:otis/screens/buildings_list.dart';
import 'package:otis/widgets/add_quarter.dart';

class LivingQuarterList extends StatefulWidget {
  const LivingQuarterList({Key? key}) : super(key: key);

  @override
  State<LivingQuarterList> createState() => _LivingQuarterListState();
}

class _LivingQuarterListState extends State<LivingQuarterList> {
  List<Map<String, dynamic>> _livingQuarters = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          " Liste des quartiers",
          style: TextStyle(fontSize: 25.0),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => const AddQuarter(),
                  fullscreenDialog: true,
                ),
              )
              .then((value) => value ? _loadData() : null);
        },
      ),
      body: !_hasData()
          ? const Center(
              child: Text(
                " La liste est vide",
                style: TextStyle(fontSize: 25.0),
              ),
            )
          : ListView.builder(
              itemCount: _livingQuarters.length,
              itemBuilder: (context, index) {
                var livingQuarterMap = _livingQuarters[index];
                var livingQuarter = LivingQuarter.fromMap(livingQuarterMap);

                var name = livingQuarter.name;
                var description = livingQuarter.description;
                var colorName = livingQuarter.colorName;
                var color = colorMap[colorName];
                return SizedBox(
                  //height: 200,
                  child: Card(
                    elevation: 5,
                    margin: const EdgeInsets.only(top: 20, right: 20, left: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    color: color,
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                BuildingsList(livingQuarter: livingQuarter),
                          ),
                        );
                      },
                      title: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                            name,
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
                    ),
                  ),
                );
              }),
    );
  }

  _loadData() async {
    final data = await SQLHelper.getLivingQuarters();

    setState(() {
      _livingQuarters = data;
    });
  }

  _hasData() => _livingQuarters.isNotEmpty;
}
