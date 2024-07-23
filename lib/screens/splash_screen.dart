import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:hr_app/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to main screen after a certain duration
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => HomeScreen(), // Your main screen
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreenUI(); // Show splash screen UI
  }
}

class SplashScreenUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/lottie/specs.json',
          height: 1200,
          width: 1200,
          fit: BoxFit.contain,
          repeat: false,
        ),
      ),
    );
  }
}
