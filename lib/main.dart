import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:otis/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helper/helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        primarySwatch: Palette.kToDark,
        scaffoldBackgroundColor: const Color(0xFFEFFFFD),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Palette.kToDark),
      ),

      home: const HomeScreen(),
    );
  }
}
