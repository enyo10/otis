import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otis/helper/helper.dart';
import 'package:otis/models/occupant.dart';
import 'package:otis/models/payment.dart';
import 'package:otis/screens/occupant_note.dart';
import 'package:otis/screens/period_payments.dart';
import 'package:otis/screens/payments_list.dart';
import 'package:otis/widgets/add_payment.dart';
import 'package:otis/widgets/number_picker.dart';
import 'package:otis/widgets/password_controller.dart';
import '../models/lodging.dart';
import '../models/note.dart';
import '../models/rent_period.dart';
import '../models/sql_helper.dart';
import '../widgets/add_comment.dart';
import '../widgets/add_occupant.dart';
import '../widgets/label_value_widget.dart';

class LodgingDetails extends StatefulWidget {
  final Lodging lodging;

  const LodgingDetails({Key? key, required this.lodging}) : super(key: key);

  @override
  State<LodgingDetails> createState() => _LodgingDetailsState();
}

class _LodgingDetailsState extends State<LodgingDetails> {
  Occupant? _occupant;

  late List<Data> monthDataList;

  late DateTime entryDate;
  bool _isLoading = true;
  Note? _note;

  late List<Rent> _rents;
  late Lodging _lodging;
  late int _year;

  @override
  initState() {
    super.initState();
    _lodging = widget.lodging;
    _year = _getPeriodYear();
    _initMonthList();
    _loadRents();
    _loadOccupantWithPayment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Le logement',
          style: GoogleFonts.charmonman(
              textStyle:
                  const TextStyle(fontSize: 25, fontWeight: FontWeight.w600)),
        ),
        actions: [
          Visibility(
            visible: _isOccupied(),
            child: Theme(
              data: Theme.of(context).copyWith(
                  textTheme: const TextTheme().apply(bodyColor: Colors.black),
                  dividerColor: Colors.white,
                  iconTheme: const IconThemeData(color: Colors.white)),
              child: PopupMenuButton<int>(
                color: Colors.black,
                itemBuilder: (context) => [
                  PopupMenuItem<int>(value: 0, child: Text(_itemValue)),
                  const PopupMenuItem<int>(
                      value: 1, child: Text("Liste des paiements")),
                  const PopupMenuDivider(),
                  PopupMenuItem<int>(
                    value: 2,
                    child: Row(
                      children: const [
                        Icon(
                          Icons.date_range,
                          color: Colors.red,
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        Text("Year")
                      ],
                    ),
                  ),
                ],
                onSelected: (item) => _selectedItem(context, item),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Visibility(
        child: FloatingActionButton(
          elevation: 10,
          onPressed: _isOccupied() ? _navigateToAddPayment : _showOccupantForm,
          child: const Icon(Icons.add),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              decoration: const BoxDecoration(
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
                    entryDate = stringValueOfDateTime(date);
                    firstname = _occupant!.firstname;
                    lastname = _occupant!.lastname;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Card(
                        elevation: 9,
                        semanticContainer: true,
                        color: const Color(0xFF99DDE9),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    LabelValueWidget(
                                        label: "Nom", value: firstname),
                                    LabelValueWidget(
                                        label: "Prenom", value: lastname),
                                    LabelValueWidget(
                                        label: "Date d'entrée",
                                        value: entryDate),
                                    LabelValueWidget(
                                        label: "Mensualité:",
                                        value: "${widget.lodging.rent} \$ "),
                                  ],
                                ),
                              ),
                              Visibility(
                                //visible: _hasComment(),
                                visible: _isOccupied(),
                                child: Row(
                                  children: [
                                    _hasComment()
                                        ? InkWell(
                                            onTap: _navigateToOccupantNote,
                                            child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 20.0),
                                                child: Text(
                                                  "i",
                                                  style: GoogleFonts.charmonman(
                                                    textStyle: const TextStyle(
                                                        fontSize: 30.0,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.red,
                                                        fontStyle:
                                                            FontStyle.italic),
                                                  ),
                                                )),
                                          )
                                        : TextButton(
                                            onPressed: () {
                                              _addOccupantNote().then(
                                                (value) => setState(() {}),
                                              );
                                            },
                                            child: Text(
                                              "C",
                                              style: GoogleFonts.charmonman(
                                                textStyle: const TextStyle(
                                                  fontSize: 30.0,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  "Status des payements en $_year",
                                  style: const TextStyle(fontSize: 20.0),
                                ),
                              ),
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
                            ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  );
                },
              ),
            ),
    );
  }

  int _getPeriodYear() {
    return DateTime.now().year;
  }

  Future<void> _loadRents() async {
    int lodgingId = _lodging.id;
    List<Rent> list = [];
    await SQLHelper.getRents(lodgingId).then((value) {
      list = value.map((e) => Rent.formMap(e)).toList();
    });
    setState(() {
      _rents = list;
    });
  }

  Future<void> _loadLodging() async {
    Lodging lodging = _lodging;
    Occupant? occupant;
    await SQLHelper.getApartment(lodging.id).then((value) async {
      lodging = value.map((e) => Lodging.fromMap(e)).toList().first;

      if (lodging.occupantId != null) {
        await SQLHelper.getOccupantById(lodging.occupantId!, lodging.id)
            .then((value) {
          occupant = value.map((e) => Occupant.fromMap(e)).toList().first;
        });
      }
    });
    setState(() {
      _lodging = lodging;
      _occupant = occupant;
    });
  }

  Future<void> _loadOccupantWithPayment() async {
    Occupant? occupant;
    if (_lodging.occupantId != null) {
      var id = _lodging.occupantId;

      await SQLHelper.getOccupantById(id!, _lodging.id).then((value) async {
        if (value.isNotEmpty) {
          occupant = value.map((e) => Occupant.fromMap(e)).toList().first;
        }
      });
      setState(() {
        _occupant = occupant;
      });
      await _loadPayments();
      await _loadComment();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadPayments() async {
    List<Payment> paymentList = [];
    _initMonthList();
    if (_occupant != null) {
      await SQLHelper.getYearPayment(_occupant!.id, _year).then((value) {
        for (var paymentMap in value) {
          paymentList.add(Payment.fromMap(paymentMap));
        }

        for (var i = 0; i < monthDataList.length; i++) {
          for (var j = 0; j < paymentList.length; j++) {
            if (monthDataList.elementAt(i).month ==
                    paymentList.elementAt(j).paymentPeriod.month &&
                _year == paymentList.elementAt(j).paymentPeriod.year) {
              monthDataList.elementAt(i).addPayment(paymentList.elementAt(j));
            }
          }
        }
      });
    }

    setState(() {});
  }

  void _initMonthList() {
    List<Data> list = [];
    for (var i = 1; i < 13; i++) {
      list.add(Data(month: i));
    }
    //  setState(() {
    monthDataList = list;

    // });
  }

  Future<void> _showOccupantForm() async {
    await showModalBottomSheet(
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

  Widget _paymentsStatus(List<Payment> paymentList, int year, int month) {
    var payments = paymentList;

    var icon = const Icon(
      Icons.close,
      color: Colors.red,
    );
    if (payments.isNotEmpty) {
      var rent = _getRent(year, month);
      var sum = _getSum(payments);

      if (sum == rent.rent) {
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

  double _getSum(List<Payment> payments) {
    var sum = 0.0;

    for (Payment payment in payments) {
      sum += payment.amount / payment.rate;
    }
    return sum;
  }

  bool _isVisible(int index, List<Payment> payments) {
    var actualYear = DateTime.now();
    var actualMonth = actualYear.month;

    if (_year < actualYear.year) {
      return true;
    }

    if (index < actualMonth || payments.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Widget _newListItem(int index) {
    var data = monthDataList.elementAt(index);

    var month = monthMap[data.month];
    //var year = DateTime.now().year;

    List<Payment> payments = data.payments;
    var icon = _paymentsStatus(payments, _year, data.month);

    return GestureDetector(
      onDoubleTap: () {
        var page = PeriodPayments(
          payments: payments,
          lodging: widget.lodging,
          occupant: _occupant!,
          data: data,
        );
        _navigateToPeriodPayment(page);
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
                Visibility(
                  visible: _isVisible(index, payments),
                  child: icon,
                )
              ],
            ),
          ),
        ),
      ),
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

  _navigateToAddPayment() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => AddPayments(
              occupant: _occupant!,
              rent: widget.lodging.rent,
              // initialPaymentPeriodDate: _occupant!.entryDate,
            ),
            fullscreenDialog: true,
          ),
        )
        .then((value) => value ? _loadOccupantWithPayment() : null)
        .onError((error, stackTrace) => null);
  }

  _navigateToPeriodPayment(StatefulWidget page) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => page,
          ),
        )
        .then((value) => _loadOccupantWithPayment())
        .onError((error, stackTrace) => null);
  }

  _loadComment() async {
    if (_occupant != null) {
      await SQLHelper.getComments(_occupant!.id)
          .then((value) => value.map((e) => Note.fromMap(e)).toList())
          .then((value) {
        if (value.isNotEmpty) {
          _note = value.first;
        } else {
          _note = null;
        }
      });
    } else {
      _note = null;
    }
    setState(() {});
  }

  Future<void> _terminateLease() async {
    var passwordController = const PasswordController(title: "Résiliation");

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return passwordController;
        }).then((value) async {
      if (value) {
        await _showRemoveOwnerDialog();
      }
    });
  }

  _navigateToOccupantNote() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => OccupantNote(
              note: _note!,
              occupant: _occupant!,
            ),
          ),
        )
        .then((value) => _loadComment());
  }

  Future<void> _addOccupantNote() async {
    var passwordController = const PasswordController(title: "Actualiser note");

    await showDialog(
        context: context,
        builder: (context) {
          return passwordController;
        }).then((value) async {
      if (value!) {
        showModalBottomSheet(
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40.0),
            ),
            context: context,
            builder: (BuildContext ctx) {
              return AddComment(ownerId: _occupant!.id, note: _note);
            }).then((value) => _loadComment());
      } else {
        showMessage(context, "Saisir mot de passe correcte");
      }
    });
  }

  bool _hasComment() {
    if (!_isOccupied()) {
      return false;
    } else {
      return _note != null;
    }
  }

  Rent _getRent(int year, int month) {
    var date = DateTime(year, month);
    var rent = _rents[0];
    for (int i = 0; i < _rents.length; i++) {
      if (_rents[i].endDate == null) {
        if (date.microsecondsSinceEpoch >=
            _rents[i].startDate.microsecondsSinceEpoch) {
          rent = _rents[i];
        }
      } else {
        if (date.microsecondsSinceEpoch >=
                _rents[i].startDate.microsecondsSinceEpoch &&
            date.microsecondsSinceEpoch <=
                _rents[i].endDate!.microsecondsSinceEpoch) {
          rent = _rents[i];
        }
      }
    }
    return rent;
  }

  Future<void> _addRemoveOccupant() async {
    _isOccupied() ? await _terminateLease() : await _showOccupantForm();
  }

  String get _itemValue =>
      _isOccupied() ? "Resilier bail " : "Ajouter locataire";

  void _selectedItem(BuildContext context, item) {
    switch (item) {
      case 0:
        _addRemoveOccupant();
        break;
      case 1:
        if (_isOccupied()) {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (_) => PaymentsList(occupant: _occupant!),
                ),
              )
              .then((value) => _loadOccupantWithPayment());
        }
        break;
      case 2:
        //  _showYearPicker();
        _selectYear();
        break;
    }
  }

  Future<void> _selectYear() async {
    await showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      context: context,
      builder: (context) {
        return SizedBox(
          height: 400,
          child: OtisPickedNumber(
            currentValue: _year,
            minValue: _occupant?.entryDate.year ?? _year,
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          _year = value;
          _loadPayments();
        });
      }
    });
  }
}
