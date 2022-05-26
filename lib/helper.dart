import 'package:flutter/material.dart';
import 'package:otis/models/payment.dart';

List<Color> colorCollection = <Color>[
  const Color(0xFFADE2CF),
  const Color(0xFF8B1FA9),
  const Color(0xFFD5463C),
  const Color(0xFFDCB5A8),
  const Color(0xFF85461E),
  const Color(0xFFFF00FF),
  const Color(0xFF61B3C3),
  const Color(0xFFE47C73),
  const Color(0xFF636363),
  const Color(0xFFB5E6EB),
  const Color(0xFFD5E8DB),
  const Color(0xFF0B0F26),
  const Color(0xFF7C6DAF),
];

List<String> colorNames = <String>[
  'Green',
  'Purple',
  'Red',
  'Orange',
  'Caramel',
  'Magenta',
  'Blue',
  'Peach',
  'Gray',
  'lightBlue',
  'lightGreen',
  'navy',
  'indigo',
];

Map<String, Color> colorMap = {
  'Green': const Color(0xFFADE2CF),
  'Purple': const Color(0xFF8B1FA9),
  'Red': const Color(0xFFD5463C),
  'Orange': const Color(0xFFDCB5A8),
  'Caramel': const Color(0xFF85461E),
  'Magenta': const Color(0xFFFF00FF),
  'Blue': const Color(0xFF61B3C3),
  'Peach': const Color(0xFFE47C73),
  'Gray': const Color(0xFF636363),
  'lightBlue': const Color(0xFF99DDE7),
  'lightGreen': const Color(0xFF90EE90),
  'navy': const Color(0xFF0B0F26),
  'indigo': const Color(0xFF7C6DAF),
};

var color = const Color(0xFFEFFFFD);
Map<int, String> monthMap = {
  1: 'Janvier',
  2: 'Février',
  3: 'Mars',
  4: 'Avril',
  5: 'Mai',
  6: 'Juin',
  7: 'Juillet',
  8: 'Août',
  9: 'Septembre',
  10: 'Octobre',
  11: 'Novembre',
  12: 'Décembre'
};

class Data {
  final int month;
  final List<Payment>_payments = [];

  Data({required this.month});

  addPayment(Payment payment){
    _payments.add(payment);
  }
  get payments =>_payments;
}

 String stringValue(DateTime dateTime){
  return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
}

const kBottomContainerHeight = 80.0;
const kBottomContainerColor = Color(0xFFEB1555);
const kActiveCardColor = Color(0xFF1D1E33);
const kInactiveCardColor = Color(0xFF111328);

const kLabelTextStyle = TextStyle(
  fontSize: 18.0,
  color: Color(0xFF8D8E98),
);

const kNumberTextStyle = TextStyle(fontSize: 50, fontWeight: FontWeight.w900);
const kLargeButtonTextStyle =
TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold);
const kTextStyle = TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold);
const kResultStyle = TextStyle(
    fontSize: 22.0, fontWeight: FontWeight.bold, color: Color(0xFF24D876));
const kBMITextStyle = TextStyle(fontSize: 100.0, fontWeight: FontWeight.bold);
const kBodyTextStyle = TextStyle(
  fontSize: 22.0,
);

