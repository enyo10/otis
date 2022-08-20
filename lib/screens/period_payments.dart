import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
                      initialPaymentPeriodDate: widget.occupant.entryDate,
                      paymentPeriod: DateTime(year, widget.data.month),
                    ),
                    fullscreenDialog: true,
                  ),
                )
                .then((value) => _reloadData())
                .onError((error, stackTrace) => null);
          }),
      appBar: AppBar(
        title: Text(
          "Payements de la période",
          style: GoogleFonts.charmonman(
              textStyle: const TextStyle(
            fontSize: 20,
                fontWeight: FontWeight.bold
          )),
        ),
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
