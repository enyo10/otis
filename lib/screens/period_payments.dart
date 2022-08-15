import 'package:flutter/material.dart';
import 'package:otis/models/lodging.dart';
import 'package:otis/models/occupant.dart';
import 'package:otis/models/sql_helper.dart';
import 'package:otis/widgets/payment_list_tile.dart';

import '../helper/helper.dart';
import '../models/payment.dart';
import '../widgets/add_payment.dart';

class PeriodPayments extends StatefulWidget {
  final List<Payment> payments;
  final Occupant occupant;
  final Lodging lodging;
  final Data data;

  const PeriodPayments({
    Key? key,
    required this.payments,
    required this.occupant,
    required this.lodging,
    required this.data,
  }) : super(key: key);

  @override
  State<PeriodPayments> createState() => _PeriodPaymentsState();
}

class _PeriodPaymentsState extends State<PeriodPayments> {
  late List<Payment> payments;
  double totalAmount = 0;

  @override
  void initState() {
    super.initState();
    payments = widget.payments;
    totalAmount = getTotalAmount(payments);
  }

/*  double getTotalAmount() {
    var amount = 0.0;
    for (Payment payment in payments) {
      double subAmount = payment.amount / payment.rate;
      double num2 = double.parse((subAmount).toStringAsFixed(2));
      amount += num2;
    }
    return amount;
  }*/

  @override
  Widget build(BuildContext context) {
    int year = DateTime.now().year;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (context) => AddPayments(
                      occupant: widget.occupant,
                      rent: widget.lodging.rent,
                      initialPaymentPeriodDate: DateTime.now(),
                      paymentPeriod: DateTime(year, widget.data.month),
                    ),
                    fullscreenDialog: true,
                  ),
                )
                .then((value) => _reloadData());
          }),
      appBar: AppBar(
        title: const Text("Les payements de la période"),
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
      bottomSheet: TotalAmountWidget(amount: totalAmount),
    );
  }

  Future<void> _reloadData() async {
    var payment = payments.first;
    var period = payment.paymentPeriod;
    var list = await SQLHelper.getPeriodPayments(
            payment.ownerId, period.year, period.month)
        .then((value) => value.map((e) => Payment.fromMap(e)).toList());
    setState(() {
      payments = list;
      totalAmount = getTotalAmount(payments);
    });
  }
}
