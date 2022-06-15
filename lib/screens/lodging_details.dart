import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otis/helper.dart';
import 'package:otis/models/occupant.dart';
import 'package:otis/models/payment.dart';
import 'package:otis/screens/payment_details.dart';
import 'package:otis/screens/payments_list.dart';
import 'package:otis/widgets/add_payment.dart';
import 'package:otis/widgets/icon_widget.dart';

import '../models/lodging.dart';
import '../models/rent_period.dart';
import '../models/sql_helper.dart';
import '../widgets/add_occupant_form.dart';

class LodgingDetails extends StatefulWidget {
  final Lodging lodging;

  const LodgingDetails({Key? key, required this.lodging}) : super(key: key);

  @override
  State<LodgingDetails> createState() => _LodgingDetailsState();
}

class _LodgingDetailsState extends State<LodgingDetails> {
  Map<String, dynamic>? _occupantMap;
  List<Map<String, dynamic>> _occupants = [];
  late Occupant occupant;

  late List<Data> monthDataList;
  late int ownerId;
  late DateTime entryDate;
  bool _isLoading = true;

  @override
  initState() {
    super.initState();
    _initMonthList();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logement'),
        actions: [
          _actionIcon(),
          Visibility(visible: isOccupied(), child: _changedOwner())
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
                      builder: (context) => AddPayments(
                        occupant: occupant,
                        rent: widget.lodging.rent,
                        initialPaymentPeriodDate: occupant.entryDate,
                      ),
                      fullscreenDialog: true,
                    ),
                  )
                  .then((value) => value ? _loadData() : null)
                  .onError((error, stackTrace) => null);
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
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              decoration: const BoxDecoration(
                //  color: Colors.orangeAccent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Builder(
                builder: (context) {
                  var entryDate = '   -';
                  var firstname = '   -';
                  var lastname = '    -';
                  if (_occupantMap != null) {
                    DateTime date = DateTime.parse(_occupantMap!['entry_date']);
                    entryDate = '${date.day}/${date.month}/${date.year}';
                    firstname = ' ${_occupantMap!['firstname']}';
                    lastname = ' ${_occupantMap!['lastname']}';
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Card(
                          margin: const EdgeInsets.all(0.0),
                          elevation: 5,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Row(
                                  children: [
                                    const Text(
                                      "Nom:",
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                    Text(
                                      " : $firstname ",
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
                                      lastname,
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
                                      entryDate,
                                      style: const TextStyle(fontSize: 20.0),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
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
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 0),
                        child: Container(
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
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      !isOccupied()
                          ? const Center(
                              child: Text(
                                "Pas d'occupant",
                                style: TextStyle(fontSize: 25.0),
                              ),
                            )
                          : Expanded(
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

  Future<Rent?> _loadRentMap(int lodgingId, DateTime dateTime) async {
    Rent? rent;
    await SQLHelper.getRents(lodgingId).then((value) {
      for (dynamic rentMap in value) {
        if (Rent.formMap(rentMap).startDate.microsecondsSinceEpoch <
            dateTime.microsecondsSinceEpoch) {
          rent = Rent.formMap(rentMap);
        }
      }
    });
    return rent;
  }

  _loadData() async {
    await SQLHelper.getOccupantsWithLodgingId(widget.lodging.id).then((value) {
      if (value.isNotEmpty) {
        _occupants = value;
        _occupantMap = _occupants.first;
        ownerId = _occupantMap!['id'];
        occupant = Occupant.fromMap(_occupantMap!);

        _loadPayments();
      }
    });

    setState(() {
      _isLoading = false;
    });
  }

  _loadPayments() async {
    if (_occupants.isNotEmpty) {
      List<Payment> paymentList = [];
      _initMonthList();

      await SQLHelper.getCurrentYearPayment(ownerId).then((value) {
        print("Payment map size ${value.length}");
        for (var paymentMap in value) {
          paymentList.add(Payment.fromMap(paymentMap));
        }

        for (var i = 0; i < monthDataList.length; i++) {
          for (var j = 0; j < paymentList.length; j++) {
            if (monthDataList.elementAt(i).month ==
                paymentList.elementAt(j).paymentPeriod.month) {
              monthDataList.elementAt(i).addPayment(paymentList.elementAt(j));
            }
          }
        }
      });
      setState(() {
        //_payments = paymentList;
        //monthDataList = monthDataList;
        print("Monate list : ${monthDataList.elementAt(0).payments.length}");
      });
    }
  }

  _initMonthList() {
    List<Data> list = [];
    for (var i = 0; i < 12; i++) {
      list.add(Data(month: i + 1));
    }
    setState(() {
      monthDataList = list;
    });
  }

  _showOccupantForm() {
    var id = widget.lodging.id;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => AddOccupantForm(
        lodgingId: id,
      ),
    ).then((value) => _loadData());
  }

  bool isOccupied() => _occupantMap != null;

  double getSum(List<Payment> payments) {
    var sum = 0.0;

    for (Payment payment in payments) {
      sum += payment.amount / payment.rate;
    }
    return sum;
  }

  bool _isVisible(int index, List<Payment> payments) {
    var actualMonth = DateTime.now().month;

    if (index < actualMonth || payments.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Widget _newListItem(int index) {
    var data = monthDataList.elementAt(index);
    var month = monthMap[data.month];

    List<Payment> payments = data.payments;

    // var icon = _statusIcon(payments);
    // var icon = _widgetStatus(payments);
    var icon = IconWidget(
      payments: payments,
      id: widget.lodging.id,
    );

    return GestureDetector(
      onDoubleTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentDetails(payments: payments),
            fullscreenDialog: true,
          ),
        );
      },
      child: Row(
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
            visible: _isVisible(index, payments),
          )
        ],
      ),
    );
  }

  Widget _actionIcon() {
    return isOccupied()
        ? IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PaymentsList(occupant: occupant),
                ),
              );
            },
            icon: const Icon(
              Icons.info,
              size: 25.0,
            ),
          )
        : IconButton(
            onPressed: () {
              _showOccupantForm();
            },
            icon: const Icon(Icons.add));
  }

  Widget _changedOwner() {
    return IconButton(
      onPressed: () {
        _showChangeOwnerDialog();
      },
      icon: const Icon(Icons.remove_circle_rounded),
    );
  }

  Future<void> _showChangeOwnerDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'ATTENTION',
            //style: TextStyle(color: Colors.red),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Le locataire quitte vraiment son logement?'),
                Text('Voulez vous vraiment le faire?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Continuer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
