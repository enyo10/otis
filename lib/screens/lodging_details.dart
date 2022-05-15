import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otis/helper.dart';
import 'package:otis/models/payment.dart';

import '../models/lodging.dart';
import '../models/occupant.dart';
import '../models/sql_helper.dart';
import '../widgets/occupant_form.dart';

class LodgingDetails extends StatefulWidget {
  final Lodging lodging;
  const LodgingDetails({Key? key, required this.lodging}) : super(key: key);

  @override
  State<LodgingDetails> createState() => _LodgingDetailsState();
}

class _LodgingDetailsState extends State<LodgingDetails> {
  final TextEditingController _amount = TextEditingController();
  late final Occupant _occupant;
  Map<String, dynamic>? _occupantMap;
  List<Map<String, dynamic>> _occupants = [];

  bool _isLoading = true;

  void _loadOccupantMap() async {
    final data = await SQLHelper.getOccupantsWithLodgingId(widget.lodging.id);

    setState(() {
      _occupants = data;
      _isLoading = false;
      if (_occupants.isNotEmpty) {
        _occupantMap = _occupants.first;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadOccupantMap();
  }

  @override
  Widget build(BuildContext context) {
    if (_occupants.isNotEmpty) {
      _occupantMap = _occupants.first;
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Logement'),
          actions: [
            IconButton(
                onPressed: () {
                  showOccupantForm();
                },
                icon: const Icon(Icons.add))
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Visibility(
            visible: isOccupied(),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  //  primary: Colors.purple,
                  // padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  padding: const EdgeInsets.all(10),
                  textStyle: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold)),
              child: const Text(" Ajouter payement"),
              autofocus: true,
            ),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: !isOccupied()
                    ? const Center(
                        child: Text("Pas d'occupant"),
                      )
                    : Builder(
                        builder: (context) {
                          var entryDate =
                              DateTime.parse(_occupantMap!['entry_date']);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 30.0),
                                    child: Row(
                                      children: [
                                        const Text("Nom:"),
                                        Text(
                                          " : ${_occupantMap!['firstname']} ",
                                          style: const TextStyle(
                                            fontSize: 20,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Row(
                                      children: [
                                        const Text("Prenom:"),
                                        Text(
                                          "  ${_occupantMap!['lastname']} ",
                                          style: const TextStyle(fontSize: 20),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10.0, bottom: 20.0),
                                    child: Row(
                                      children: [
                                        const Text("Date d'entrée:"),
                                        Text(
                                          ' ${entryDate.day}/${entryDate.month}/${entryDate.year}',
                                          style:
                                              const TextStyle(fontSize: 20.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.only(top: 10, bottom: 30),
                                    child: Text(
                                      "Situation des payements ",
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.blue),
                                    ),
                                  )
                                ],
                              ),
                              Expanded(
                                child: ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        const Divider(
                                          color: Colors.black,
                                        ),
                                    itemCount: monthMap.values.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      var month =
                                          monthMap.values.elementAt(index);
                                      return _situationWidget(
                                          month, 2000, null);
                                    }),
                              )
                            ],
                          );
                        },
                      ),
              ));
  }

  void addPayment(double payment) {
    // get occupant id
    // save payment in table.
  }

  showOccupantForm() {
    var id = widget.lodging.id;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddOccupantForm(
        lodgingId: id,
      ),
    ).then((value) => _loadOccupantMap());
  }

  bool isOccupied() => _occupantMap != null;

  Icon _statusIcon(String mount, int year, Payment? payment) {
    var icon = const Icon(
      Icons.close,
      color: Colors.red,
    );
    if (payment != null) {
      if (payment.amount == widget.lodging.rent) {
        icon = const Icon(
          Icons.check,
          color: Colors.green,
        );
      } else {
        icon = const Icon(
          Icons.check_box_outlined,
          color: Colors.orange,
        );
      }
    }
    return icon;
  }

  Widget _situationWidget(String month, int year, Payment? payment) {

    var icon = _statusIcon(month, year, payment);

    return Row(
      children: [
        Text(
          month,
          style: const TextStyle(fontSize: 20.0),
        ),
        icon
      ],
    );
  }
}
