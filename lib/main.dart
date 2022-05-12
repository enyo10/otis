import 'package:flutter/material.dart';
import 'package:otis/models/living_quarter.dart';
import 'package:otis/screens/home.dart';
import 'package:otis/screens/living_quarter_list.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove the debug banner
      debugShowCheckedModeBanner: false,
      title: 'Otis',
      theme: ThemeData(
        primarySwatch: Colors.red,
        //  primaryColor: Colors.orange
      ),

      home: const HomeScreen(),
    );
  }
}
