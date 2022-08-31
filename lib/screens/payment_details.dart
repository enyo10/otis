import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otis/models/payment.dart';

import '../helper/helper.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/info_widget.dart';

class PaymentDetails extends StatelessWidget {
  final Payment payment;
  const PaymentDetails({Key? key, required this.payment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                          data: payment.paymentPeriod.toString(),
                          text: 'Mois',
                        ),
                        NewWidget(
                            data: payment.amount.toString(), text: "Montant"),
                        NewWidget(data: payment.currency, text: "Devise"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            NewWidget(
                                data: stringValue(payment.paymentDate),
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


                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


