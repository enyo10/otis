import 'package:flutter/material.dart';
import 'package:otis/widgets/payment_list_tile.dart';

import '../models/payment.dart';

class PaymentDetails extends StatefulWidget {
  final List<Payment> payments;
  const PaymentDetails({Key? key, required this.payments}) : super(key: key);

  @override
  State<PaymentDetails> createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> {
  late List<Payment> payments;
  double totalAmount = 0;

  @override
  void initState() {
    super.initState();
    payments = widget.payments;
    totalAmount = getTotalAmount();
  }

  double getTotalAmount() {
    var amount = 0.0;
    for (Payment payment in payments) {
      amount += payment.amount;
    }
    return amount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Details du payment"),
      ),
      body: Column(
        children: [
          const PaymentTileHeader(),
          Expanded(
            child: ListView.builder(
                itemCount: payments.length,
                itemBuilder: (_, index) {
                  var payment = payments.elementAt(index);
                  return PaymentListTile(payment: payment);
                }),
          ),
        ],
      ),
      bottomSheet: TotalAmountWidget(
        amount: totalAmount
      ),
    );
  }
}
