import 'package:flutter/cupertino.dart';

class NewWidget extends StatelessWidget {
  const NewWidget(
      {Key? key, required this.data, required this.text, this.color})
      : super(key: key);

  final String data;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        " $text: $data",
        style: const TextStyle(
          fontSize: 20,
        ),
      ),
    );
  }
}
