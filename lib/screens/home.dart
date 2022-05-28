import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:otis/screens/living_quarter_list.dart';

import '../helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const colorizeColors = [
    Colors.purple,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  static const colorizeTextStyle = TextStyle(
    fontSize: 50.0,
    fontFamily: 'Horizon',
  );

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
      onDoubleTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const LivingQuarterList()));
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 250.0,
              child: TextLiquidFill(
                text: 'Otis',
                waveColor: Colors.blueAccent,
                boxBackgroundColor: Colors.red,
                textStyle: const TextStyle(
                    fontSize: 80.0,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic),
                boxHeight: 300.0,
              ),
            ),
            const Text(
              "Developed with ❤️ by Enyo",
              //style: TextStyle(fontStyle: FontStyle.italic),
              style: kLabelTextStyle,
            )
          ],
        ),
      ),
    ));
  }
}
