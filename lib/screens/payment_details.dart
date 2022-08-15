import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otis/models/payment.dart';

import '../helper/helper.dart';

class PaymentDetails extends StatelessWidget {
  final Payment payment;
  const PaymentDetails({Key? key, required this.payment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var desc = (payment.desc == '') ? 'Description null' : payment.desc;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFEFFFFD),
          elevation: 0.0,
          iconTheme: const IconThemeData(
            color: Colors.red,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NewWidget(
                data: payment.paymentPeriod.toString(),
                text: 'Mois',
              ),
              NewWidget(data: payment.amount.toString(), text: "Montant"),
              NewWidget(data: payment.currency, text: "Devise"),
              NewWidget(
                  data: stringValue(payment.paymentDate), text: "Date payement"),
              const NewWidget(data: "", text: "Commentaire"),
              Card(
                elevation: 5,
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    desc,
                    style: const TextStyle(
                        fontSize: 20, fontStyle: FontStyle.italic),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class NewWidget extends StatelessWidget {
  const NewWidget({Key? key, required this.data, required this.text})
      : super(key: key);

  final String data;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        " $text: $data",
        style: const TextStyle(
          fontSize: 20,
        ),
      ),
    );
  }
}
