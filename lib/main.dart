import 'package:flutter/material.dart';
import '/splash.dart'; // Import splash screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: Splash(), // Start with splash screen
    );
  }
}
