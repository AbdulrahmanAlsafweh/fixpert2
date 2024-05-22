import 'package:flutter/material.dart';
import 'home.dart';
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Simulate a delay to show the splash screen for a few seconds
    Future.delayed(Duration(seconds: 2), () {
      // Navigate to the main screen after delay
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()), // Replace HomeScreen() with your main screen widget
      );
    });

    return Scaffold(
      body: Center(
        child: Image.asset('assets/logo.png'), // Replace 'assets/logo.png' with the path to your logo image
      ),
    );
  }
}
