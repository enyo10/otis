import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:otis/models/period.dart';
import 'package:otis/models/sql_helper.dart';

class AddPayment extends StatefulWidget {
  final DateTime initialDate;
  final int ownerId;
  const AddPayment({Key? key, required this.initialDate, required this.ownerId})
      : super(key: key);

  @override
  State<AddPayment> createState() => _AddPaymentState();
}

class _AddPaymentState extends State<AddPayment> {
  final TextEditingController _dollarPaymentController =
      TextEditingController();

  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.red,
      appBar: AppBar(
        title: const Text("Ajouter payment"),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                decoration: const InputDecoration(hintText: 'Amount'),
                controller: _dollarPaymentController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)')),
                ],
              ),
            ),
            const Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                textAlign: TextAlign.center,
                // controller: buildingNameController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Building name',
                    hintText: 'Enter description'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        showMonthPicker(
                                context: context,
                                initialDate: widget.initialDate)
                            .then((date) => {
                                  if (date != null)
                                    {
                                      setState(() {
                                        selectedDate = date;
                                      })
                                    }
                                });
                      },
                      child: const Text("Periode de payement")),
                  const SizedBox(
                    width: 15.0,
                  ),
                  Text("${selectedDate.month}/${selectedDate.year}")
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            IconButton(
                onPressed: () {
                  _savePayment();

                  Navigator.of(context).pop(true);
                  // Navigator.pop(context, true);
                },
                icon: const Icon(Icons.save))
          ],
        ),
      ),
    );
  }

  Future<int> _savePayment() async {
    var paymentDate = DateTime.now();
    var month = selectedDate.month;
    var year = selectedDate.year;
    var amount = double.parse(_dollarPaymentController.text);
    var periodOfPayment = Period(month: month, year: year);
    var id = await SQLHelper.insertPayment(
        widget.ownerId, amount, paymentDate, periodOfPayment, "\$", 450);
    if (kDebugMode) {
      print(" Payment with id : $id inserted");
    }
    return id;
  }
}
