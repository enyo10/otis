import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otis/models/sql_helper.dart';

import '../models/payment.dart';

class UpdatePayment extends StatefulWidget {
  const UpdatePayment({Key? key, required this.payment}) : super(key: key);
  final Payment payment;

  @override
  State<UpdatePayment> createState() => _UpdatePaymentState();
}

class _UpdatePaymentState extends State<UpdatePayment> {
  final TextEditingController _descController = TextEditingController();
  @override
  void initState() {
    _initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      height: MediaQuery.of(context).size.height * 0.60,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: FloatingActionButton(
          onPressed: () async {
            await _addNoteToPayment()
                .then((value) => Navigator.of(context).pop());
          },
          child: const Icon(Icons.save),
        ),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              const Center(
                child: Text(' Ajouter note',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30.0, color: Colors.red)),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Divider(
                  thickness: 5, // thickness of the line
                  indent: 20, // empty space to the leading edge of divider.
                  endIndent:
                  20, // empty space to the trailing edge of the divider.
                  color: Colors.red, // The color to use when painting the line.
                  height: 20, //

                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: _descController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Ajouter commentaire',
                      hintText: 'Commentaire'),
                  style: Theme.of(context).textTheme.labelLarge,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addNoteToPayment() async {
    var desc = _descController.text;
    if (desc.isNotEmpty) {
      var id = widget.payment.paymentId;
      await SQLHelper.updatePayment(id, desc).then((value) => setState(() {
        widget.payment.desc= desc;

      }));
    }
  }

  _initData() {
    var desc = widget.payment.desc;
    if (desc.isNotEmpty) {
      _descController.text = widget.payment.desc;
    }
  }
}
