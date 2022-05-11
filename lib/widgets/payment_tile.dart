import 'package:flutter/material.dart';
import '../models/payment.dart';


class PaymentTile extends StatelessWidget {
  final Payment payment;
  const PaymentTile({Key? key, required this.payment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String data = payment.amount.toString();
    return  ListTile(
      title: Text(data),
    );
  }
}
