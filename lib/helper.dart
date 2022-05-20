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
  Payment? payment;

  Data({required this.month});
}

List<Data> dataList = [
  Data(month: 1),
  Data(month: 2),
  Data(month: 3),
  Data(month: 4),
  Data(month: 5),
  Data(month: 6),
  Data(month: 7),
  Data(month: 8),
  Data(month: 9),
  Data(month: 10),
  Data(month: 11),
  Data(month: 12),
];
