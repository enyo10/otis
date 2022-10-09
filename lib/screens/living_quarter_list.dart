import 'package:flutter/material.dart';
import 'package:otis/helper/helper.dart';
import 'package:otis/models/living_quarter.dart';
import 'package:otis/models/sql_helper.dart';
import 'package:otis/screens/buildings_list.dart';
import 'package:otis/widgets/add_quarter.dart';
import 'package:otis/widgets/otis_appBar_title.dart';
import 'package:otis/widgets/password_controller.dart';

import '../widgets/otis_widgets.dart';

class LivingQuarterList extends StatefulWidget {
  const LivingQuarterList({Key? key}) : super(key: key);

  @override
  State<LivingQuarterList> createState() => _LivingQuarterListState();
}

class _LivingQuarterListState extends State<LivingQuarterList> {
  List<Map<String, dynamic>> _livingQuarters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppBarTitleWidget(title: "Les quartiers", ratio: 40),
      ),
      floatingActionButton:
          OtisAddFloatingButton(callback: _navigateToAddQuarter),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _livingQuarters.length,
              itemBuilder: (context, index) {
                var livingQuarterMap = _livingQuarters[index];
                var livingQuarter = LivingQuarter.fromMap(livingQuarterMap);

                var title = livingQuarter.name;
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
                    child: OtisListTile(
                        callback: () => _navigateToBuildingList(livingQuarter),
                        delete: () => _deleteLivingQuarter(livingQuarter.id),
                        title: title,
                        description: description),
                  ),
                );
              }),
    );
  }

  _loadData() async {
    final data = await SQLHelper.getLivingQuarters();

    setState(() {
      _livingQuarters = data;
      _isLoading = false;
    });
  }

  _navigateToBuildingList(LivingQuarter livingQuarter) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BuildingsList(livingQuarter: livingQuarter),
      ),
    );
  }

  _navigateToAddQuarter() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => const AddQuarter(),
            fullscreenDialog: true,
          ),
        )
        .then((value) => _loadData());
  }

  Future<void> _deleteLivingQuarter(int id) async {
    var title = "Suppression";
    var passwordController = PasswordController(title: title);
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return passwordController;
        }).then((value) async {
      if (value!) {
        await SQLHelper.deleteLivingQuarter(id).then((value) {
          showMessage(context, " Le quartier est supprimé");
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
