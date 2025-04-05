import 'package:flutter/material.dart';
import 'dart:async';
import 'home_page.dart'; // ✅ Correct import

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();

    // Navigate to HomePage after 3 seconds
    Timer(Duration(seconds: 7), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ), // ✅ Correct class name
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFF8996EB),
      body: Center(
        child: CircleAvatar(
          radius: screenWidth * 0.2,
          backgroundImage: AssetImage('assets/logo.png'),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}
