import 'package:flutter/material.dart';
class LabelValueWidget extends StatelessWidget {
  const LabelValueWidget({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
          )
        ],
      ),
    );
  }
}