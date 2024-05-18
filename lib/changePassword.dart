import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordpage extends StatefulWidget {
  const ChangePasswordpage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordpage> createState() => _ChangePasswordpageState();
}

class _ChangePasswordpageState extends State<ChangePasswordpage> {
  late TextEditingController currentPassowrdController;
  late TextEditingController newPasswordController;
  late TextEditingController repeatedPasswordController;
  String baseUrl = 'https://switch.unotelecom.com/fixpert/changeCustomerPassword.php';
  String? user_id;

  @override
  void initState() {
    super.initState();
    currentPassowrdController = TextEditingController();
    newPasswordController = TextEditingController();
    repeatedPasswordController = TextEditingController();
    getCustomerId();
  }

  Future<void> getCustomerId() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      user_id = sp.getString('user_id');
    });
  }

  Future<void> changePassword() async {
    if (newPasswordController.text == repeatedPasswordController.text && newPasswordController.text.isNotEmpty && repeatedPasswordController.text.isNotEmpty) {
      final url = "$baseUrl?user_id=$user_id&current_password=${currentPassowrdController.text}&new_password=${newPasswordController.text}";
      print("fetching $url");
      final request = await http.get(Uri.parse(url));
      if (request.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(request.body);
        String message = jsonResponse['message'];
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please make sure the password and repeated are matched"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: changePassword,
            child: Text(
              'Change',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: TextField(
              controller: currentPassowrdController,
              decoration: InputDecoration(
                labelText: "Current Password",
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: TextField(
              controller: newPasswordController,
              decoration: InputDecoration(
                labelText: "New Password",
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: TextField(
              controller: repeatedPasswordController,
              decoration: InputDecoration(
                labelText: "Retype New Password",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
