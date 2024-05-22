import 'package:flutter/material.dart';
import 'login.dart';
import 'home.dart';
import 'splashScreen.dart';
import 'homePage.dart';
import 'OnBoarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure that Flutter has initialized
  // await checkLandingFlag(); // Await the function call here
  runApp(const MyApp());
}

bool landingFlag =false;
Future<void> checkLandingFlag() async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  landingFlag = sp.getBool('landingFlag') ?? true; // Use null-aware operator
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // Fix the constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: Scaffold(
        body:  landingFlag? OnBoarding() : SplashScreen() , // Use null assertion operator
      ),
    );
  }
}
