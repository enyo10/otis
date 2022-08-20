import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otis/helper/helper.dart';
import 'package:otis/helper/password_helper.dart';
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
  bool _isLoading = true;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(
          " Les quartiers",
         // style: TextStyle(fontSize: 25.0),
          style: GoogleFonts.charmonman(
            textStyle: const TextStyle(fontSize: 25, fontWeight: FontWeight.w600)
          )
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
              .then((value) => _loadData());
        },
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
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
                                  icon: const Icon(Icons.delete, color: Colors.black),
                                  onPressed: () async {
                                    await _deleteLivingQuarter(
                                        livingQuarter.id);
                                    setState(() {});
                                  })
                            ],
                          ),
                        )),
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

  Future<void> _deleteLivingQuarter(int id) async {
    await askedToDelete(
        context, _passwordController, id, SQLHelper.deleteLivingQuarter);
    await _loadData();
    if (!mounted) return;
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => super.widget));
  }

  _hasData() => _livingQuarters.isNotEmpty;
}
