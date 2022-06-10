import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otis/screens/home.dart';
import 'package:otis/screens/profil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initPassword();

  runApp(const MyApp());
}

final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
void initPassword() async {
  final SharedPreferences prefs = await _prefs;
  prefs.get(kPassword) ?? prefs.setString(kPassword, "123Otis");
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
