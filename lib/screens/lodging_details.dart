import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otis/helper.dart';
import 'package:otis/models/occupant.dart';
import 'package:otis/models/payment.dart';
import 'package:otis/screens/payment_details.dart';
import 'package:otis/screens/payments_list.dart';
import 'package:otis/widgets/add_payment.dart';
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

  late List<Rent> _rents;

  @override
  initState() {
    super.initState();
    _loadRents(widget.lodging.id);
    _initMonthList();
    _loadData();
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

  _loadRents(int lodgingId) async {
    List<Rent> list = [];
    await SQLHelper.getRents(lodgingId).then((value) {
      list = value.map((e) => Rent.formMap(e)).toList();
    });
    setState(() {
      _rents = list;
    });
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
      setState(() {});
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

  bool _isOccupied() => _occupantMap != null;

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
