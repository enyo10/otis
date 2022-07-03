import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otis/helper/helper.dart';
import 'package:otis/models/occupant.dart';
import 'package:otis/models/payment.dart';
import 'package:otis/screens/payment_details.dart';
import 'package:otis/screens/payments_list.dart';
import 'package:otis/widgets/add_payment.dart';
import 'package:otis/widgets/password_controller.dart';
import '../models/lodging.dart';
import '../models/rent_period.dart';
import '../models/sql_helper.dart';
import '../widgets/add_occupant.dart';

class LodgingDetails extends StatefulWidget {
  final Lodging lodging;

  const LodgingDetails({Key? key, required this.lodging}) : super(key: key);

  @override
  State<LodgingDetails> createState() => _LodgingDetailsState();
}

class _LodgingDetailsState extends State<LodgingDetails> {
  Occupant? _occupant;

  late List<Data> monthDataList;
  List<Payment> payments = [];
  //late int ownerId;
  late DateTime entryDate;
  bool _isLoading = true;

  late List<Rent> _rents;
  late Lodging _lodging;

  @override
  initState() {
    _lodging = widget.lodging;
    _loadRents();
    _initMonthList();
    _loadOccupantWithPayment();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /*return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Visibility(
          visible: _isOccupied(),
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Logement'),
            actions: [
              _actionIcon(),
              Visibility(visible: _isOccupied(), child: _changedOwner())
            ],
            floating: true,
            flexibleSpace: Placeholder(),
            expandedHeight: 200,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, index) {
                return _newListItem(index);
              },
              childCount: monthDataList.length,
            ),
          ),
        ],
      ),
    );*/
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logement'),
        actions: [
          _actionIcon(),
          Visibility(visible: _isOccupied(), child: _changedOwner())
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Visibility(
          visible: _isOccupied(),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (context) => AddPayments(
                        occupant: _occupant!,
                        rent: widget.lodging.rent,
                        initialPaymentPeriodDate: _occupant!.entryDate,
                      ),
                      fullscreenDialog: true,
                    ),
                  )
                  .then((value) => value ? _loadOccupantWithPayment() : null)
                  .onError((error, stackTrace) => null);
            },
            style: ElevatedButton.styleFrom(
                //  primary: Colors.purple,
                // padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                padding: const EdgeInsets.all(10),
                textStyle:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            autofocus: true,
            child: const Text(" Ajouter payement "),
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
                  if (_occupant != null) {
                    DateTime date = _occupant!.entryDate;
                    entryDate = '${date.day}/${date.month}/${date.year}';
                    firstname = _occupant!.firstname;
                    lastname = _occupant!.lastname;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        child: Card(
                          margin: const EdgeInsets.all(0.0),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
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
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
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
                                padding: const EdgeInsets.only(left: 10),
                                width: 150.0,
                                child: const Text(
                                  "Mois",
                                  style: TextStyle(fontSize: 20.0),
                                ),
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
                      !_isOccupied()
                          ? const Center(
                              child: Text(
                                "Pas d'occupant",
                                style: TextStyle(fontSize: 25.0),
                              ),
                            )
                          : Expanded(
                              flex: 1,
                              child: ListView.builder(
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

  _loadRents() async {
    int lodgingId = _lodging.id;
    List<Rent> list = [];
    await SQLHelper.getRents(lodgingId).then((value) {
      list = value.map((e) => Rent.formMap(e)).toList();
    });
    setState(() {
      _rents = list;
    });
  }

  _loadLodging() async {
    Lodging lodging = _lodging;
    Occupant? occupant;
    await SQLHelper.getApartment(lodging.id).then((value) async {
      lodging = value.map((e) => Lodging.fromMap(e)).toList().first;
      print(" in load Loading : lodging id --> ${lodging.id}");
      print(" Occupant id : ${lodging.occupantId}");
      if (lodging.occupantId != null) {
        await SQLHelper.getOccupantById(lodging.occupantId!, lodging.id)
            .then((value) {
          occupant = value.map((e) => Occupant.fromMap(e)).toList().first;
          if (kDebugMode) {
            print(" Occupant id:  ${occupant?.id}");
          }
        });
      }
    });
    setState(() {
      _lodging = lodging;
      _occupant = occupant;
    });
  }

  _loadOccupantWithPayment() async {
    print("in load Occupant lodging with occupant id ${_lodging.occupantId}");
    Occupant? occupant;
    if (_lodging.occupantId != null) {
      if (kDebugMode) {
        print(" Occupant id : ${_lodging.occupantId}");
      }
      var id = _lodging.occupantId;

      await SQLHelper.getOccupantById(id!, _lodging.id).then((value) async {
        if (value.isNotEmpty) {
          if (kDebugMode) {
            print("Value ist not empty");
          }
          occupant = value.map((e) => Occupant.fromMap(e)).toList().first;
         // await _loadPayments();
        }
      });
      setState(() {
        _occupant = occupant;
      });
      await _loadPayments();
    }

    setState(() {
      _isLoading = false;
    });
  }

  _loadPayments() async {
    List<Payment> paymentList = [];
    _initMonthList();
    if (_occupant != null) {
      print("in load payment");
      await SQLHelper.getCurrentYearPayment(_occupant!.id).then((value) {
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
    }

    setState(() {});
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => AddOccupantForm(
        lodging: _lodging,
      ),
    ).then((value) {
      _loadLodging();
    });
  }

  bool _isOccupied() => _lodging.occupantId != null;

  double _getSum(List<Payment> payments) {
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

  Widget _paymentsStatus(List<Payment> paymentList) {
    var payments = paymentList;
    var icon = const Icon(
      Icons.close,
      color: Colors.red,
    );
    if (payments.isNotEmpty) {
      var period = payments.elementAt(0).paymentPeriod;
      var date = DateTime(period.year, period.month);
      var rent = _getRent(date);
      var sum = _getSum(payments);

      if (sum == rent?.rent) {
        icon = const Icon(
          Icons.check,
          color: Colors.green,
        );
      } else {
        print("Not Equal");

        icon = const Icon(
          Icons.check_box_outlined,
          color: Colors.orange,
        );
      }
    }

    return icon;
  }

  Rent? _getRent(DateTime dateTime) {
    Rent? rent;
    for (Rent value in _rents) {
      if (value.startDate.microsecondsSinceEpoch <
          dateTime.microsecondsSinceEpoch) {
        rent = value;
      }
    }
    return rent;
  }

  Widget _newListItem(int index) {
    var data = monthDataList.elementAt(index);
    var month = monthMap[data.month];

    List<Payment> payments = data.payments;
    var icon = _paymentsStatus(payments);

    return GestureDetector(
      onDoubleTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentDetails(payments: payments),
            fullscreenDialog: true,
          ),
        );
      },
      child: SizedBox(
        child: Card(
          elevation: 5,
          // margin: const EdgeInsets.only(top: 20, right: 20, left: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
          ),
        ),
      ),
    );
  }

  Widget _actionIcon() {
    return _isOccupied()
        ? IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PaymentsList(occupant: _occupant!),
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
      onPressed: () async {
        var passwordController = const PasswordController(title: "Résiliation");

        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return passwordController;
            }).then((value) {
          if (value) {
            _showRemoveOwnerDialog();
          }
        });
      },
      icon: const Icon(Icons.remove_circle_rounded),
    );
  }

  Future<void> _showRemoveOwnerDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'ATTENTION',
            style: TextStyle(color: Colors.red),
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
              onPressed: () async {
                await _removeOccupant();

                if (!mounted) return;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeOccupant() async {
    var lodging = widget.lodging;
    await SQLHelper.updateApartment(lodging.id, lodging.floor, lodging.rent,
            lodging.address, lodging.description, null)
        .then((value) {
      _loadLodging();
    });
  }
}
