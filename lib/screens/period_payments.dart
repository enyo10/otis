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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    int year = DateTime.now().year;
    var monthInt = widget.data.month;
    var month = monthMap[monthInt];
    double height = MediaQuery.of(context).size.height * 0.10;
    return Scaffold(

      appBar: AppBar(
        title: Text(
          "Payements de $month",
          style: GoogleFonts.charmonman(
              textStyle:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
      ),
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
                fullscreenDialog: false,
              ),
            )
                .then((value) => _loadData())
                .onError((error, stackTrace) => null);
          }),
      body: Container(
        padding: EdgeInsets.only(bottom: height + 10),
        child: _isLoading
            ? Center(
                child: Text(
                  "...En chargement",
                  style: GoogleFonts.charmonman(fontSize: 40),
                ),
              )
            : Column(
                children: [
                  const PaymentTileHeader(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: payments.length,
                      itemBuilder: (_, index) {
                        var payment = payments.elementAt(index);
                        return PaymentListTile(payment: payment);
                      },
                    ),
                  ),
                ],
              ),
      ),
      bottomSheet: TotalAmountWidget(
        amount: totalAmount,
        height: height,
      ),
    );
  }

  Future<void> _loadData() async {
    var month = widget.data.month;
    var ownerId = widget.occupant.id;
    var year = DateTime.now().year;
    var list = await SQLHelper.getPeriodPayments(ownerId, year, month)
        .then((value) => value.map((e) => Payment.fromMap(e)).toList());
    setState(() {
      payments = list;
      totalAmount = getTotalAmount(payments);
      _isLoading = false;
    });
  }
}
