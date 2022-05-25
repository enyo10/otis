import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:otis/helper.dart';

import '../models/payment.dart';

class PaymentDetails extends StatefulWidget {
  final List<Payment>payments;
  const PaymentDetails({Key? key, required this.payments}) : super(key: key);

  @override
  State<PaymentDetails> createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Payment> payments;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    payments = widget.payments;

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Details du payment"),
        ),
        body: ListView.builder(
            itemCount: payments.length,
            itemBuilder: (_, index) {
              var payment = payments.elementAt(index);
          return ListTile(
            textColor: Colors.black,
            title: Text(" ${payment.amount} ${payment.currency}"),
            trailing: Text(" ${stringValue(payment.paymentDate)}"),
          )
            /*Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Date : ${payment.paymentDate}"),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Amount : ${payment.amount}"),
              ),
              Text("Devise ${payment.currency}")
            ],

          )*/;
        }));
  }
}