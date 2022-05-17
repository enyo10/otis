import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otis/helper.dart';
import 'package:otis/models/payment.dart';
import 'package:otis/models/payment_period.dart';

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
  /*final TextEditingController _amount = TextEditingController();
  late final Occupant _occupant;*/
  Map<String, dynamic>? _occupantMap;
  List<Map<String, dynamic>> _occupants = [];
  Payment payment1 = Payment(
      paymentId: 1,
      amount: 2076,
      ownerId: 1,
      paymentDate: DateTime.now(),
      paymentPeriod: PaymentPeriod(month: 1, year: 2022));
  Payment payment2 = Payment(
      paymentId: 1,
      amount: 39652.0,
      ownerId: 1,
      paymentDate: DateTime.now(),
      paymentPeriod: PaymentPeriod(month: 2, year: 2022));
  Payment payment3 = Payment(
      paymentId: 1,
      amount: 2076,
      ownerId: 1,
      paymentDate: DateTime.now(),
      paymentPeriod: PaymentPeriod(month: 3, year: 2022));
  Payment payment4 = Payment(
      paymentId: 1,
      amount: 39652.0,
      ownerId: 1,
      paymentDate: DateTime.now(),
      paymentPeriod: PaymentPeriod(month: 4, year: 2022));
  List<Payment> payments = [];


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
    payments.add(payment1);
    payments.add(payment2);
    payments.add(payment3);
    payments.add(payment4);

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
                                        const Text(
                                          "Nom:",
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic),
                                        ),
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
                                        const Text(
                                          "Prenom:",
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic),
                                        ),
                                        Text(
                                          "  ${_occupantMap!['lastname']} ",
                                          style: const TextStyle(fontSize: 20),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Row(
                                      children: [
                                        const Text("Date d'entrée:",
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic)),
                                        Text(
                                          ' ${entryDate.day}/${entryDate.month}/${entryDate.year}',
                                          style:
                                              const TextStyle(fontSize: 20.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 20),
                                    child: Row(
                                      children: [
                                        const Text(
                                          "Mensualité:",
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic),
                                        ),
                                        Text(
                                          " ${widget.lodging.rent} \$ ",
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
                              Container(
                                padding: const EdgeInsets.only(left: 0),
                                color: Colors.black12,
                                height: 40.0,
                                child: Row(
                                  children: [
                                    Container(
                                      child: const Text(
                                        "Mois",
                                        style: TextStyle(fontSize: 20.0),
                                      ),
                                      padding: const EdgeInsets.only(left: 10),
                                      width: 150.0,
                                    ),
                                    //const SizedBox(width: 40,),
                                    const Text(
                                      "Status",
                                      style: TextStyle(
                                        fontSize: 20.0,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
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
                                      var period =
                                          PaymentPeriod(month: 1, year: 2022);
                                      var payment = Payment(
                                          paymentId: 1,
                                          amount: 39652.0,
                                          ownerId: 2,
                                          paymentDate: DateTime.now(),
                                          paymentPeriod: period);
                                      return _newListItem(index);

                                      /*return _situationWidget(
                                          index, month, 2022, payment);*/
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

  Icon _statusIcon(int index, Payment? payment) {
    var icon = const Icon(
      Icons.close,
      color: Colors.red,
    );

    if (kDebugMode) {
      print(widget.lodging.rent);
    }
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

  Widget _situationWidget(int index, String month, int year, Payment? payment) {
    Payment? value;
    var periodMonth = monthMap[payment?.paymentPeriod.month];

    if (month == periodMonth && year == payment?.paymentPeriod.year) {
      value = payment;
    }

    var icon = _statusIcon(index, value);

    return Row(
      children: [
        SizedBox(
          width: 150.0,
          child: Text(
            month,
            style: const TextStyle(fontSize: 20.0),
          ),
        ),
        //const SizedBox(width: 40,),
        Visibility(
          child: icon,
          visible: _isVisible(index, value),
        )
      ],
    );
  }

  bool _isVisible(int index, Payment? payment) {
    var actualMonth = DateTime.now().month;

    if (kDebugMode) {
      print(" month : $actualMonth");
      print(" index $index");
    }

    if (index < actualMonth || payment != null) {
      return true;
    } else {
      return false;
    }
  }

  Widget _listItem(index, month, year, Payment? payment) {
    Payment? value;
    var periodMonth = monthMap[payment?.paymentPeriod.month];

    if (month == periodMonth && year == payment?.paymentPeriod.year) {
      value = payment;
    }

    var icon = _statusIcon(index, value);
    return Container(
      padding: const EdgeInsets.all(10),
      child: ListTile(
        title: Text(
          monthMap.values.elementAt(index),
          style: const TextStyle(fontSize: 18),
        ),
        trailing: icon,
      ),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(width: 1, color: Colors.black26))),
    );
  }

  Widget _newListItem( int index) {
    var month = monthMap.values.elementAt(index);
    Payment? payment;


    payments
        .sort((a, b) => a.paymentPeriod.month.compareTo(b.paymentPeriod.month));
    if(index <payments.length) {
      payment = payments.elementAt(index);
    } else {
      payment = null;
    }

    var icon = _statusIcon(index, payment);

    return Row(
      children: [
        SizedBox(
          width: 150.0,
          child: Text(
            month,
            style: const TextStyle(fontSize: 20.0),
          ),
        ),
        //const SizedBox(width: 40,),
        Visibility(
          child: icon,
          visible: _isVisible(index, payment),
        )
      ],
    );
  }
}
