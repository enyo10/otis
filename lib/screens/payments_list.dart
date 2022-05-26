import 'package:flutter/material.dart';
import 'package:otis/models/occupant.dart';
import 'package:otis/models/sql_helper.dart';

import '../helper.dart';
import '../models/payment.dart';

class PaymentsList extends StatefulWidget {
  final Occupant occupant;
  const PaymentsList({Key? key, required this.occupant}) : super(key: key);

  @override
  State<PaymentsList> createState() => _PaymentsListState();
}

class _PaymentsListState extends State<PaymentsList> {
  List<Payment> _payments = [];

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Les payements"),
      ),
      body: ListView.builder(
          itemCount: _payments.length,
          itemBuilder: (_, index) {
            var payment = _payments.elementAt(index);
            return Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Card(
                //semanticContainer: false,
                shadowColor: Colors.green,
                elevation: 8.0,
                /*shape: OutlineInputBorder(*/
                /*    borderRadius: BorderRadius.circular(10),*/
                /*    borderSide: const BorderSide(color: Colors.white))*/
                child: Container(
                  child: ListTile(
                    textColor: Colors.black,
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        payment.paymentPeriod.toString(),
                      ),
                    ),
                    title: Text(" ${payment.amount} ${payment.currency}"),
                    trailing: Text(
                      " ${stringValue(payment.paymentDate)}",
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  _loadPayments() async {
    var list = await SQLHelper.getPayments(widget.occupant.id)
        .then((value) => value.map((e) => Payment.fromMap(e)).toList());

    setState(() {
      _payments = list;
    });
  }
}
