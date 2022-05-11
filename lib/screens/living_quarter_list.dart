import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otis/helper.dart';
import 'package:otis/models/sql_helper.dart';
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
        title: const Text(" Otis"),
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
      body: ListView.builder(
          itemCount: _livingQuarters.length,
          itemBuilder: (context, index) {
            var livingQuarter = _livingQuarters[index];
            var name = livingQuarter['name'];
            var colorName = livingQuarter['color'];
            var color = colorMap[colorName];

            return GestureDetector(
              child: Card(
                color: color,
                child: ListTile(
                  title: Text(name),
                ),
              ),
            );
          }),
    );
  }

  _loadData() async {
    final data = await SQLHelper.getLivingQuarters();
    if (kDebugMode) {
      print(" living quarter loaded and size is ${data.length}");
    }

    setState(() {
      _livingQuarters = data;
    });
  }

  _getRequests() async {}
}
