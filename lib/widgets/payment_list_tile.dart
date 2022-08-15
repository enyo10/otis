import 'package:flutter/material.dart';
import 'package:otis/screens/payment_details.dart';

import '../helper/helper.dart';
import '../models/payment.dart';

class PaymentListTile extends StatelessWidget {
  const PaymentListTile({
    Key? key,
    required this.payment,
  }) : super(key: key);

  final Payment payment;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentDetails(payment: payment),
          ),
        );
      },
      child: Card(
        //semanticContainer: false,
        shadowColor: Colors.green,
        elevation: 4.0,

        child: _paymentWidget(payment),
      ),
    );
  }

  Widget _paymentWidget(Payment payment) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(child: Text(payment.paymentPeriod.toString())),
          Expanded(child: Text(" ${payment.amount} ${payment.currency}")),
          Expanded(child: Text(payment.rate.toString())),
          Expanded(flex: 1, child: Text(stringValue(payment.paymentDate))),
        ],
      ),
    );
  }
}

class PaymentTileHeader extends StatelessWidget {
  const PaymentTileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white70,
      //semanticContainer: false,
      shadowColor: Colors.green,
      elevation: 8.0,
      /*shape: OutlineInputBorder(*/
      /*    borderRadius: BorderRadius.circular(10),*/
      /*    borderSide: const BorderSide(color: Colors.white))*/
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        textColor: Colors.black,
        leading: const Padding(
          padding: EdgeInsets.all(4.0),
          child: Text('Periode'),
        ),
        title: const Text("Montant"),
        trailing: Text("${currencies.elementAt(0)}/${currencies.elementAt(1)}"
            "       Date de paie"),
      ),
    );
  }
}

class TotalAmountWidget extends StatelessWidget {
  final double amount;

  const TotalAmountWidget({Key? key, required this.amount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white70,
      //semanticContainer: false,
      shadowColor: Colors.green,
      elevation: 8.0,
      /*shape: OutlineInputBorder(*/
      /*    borderRadius: BorderRadius.circular(10),*/
      /*    borderSide: const BorderSide(color: Colors.white))*/
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        textColor: Colors.black,
        title: Text("  Montant total :   $amount"),
      ),
    );
  }
}
