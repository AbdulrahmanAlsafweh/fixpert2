import 'dart:math';
import 'home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Profile extends StatefulWidget {
  final Function? loadData;
  Profile({Key? key, this.loadData}) : super(key: key);


  @override
  State<Profile> createState() => _ProfileState();
}

 Future<void> logout()async{
  SharedPreferences sp=await SharedPreferences.getInstance();
  sp.setBool('loggedIn', false);
}
class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile'),),
      body: Column(
        children:<Widget> [
          ElevatedButton(onPressed: () {
            // logout()
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Home(),));
            setState(() {
              logout();

            });
          }, child: Text("Logout"))
        ],
      ),
    );
  }
}
