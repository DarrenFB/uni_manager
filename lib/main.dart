import 'package:flutter/material.dart';
import 'package:uni_manager/screens/signup_login.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const UniManagerApp());
}

class UniManagerApp extends StatelessWidget {
  const UniManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniManager',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Inter',
      ),

      home: const HomeScreen(),
    );
  }
}