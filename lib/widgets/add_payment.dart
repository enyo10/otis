import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otis/models/occupant.dart';
import 'package:otis/models/payment.dart';
import 'package:otis/models/sql_helper.dart';
import 'package:month_picker_dialog_2/month_picker_dialog_2.dart';

import '../helper/helper.dart';
import '../models/period.dart';
import '../models/rent_period.dart';

class AddPayments extends StatefulWidget {
  final Occupant occupant;
  // final DateTime initialPaymentPeriodDate;
  final double rent;
  final DateTime? paymentPeriod;

  const AddPayments(
      {Key? key,
      required this.occupant,
      required this.rent,
      // required this.initialPaymentPeriodDate,
      this.paymentPeriod})
      : super(key: key);

  @override
  State<AddPayments> createState() => _AddPaymentsState();
}

class _AddPaymentsState extends State<AddPayments> {
  final TextEditingController _amountController = TextEditingController();

  final TextEditingController _taxController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  double amountInDollar = 0.0;
  late DateTime _selectedPaymentDate;
  String _currency = currencies.elementAt(0);
  late DateTime _selectedPeriodDate;
  bool _hasPeriod = false;
  bool _currencyIsUSD = true;

  @override
  void initState() {
    super.initState();
    _initPaymentPeriod();
    _selectedPaymentDate = DateTime.now();
    _updateTaxValue();
  }

  _initPaymentPeriod() {
    if (widget.paymentPeriod != null) {
      _selectedPeriodDate = widget.paymentPeriod!;
      _hasPeriod = true;
    } else {
      _selectedPeriodDate = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(" Ajouter payement"),
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
                        controller: _amountController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Payement ',
                            hintText: 'Enter payement en \$'),
                        style: Theme.of(context).textTheme.labelLarge,
                        keyboardType: const TextInputType.numberWithOptions(
                            signed: true, decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'(^-?\d*\.?\d*)')),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: DropdownButton<String>(
                          value: _currency,
                          items: currencies
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem(
                              value: value,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  value,
                                  style: const TextStyle(fontSize: 30),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _currency = newValue!;
                            });
                            _updateTaxValue();
                          }),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: !_currencyIsUSD,
                child: Padding(
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
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 30),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      flex: 2,
                      child: TextField(
                        controller: _descController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Ajouter commentaire',
                            hintText: 'Commentaire'),
                        style: Theme.of(context).textTheme.labelLarge,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
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
              //  SizedBox()
              Visibility(
                  visible: !_hasPeriod,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 30),
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
                        Text("${_selectedPeriodDate.month}/"
                            "${_selectedPeriodDate.year}")
                      ],
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 30),
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
                    Text("${_selectedPaymentDate.day}/"
                        "${_selectedPaymentDate.month}/"
                        "${_selectedPaymentDate.year}")
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
                    await _addPayment();
                    if (!mounted) return;
                    Navigator.of(context).pop(true);
                  },
                  icon: const Icon(
                    Icons.save,
                    size: 35,
                    color: Colors.red,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPaymentMontPicker(BuildContext context) async {
    showMonthPicker(
      context: context,
      initialDate: _selectedPeriodDate,
      firstDate: widget.occupant.entryDate,
      unselectedMonthTextColor: Colors.black,
    ).then((date) => {
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
      firstDate: widget.occupant.entryDate,
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

  void _updateTaxValue() {
    if (_currency == currencies.elementAt(0)) {
      _taxController.text = 1.toString();
      _currencyIsUSD = true;
    } else {
      _taxController.clear();
      _currencyIsUSD = false;
    }
    setState(() {});
  }

  bool _checkValues() {
    if (_amountController.text.isNotEmpty && _taxController.text.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<Rent?> _loadRentMap(DateTime dateTime) async {
    Rent? rentValue;
    await SQLHelper.getRents(widget.occupant.lodgingId).then((value) {
      for (dynamic rent in value) {
        if (Rent.formMap(rent).startDate.microsecondsSinceEpoch <=
            dateTime.microsecondsSinceEpoch) {
          rentValue = Rent.formMap(rent);
        }
      }
    });
    return rentValue;
  }

  Future<int> _addPayment() async {
    int id = 0;
    if (!_checkValues()) {
      var message = 'Saisir le montant';
      showMessage(context, message);
      return id;
    } else {
      double totalAmount = 0;
      var ownerId = widget.occupant.id;
      var year = _selectedPeriodDate.year;
      var month = _selectedPeriodDate.month;
      var amount = double.parse(_amountController.text);

      List<Payment> payments =
          await SQLHelper.getPeriodPayments(ownerId, year, month)
              .then((value) => value.map((e) => Payment.fromMap(e)).toList());

      for (Payment payment in payments) {
        totalAmount += payment.amount / payment.rate;
      }

      Rent? rentData = await _loadRentMap(DateTime(year, month));
      if (rentData != null) {
        print("+++++++++ Load rent data not null +++++++++");
        double rate = double.parse(_taxController.text);
        var amountValue = amount / rate;
        var newValue = totalAmount + amountValue;

        if (newValue <= rentData.rent) {
          var paymentDate = _selectedPaymentDate;
          var periodOfPayment = Period(month: month, year: year);
          var desc = _descController.text;

          await SQLHelper.insertPayment(ownerId, amount, paymentDate,
                  periodOfPayment, _currency, rate, desc)
              .then((value) {
            id = value;
            showMessage(context, ' Le payement est enrégistré');
          });

          return id;
        }
      }else{
        print("+++++++++ Load rent data is null +++++++++");
      }


    }
    if (mounted) {
      showMessage(context, 'Erreur: Verifiez les données');
    }
    return id;
  }
}
