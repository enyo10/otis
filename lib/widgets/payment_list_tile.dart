import 'package:flutter/material.dart';
import 'package:otis/screens/payment_details.dart';

import '../helper/helper.dart';
import '../models/payment.dart';

class PaymentListTile extends StatefulWidget {
  const PaymentListTile({
    Key? key,
    required this.payment,
    this.color,
  }) : super(key: key);

  final Payment payment;
  final Color? color;

  @override
  State<PaymentListTile> createState() => _PaymentListTileState();
}

class _PaymentListTileState extends State<PaymentListTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Payment payment = widget.payment;
    var amount = "${payment.amount} ${payment.currency}";
    var period = payment.paymentPeriod.toString();
    var tax = payment.rate.toString();
    var date = stringValue(payment.paymentDate);
    var info = (widget.payment.desc == '') ? " " : "i";

    return GestureDetector(
      onDoubleTap: () async {
        await Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (context) => PaymentDetails(payment: payment),
              ),
            )
            .then((value) => setState(() {}));
      },
      child: PaymentCard(
          period: period, amount: amount, tax: tax, date: date, info: info),
    );
  }

  Widget _paymentWidget(Payment payment) {
    var info = (payment.desc == '') ? " " : "i";
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MyTextWidget(
            text: payment.paymentPeriod.toString(),
          ),
          MyTextWidget(text: "${payment.amount} ${payment.currency}"),
          MyTextWidget(text: payment.rate.toString()),
          MyTextWidget(text: stringValue(payment.paymentDate)),
          MyTextWidget(text: info),
        ],
      ),
    );
  }
}

class PaymentTileHeader extends StatelessWidget {
  const PaymentTileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var period = 'Periode';
    var amount = "Montant";
    var rate = "Taux";
    var date = "Date paie";
    var info = "";

    return Card(
      color: Colors.white70,
      //semanticContainer: false,
      shadowColor: Colors.green,
      elevation: 8.0,

      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MyTextWidget(text: period),
            MyTextWidget(text: amount),
            MyTextWidget(text: rate),
            MyTextWidget(text: date),
            const Text("")
            // MyTextWidget(text: info)
          ],
        ),
      ),
    );
  }
}

class TotalAmountWidget extends StatelessWidget {
  final double amount;
  final double height;

  const TotalAmountWidget(
      {Key? key, required this.amount, required this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Card(
        color: Colors.white70,
        //semanticContainer: false,
        semanticContainer: true,
        shadowColor: Colors.green,
        elevation: 10.0,
        /*shape: OutlineInputBorder(*/
        /*    borderRadius: BorderRadius.circular(10),*/
        /*    borderSide: const BorderSide(color: Colors.white))*/
        child: ListTile(
          /* contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),*/
          textColor: Colors.black,
          title: Text("  Montant total :   $amount"),
        ),
      ),
    );
  }
}

class MyTextWidget extends StatelessWidget {
  final String text;

  const MyTextWidget({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class MyRow extends StatelessWidget {
  const MyRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );
  }
}

class PaymentCard extends StatelessWidget {
  const PaymentCard(
      {Key? key,
      this.color,
      required this.period,
      required this.amount,
      required this.tax,
      required this.date,
      required this.info})
      : super(key: key);
  final Color? color;
  final String period;
  final String amount;
  final String tax;
  final String date;
  final String info;

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.green,
      elevation: 4.0,
      child: ListTile(
        trailing: SizedBox(
          width: 10,
          child: Text(
            info,
            style: const TextStyle(
                color: Colors.amber, fontStyle: FontStyle.italic, fontSize: 25),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(period),
            Text(
              amount,
              style: _isNegative()
                  ? const TextStyle(color: Colors.redAccent)
                  : const TextStyle(),
            ),
            Text(tax),
            Text(date)
          ],
        ),
      ),
    );
  }

  bool _isNegative() => amount.contains("-");
}
