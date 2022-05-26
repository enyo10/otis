import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otis/models/occupant.dart';
import 'package:otis/models/payment.dart';
import 'package:otis/models/sql_helper.dart';


import '../models/period.dart';

class AddPayments extends StatefulWidget {
  final Occupant occupant;
  final DateTime initialDate;
  final double rent;

 const AddPayments(
      {Key? key,
      required this.occupant,
      required this.rent,
      required this.initialDate})
      : super(key: key);

  @override
  State<AddPayments> createState() => _AddPaymentsState();
}

class _AddPaymentsState extends State<AddPayments> {
  final TextEditingController _dollarPaymentController =
      TextEditingController();

  final TextEditingController _taxController = TextEditingController();

  double amountInDollar = 0.0;
  DateTime _selectedDate = DateTime.now();
  String _currency = '\$';
  late DateTime selectedPaymentDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.occupant.entryDate;
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
                            labelText: 'Payement en Dollar',
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
                          _showDatePicker();
                        },
                        child: const Text("Date de payement")),
                    const SizedBox(
                      width: 15.0,
                    ),
                    Text(
                        "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}")
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 30),
                child: IconButton(
                    onPressed: () {
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

  double convertToDollar(double cdfAmount, double tax) {
    return cdfAmount / tax;
  }

  double convertToCDF(double dollarAmount, double tax) {
    return dollarAmount * tax;
  }

  _showDatePicker() {
    showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2050))
        .then((date) => {
              if (date != null)
                {
                  setState(() {
                    _selectedDate = date;
                  })
                }
            });
  }

  Future<int> _addPayment(
      int ownerId, int year, int month, double amount) async {
    double totalAmount = 0;

    List<Payment> payments =
        await SQLHelper.getPeriodPayments(ownerId, year, month)
            .then((value) => value.map((e) => Payment.fromMap(e)).toList());

    for (Payment payment in payments) {
      totalAmount += payment.amount;
    }
    if (totalAmount < widget.rent) {
      var paymentDate = _selectedDate;
      var periodOfPayment = Period(month: month, year: year);
      double rate;
      if (_currency == '\$') {
        rate = 1;
      } else {
        rate = double.parse(_taxController.text);
      }

      return SQLHelper.insertPayment(
          ownerId, amount, paymentDate, periodOfPayment, _currency, rate);
    }
    return 0;
  }
}

