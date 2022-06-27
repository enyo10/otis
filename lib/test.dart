import 'package:flutter/material.dart';
import 'package:otis/screens/share_data.dart';
import 'bottomSheet.dart';

main(){
  String string = "Kofi";
  String path = "Hellls /kdkkdkd/ lldldl/";
  print(string.substring(3));
  List<String> splited = path.split("/");
  print(splited.elementAt(splited.length-1));

  runApp(const ShareData());
}