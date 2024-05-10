import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login.dart';
import 'home.dart';
import 'getServices.dart';

class Signup extends StatelessWidget {
  final String? accType;

  Signup({Key? key, this.accType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(accType);

    // The size of screen
    double screenWidth = MediaQuery.of(context).size.width;

    // Textfield Initialization
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirm_passwordController = TextEditingController();
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// This function to to create new customer account
//     Singup.php file will receive the user email and password
//     first the php file will check if the email is exist in customer or worker tables
//     Then if its not it will insert the new account to datbase
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    Future<void> signup() async {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String baseURL = 'https://switch.unotelecom.com/fixpert/signup.php';
      String email = emailController.text.trim();
      String password = Uri.encodeComponent(passwordController.text).trim();
      print(email);
      if(email.contains('@gmail.com')){
        if(password.isNotEmpty){
      // if the password doesnot match with the repeated one
      if (passwordController.text.trim() !=
          confirm_passwordController.text.trim())
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("The passwords doesn't match"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ));
      // if the password match
      else {
        String url = '$baseURL?user_email=$email&user_password=$password';
        final response = await http.get(Uri.parse(url));
        // if the request to api is success
        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(responseData['message']),
            duration: Duration(seconds: 3),
          //   i will check if the message will tell the user that the account is already exist
          // i will set the background color of the snackbar to red and if not it will be green
            backgroundColor:
                responseData['message'].toLowerCase().contains('exist')
                    ? Colors.red
                    : Colors.green,
          ));

          /////////////////////////////////////////////////////////////////////////////
          //i know that if the account created successfully the response message will be
          // weclome aboard! so i will save that the user logged in if i catch a word welcome
          /////////////////////////////////////////////////////////////////////////////

          if (responseData['message'].toLowerCase().contains('welcome')) {
            sp.setBool("loggedIn", true);

            String urlToGetUserId='https://switch.unotelecom.com/fixpert/getUserInfo.php?user_email=$email';
            final response=await http.get(Uri.parse(urlToGetUserId));
            if(response.statusCode== 200 ){
              Map<String , dynamic> responseData=jsonDecode(response.body);
              sp.setString('user_id', responseData['user_id']);//i save the new user id that create new account
              sp.setString('username',responseData['username']);
              sp.setString('address',responseData['address']);
            }
            print('signup done');
            // Navigate to the home page to trigger rebuild
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          } else {
            sp.setBool("loggedIn", false);
          }
        }
      }}
      else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Check you entered a password!"),duration: Duration(seconds: 3),backgroundColor: Colors.red,));
        }
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Check your email"),duration: Duration(seconds: 3),backgroundColor: Colors.red,));
      }
    }

    // This function will check if the worker is already exist so it will not proceed into the nest step
    Future<void> checkIfWorkerExistst() async {
      String baseURL =
          "https://switch.unotelecom.com/fixpert/checkIfWorkerExists.php";
      // SharedPreferences sp = await SharedPreferences.getInstance();
      String email = emailController.text.trim();
      String password = Uri.encodeComponent(passwordController.text).trim();
// check if the password match the repeated one
      if(email.contains("@gmail.com")){
        if(password.isNotEmpty){
      if (passwordController.text.trim() !=
          confirm_passwordController.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("The passwords doesn't match"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ));
      } else {
        String url = '$baseURL?user_email=$email';
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = jsonDecode(response.body);
          responseData['message'].toLowerCase().contains('signed up')
              ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(responseData['message']),
                  duration: Duration(seconds: 3),
                  backgroundColor: Colors.red,
                ))
              : Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => Services(
                    email: email,
                    password: password,
                  ),
                ));
        }
      }}
      else{
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Check you entered a password!'),duration: Duration(seconds: 3),backgroundColor: Colors.red,));

        }
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Check your email'),duration: Duration(seconds: 3),backgroundColor: Colors.red,));
      }
    }

    return Scaffold(
        appBar: AppBar(
            // title: Text("Signup"),
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
                'Create an account',
                style: TextStyle(fontSize: 24),
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
                width: screenWidth - (screenWidth * 0.05),
                // margin: EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: confirm_passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFF0F2F5),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10.0)),
                      hintText: "Re-Write password"),
                ),
              ),
              SizedBox(
                height: 24,
              ),
              Container(
                width: screenWidth - (screenWidth * 0.1),

                //The sign up button
                child: accType == "client"
                    ? ElevatedButton(
                        onPressed: () {
                          signup();
                        },
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: ButtonStyle(
                            padding:
                                MaterialStateProperty.all(EdgeInsets.all(16)),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color(0xFF1A80E5)),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)))),
                      )

                    //The continue button which will appear if the user is worker
                    : ElevatedButton(
                        onPressed: () {
                          checkIfWorkerExistst();
                          // Navigator.of(context).push(MaterialPageRoute(builder: (context) => Services(email: emailController.text,password: passwordController.text,),));
                        },
                        child: Text(
                          'Continue',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: ButtonStyle(
                            padding:
                                MaterialStateProperty.all(EdgeInsets.all(16)),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color(0xFF1A80E5)),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20))))),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: screenWidth - (screenWidth * 0.1),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => Login()));
                  },
                  child: Text(
                    'I have an account',
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
