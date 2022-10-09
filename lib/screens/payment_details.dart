import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otis/models/payment.dart';
import 'package:otis/models/sql_helper.dart';
import 'package:otis/screens/update_payment.dart';

import '../helper/helper.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/info_widget.dart';
import '../widgets/password_controller.dart';

class PaymentDetails extends StatefulWidget {
  final Payment payment;
  const PaymentDetails({Key? key, required this.payment}) : super(key: key);

  @override
  State<PaymentDetails> createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Payment payment = widget.payment;
    var desc = (payment.desc == '')
        ? "Aucun commentaire n'a été laissé"
        : payment.desc;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFEFFFFD),
          elevation: 0.0,
          iconTheme: const IconThemeData(
            color: Colors.red,
          ),
        ),
        body: FractionallySizedBox(
          heightFactor: 0.8,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 10,
                  margin: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        NewWidget(
                          data: widget.payment.paymentPeriod.toString(),
                          text: 'Mois',
                        ),
                        NewWidget(
                            data: widget.payment.amount.toString(),
                            text: "Montant"),
                        NewWidget(
                            data: widget.payment.currency, text: "Devise"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            NewWidget(
                                data: stringValue(widget.payment.paymentDate),
                                text: "Date payement"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Card(
                  elevation: 5,
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "Commentaire: ",
                              // style: TextStyle(fontSize: 20),
                              style: GoogleFonts.courgette(
                                textStyle: const TextStyle(fontSize: 25),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          desc,
                          /*style: const TextStyle(
                              fontSize: 20, fontStyle: FontStyle.italic),*/
                          style: GoogleFonts.courgette(
                              textStyle: const TextStyle(
                            fontSize: 20,
                          )),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: TextButton(
                          onPressed: () async {
                            const String message = "Actualiser note";
                            const PasswordController passwordController =
                                PasswordController(title: message);
                            await showDialog(
                                context: context,
                                builder: (BuildContext c) {
                                  return passwordController;
                                }).then((value) async {
                              if (value) {
                                await _showUpdateForm();
                              }
                            });
                          },
                          child: Text(
                            "Actualiser",
                            style: GoogleFonts.charm(
                                textStyle: const TextStyle(
                                    color: Colors.lightGreen, fontSize: 25)),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: TextButton(
                          onPressed: () async {
                            const String message = "Suppression";
                            const PasswordController passwordController =
                                PasswordController(title: message);
                            await showDialog(
                                context: context,
                                builder: (BuildContext c) {
                                  return passwordController;
                                }).then((value) async {
                              if (value) {
                                await _deleteNote().then((value) =>
                                    showMessage(context, "$message réussie"));
                              }
                            });
                          },
                          child: Text(
                            "Supprimer",
                            style: GoogleFonts.charm(
                                textStyle: const TextStyle(
                                    color: Colors.red, fontSize: 25)),
                          )),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showUpdateForm() async {
    var payment = widget.payment;
    await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (BuildContext context) => UpdatePayment(payment: payment))
        .then((value) {
      setState(() {});
    });
  }

  Future<void> _deleteNote() async {
    const String desc = "";
     await SQLHelper.updatePayment(widget.payment.paymentId, desc)
        .then((value) {
      widget.payment.desc = "";
      setState(() {});
    });
  }
}
