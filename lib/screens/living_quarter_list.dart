import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      appBar: AppBar(title: const Text(" Otis"),),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const AddQuarter()));
        },),
      //backgroundColor: Colors.lightGreenAccent,
      body: ListView.builder(
          itemCount: _livingQuarters.length,
          itemBuilder: (context, index) => GestureDetector(
                child: const Card(
                  child: ListTile(
                    title: Text(" Nouveau quartier"),
                  ),
                ),
              )),
    );
  }

  _loadData() async {
    final data = await SQLHelper.getLivingQuarters();

    setState(() {
      _livingQuarters = data;
    });
  }
}
