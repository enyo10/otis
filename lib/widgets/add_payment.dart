import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:otis/models/occupant.dart';
import 'package:otis/models/payment.dart';
import 'package:otis/models/sql_helper.dart';

import '../models/period.dart';

class AddPayments extends StatefulWidget {
  final Occupant occupant;
  final DateTime initialPaymentPeriodDate;
  final double rent;

  const AddPayments(
      {Key? key,
      required this.occupant,
      required this.rent,
      required this.initialPaymentPeriodDate})
      : super(key: key);

  @override
  State<AddPayments> createState() => _AddPaymentsState();
}

class _AddPaymentsState extends State<AddPayments> {
  final TextEditingController _dollarPaymentController =
      TextEditingController();

  final TextEditingController _taxController = TextEditingController();

  double amountInDollar = 0.0;
  late DateTime _selectedPaymentDate;
  String _currency = '\$';
  late DateTime _selectedPeriodDate;

  @override
  void initState() {
    super.initState();
    _selectedPeriodDate = DateTime.now();
    _selectedPaymentDate = _selectedPeriodDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(" add Payment"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Padding(
                padding: EdgeInsets.all(30.0),
                child: Center(
                  child: Text(
                    "Payement: \$ , CDF",
                    style: TextStyle(fontSize: 25),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      flex: 2,
                      child: TextField(
                        controller: _dollarPaymentController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Payement ',
                            hintText: 'Enter payement en \$'),
                        style: Theme.of(context).textTheme.labelLarge,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'(^\d*\.?\d*)')),
                        ],
                      ),
                    ),
                    Flexible(
                        flex: 1,
                        child: DropdownButton<String>(
                            value: _currency,
                            items: ["\$", "CDF"]
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem(
                                  value: value,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      value,
                                      style: const TextStyle(fontSize: 30),
                                    ),
                                  ));
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _currency = newValue!;
                              });
                            })),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 30),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      flex: 2,
                      child: TextField(
                        controller: _taxController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Entrer le taux',
                            hintText: 'Taux de conversion'),
                        style: Theme.of(context).textTheme.labelLarge,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'(^\d*\.?\d*)')),
                        ],
                      ),
                    ),
                    const Flexible(
                      flex: 1,
                      child: Text(
                        " ",
                        style: TextStyle(fontSize: 30.0),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text("Check"),
                    ),
                    const SizedBox(
                      width: 15.0,
                    ),
                    const Text("")
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          _showPaymentMontPicker(context);
                        },
                        child: const Text("Periode de payement")),
                    const SizedBox(
                      width: 15.0,
                    ),
                    Text(
                        "${_selectedPeriodDate.month}/${_selectedPeriodDate.year}")
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          _showPaymentDatePicker();
                        },
                        child: const Text("Date de payement")),
                    const SizedBox(
                      width: 15.0,
                    ),
                    Text(
                        "${_selectedPaymentDate.day}/${_selectedPaymentDate.month}/${_selectedPaymentDate.year}")
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 30),
                child: IconButton(
                    onPressed: () async {
                      if (kDebugMode) {
                        print("Avant add payment");
                      }
                      await _addPayment();
                      if (kDebugMode) {
                        print("Après add payment");
                      }
                      Navigator.of(context).pop(true);
                      // Navigator.pop(context, true);
                    },
                    icon: const Icon(
                      Icons.save,
                      size: 35,
                      color: Colors.red,
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentMontPicker(BuildContext context) {
    showMonthPicker(
            context: context,
            initialDate: _selectedPeriodDate,
            firstDate: widget.initialPaymentPeriodDate)
        .then((date) => {
              if (date != null)
                {
                  setState(() {
                    _selectedPeriodDate = date;
                  })
                }
            });
  }

  void _showPaymentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedPaymentDate,
      firstDate: widget.initialPaymentPeriodDate,
      lastDate: DateTime(2050),
    ).then((date) => {
          if (date != null)
            {
              setState(() {
                _selectedPaymentDate = date;
              })
            }
        });
  }

  double convertToDollar(double cdfAmount, double tax) {
    return cdfAmount / tax;
  }

  double convertToCDF(double dollarAmount, double tax) {
    return dollarAmount * tax;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  bool _checkValues() {
    if (_currency == '\$') {
      _taxController.text = 1.toString();
    }
    if (_dollarPaymentController.text.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<int> _addPayment() async {
    int id = 0;
    if (!_checkValues()) {
      var message = 'Saisir le montant';
      _showMessage(message);
      return id;
    } else {
      double totalAmount = 0;
      var ownerId = widget.occupant.id;
      var year = _selectedPeriodDate.year;
      var month = _selectedPeriodDate.month;
      var amount = double.parse(_dollarPaymentController.text);

      List<Payment> payments =
          await SQLHelper.getPeriodPayments(ownerId, year, month)
              .then((value) => value.map((e) => Payment.fromMap(e)).toList());

      for (Payment payment in payments) {
        totalAmount += payment.amount;
      }
      if (totalAmount < widget.rent) {
        var paymentDate = _selectedPaymentDate;
        var periodOfPayment = Period(month: month, year: year);
        double rate;
        if (_currency == '\$') {
          rate = 1;
        } else {
          rate = double.parse(_taxController.text);
        }

        id = await SQLHelper.insertPayment(
            ownerId, amount, paymentDate, periodOfPayment, _currency, rate);

        _showMessage(' Le payement est enrégistré');
        return id;
      }
      _showMessage('Erreur: Vérifier les champs');

    }
    return id ;
  }
}
