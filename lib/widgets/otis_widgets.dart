import 'package:flutter/cupertino.dart';
import 'package:otis/helper/helper.dart';

class AppBarTitleWidget extends StatelessWidget {
  const AppBarTitleWidget({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: definedFontSize(context, multiplier),
      ),
    );
  }
}
