import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otis/helper/helper.dart';

class AppBarTitleWidget extends StatelessWidget {
  const AppBarTitleWidget({Key? key, required this.title, required this.ratio})
      : super(key: key);
  final String title;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.charmonman(
        textStyle: TextStyle(
            fontSize: definedFontSize(context, ratio),
            fontWeight: FontWeight.w700),
      ),
    );
  }
}
