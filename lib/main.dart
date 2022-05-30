import 'package:flutter/material.dart';
import 'package:otis/screens/home.dart';

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

          scaffoldBackgroundColor: const Color(0xFFEFFFFD)
          //primaryColor: Colors.orange
          // backgroundColor: Colors.black12
          ),

       home: const HomeScreen(),

    );
  }
}
