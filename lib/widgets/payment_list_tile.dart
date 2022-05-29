import 'package:flutter/material.dart';

import '../helper.dart';
import '../models/payment.dart';

class PaymentListTile extends StatelessWidget {
  const PaymentListTile({
    Key? key,
    required this.payment,
  }) : super(key: key);

  final Payment payment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Card(
        //semanticContainer: false,
        shadowColor: Colors.green,
        elevation: 8.0,
        /*shape: OutlineInputBorder(*/
        /*    borderRadius: BorderRadius.circular(10),*/
        /*    borderSide: const BorderSide(color: Colors.white))*/
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
    );
  }
}

class PaymentTileHeader extends StatelessWidget {
  const PaymentTileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding:  EdgeInsets.only(left: 8.0, right: 8.0),
      child: Card(
        color: Colors.white70,
        //semanticContainer: false,
        shadowColor: Colors.green,
        elevation: 8.0,
        /*shape: OutlineInputBorder(*/
        /*    borderRadius: BorderRadius.circular(10),*/
        /*    borderSide: const BorderSide(color: Colors.white))*/
        child: ListTile(
          textColor: Colors.black,
          leading: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Periode'
            ),
          ),
          title: Text("Montant"),
          trailing: Text(
            " Date de payment",
          ),
        ),
      ),
    );
  }
}


