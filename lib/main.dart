import 'package:flutter/material.dart';
import 'splashScreen.dart';
import 'OnBoarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<bool> checkLandingFlag() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getBool('landingFlag') ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkLandingFlag(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else {
          bool landingFlag = snapshot.data ?? true;
          return MaterialApp(
            home: Scaffold(
              body: landingFlag ? OnBoarding() : SplashScreen(),
            ),
          );
        }
      },
    );
  }
}
