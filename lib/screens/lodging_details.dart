import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otis/helper.dart';
import 'package:otis/models/payment.dart';
import 'package:otis/widgets/payment_form.dart';

import '../models/lodging.dart';
import '../models/sql_helper.dart';
import '../widgets/occupant_form.dart';

class LodgingDetails extends StatefulWidget {
  final Lodging lodging;
  const LodgingDetails({Key? key, required this.lodging}) : super(key: key);

  @override
  State<LodgingDetails> createState() => _LodgingDetailsState();
}

class _LodgingDetailsState extends State<LodgingDetails> {
  Map<String, dynamic>? _occupantMap;
  List<Map<String, dynamic>> _occupants = [];
  final int _currentMonth = DateTime.now().month;
  List<Data> monthDataList = dataList;

  List<Payment> _payments = [];
  late int ownerId;
  late DateTime entryDate;
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
            onPressed: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (context) => AddPayment(
                        initialDate: DateTime.now(),
                        ownerId: ownerId,
                      ),
                      fullscreenDialog: false,
                    ),
                  )
                  .then((value) =>  _loadPayments() );
            },
            style: ElevatedButton.styleFrom(
                //  primary: Colors.purple,
                // padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                padding: const EdgeInsets.all(10),
                textStyle:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            child: const Text(" Ajouter payement "),
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
                      child: Text("Pas d'occupant", style: TextStyle(
                        fontSize: 25.0
                      ),),
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
                                        style: const TextStyle(fontSize: 20.0),
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
                                        style: const TextStyle(fontSize: 20.0),
                                      ),
                                    ],
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 10, bottom: 30),
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
                                  itemCount: monthDataList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return _newListItem(index);
                                  }),
                            )
                          ],
                        );
                      },
                    ),
            ),
    );
  }

  _loadData() async {
    var occupantData =
        await SQLHelper.getOccupantsWithLodgingId(widget.lodging.id)
            .then((value) {
      if (value.isNotEmpty) {
        _occupants = value;
        _occupantMap = _occupants.first;
        ownerId = _occupantMap!['id'];

        _loadPayments();

      }
    });

    setState(() {
      _isLoading = false;

    });
  }

  _loadPayments() async {
    List<Payment> paymentList = [];

    await SQLHelper.getCurrentYearPayment(ownerId).then((value) {
      for (var element in value) {
        paymentList.add(Payment.fromMap(element));
      }
    });
    setState(() {
      _payments = paymentList;

    });
    _updateMonthList();

    if (kDebugMode) {
      print("payments size ${_payments.length}");
    }
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
    ).then((value) => _loadData());
  }

  bool isOccupied() => _occupantMap != null;

  Icon _statusIcon( Payment? payment) {
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

  bool _isVisible(int index, Payment? payment) {
    var actualMonth = DateTime.now().month;

    if (index < actualMonth || payment != null) {
      return true;
    } else {
      return false;
    }
  }

  _updateMonthList() {
    if (kDebugMode) {
      print("payment size ${_payments.length}");
    }
    for (var element in _payments) {
      if (kDebugMode) {
        print("Element ---- month${element.paymentPeriod.month}");
      }
    }

    for (int i = 0; i < monthDataList.length - 1; i++) {
      for (int j = 0; j < _payments.length - 1; j++) {
        if (monthDataList.elementAt(i).month ==
            _payments.elementAt(j).paymentPeriod.month) {
          setState(() {
            monthDataList.elementAt(i).payment = _payments.elementAt(j);
          });

          if (kDebugMode) {
            print("in update ${monthDataList.elementAt(i).payment}");
          }

        }
      }
    }

    if (kDebugMode) {
      print("in update payment list ${_payments.length}");
    }

  }

  Widget _newListItem(int index) {
    var data = monthDataList.elementAt(index);
    var month = monthMap[data.month];

    Payment? payment= data.payment;
    print("payment $payment");

    var icon = _statusIcon( payment);

    return Row(
      children: [
        SizedBox(
          width: 150.0,
          child: Text(
            month!,
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
