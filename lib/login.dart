import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home.dart';
import 'dart:convert';
import 'ChooseTheAccountType.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String displayError = "";
  String baseURL = "https://switch.unotelecom.com/fixpert/login";
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    SharedPreferences sp= await SharedPreferences.getInstance();

    String email = emailController.text.trim();
    String password = Uri.encodeComponent(passwordController.text).trim();
    print(email);
    print(password);

    if (email.contains("@gmail.com")){
      if(password.isNotEmpty){
    String url = '$baseURL?user_email=$email&user_password=$password';
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData.containsKey('message')) {
        if(responseData['message'].toLowerCase().contains('succesfully')) {
          sp.setString('user_id', responseData['id']);
          sp.setString('username',responseData['username']);
          sp.setString('address',responseData['address']);
          sp.setString('acc_type', responseData['acc_type']);
          sp.setString("profile_pic",responseData['profile_pic']);
          sp.setBool("loggedIn", true);
          if(responseData['acc_type'] == 'worker'){
            sp.setInt('availability',int.parse(responseData['availability']));
            sp.setString('open_time',responseData['open_time']);
            sp.setString('about', responseData['about']);
            sp.setString('profile_pic',responseData['profile_pic']);
          }
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Home(),));
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            responseData['message'],
          ),
          duration: Duration(seconds: 3),
          backgroundColor: responseData['message'].toLowerCase().contains('failed') || responseData['message'].toLowerCase().contains("exist") ? Colors.red : Colors.green,
        ));
      }
      print(response.body);
    }}
      else
        {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Check you entered a password!'),duration: Duration(seconds: 3),backgroundColor: Colors.red,));

        }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text( "Check the entered email")
          ,duration: Duration(seconds: 3),
          backgroundColor: Colors.red));
    }
    // }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          // title: Text("Login"),
        ),
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Image(
                  image: AssetImage("assets/logo.png"),
                  width: screenWidth - (screenWidth * 0.4),
                ),
                alignment: Alignment.center,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Login',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(
                height: 10,
              ),
              if (displayError.isNotEmpty)
                Text(
                  displayError,
                  style: TextStyle(fontSize: 13),
                ),
              SizedBox(
                height: 24,
              ),
              Container(
                width: screenWidth - (screenWidth * 0.05),
                // margin: EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFF0F2F5),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10.0)),
                      hintText: "Email"),
                ),
              ),
              SizedBox(
                height: 24,
              ),
              Container(
                width: screenWidth - (screenWidth * 0.05),
                // margin: EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFF0F2F5),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10.0)),
                      hintText: "Password"),
                ),
              ),
              SizedBox(
                height: 24,
              ),
              Container(
                width: screenWidth - (screenWidth * 0.1),
                child: ElevatedButton(
                  onPressed: () {
                    login();
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.all(16)),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Color(0xFF1A80E5)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)))),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: screenWidth - (screenWidth * 0.1),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ChooseAcountType(),));
                  },
                  child: Text(
                    'Create an account',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.all(16)),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Color(0xFFF0F2F5)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)))),
                ),
              )
            ],
          ),
        ));
  }
}
