import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddPayment extends StatelessWidget {
  final TextEditingController _paymentAmountController =
      TextEditingController();

  AddPayment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          decoration: const InputDecoration(hintText: 'Amount'),
          controller: _paymentAmountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)')),
          ],
        )
      ],
    );
  }
}
