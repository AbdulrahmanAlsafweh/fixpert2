import 'package:flutter/material.dart';


class ChangePasswordpage extends StatefulWidget {
  const ChangePasswordpage({super.key});

  @override
  State<ChangePasswordpage> createState() => _ChangePasswordpageState();
}

class _ChangePasswordpageState extends State<ChangePasswordpage> {
  TextEditingController currentPassowrdController=TextEditingController();
  TextEditingController newPasswordController=TextEditingController();
  TextEditingController repeatedPasswordController=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(onPressed: () {

          }, child:Text(
            'Change',style: TextStyle(fontWeight: FontWeight.w500),
          ))
        ],
      ),
      body: Column(children:<Widget> [
        Padding(padding: EdgeInsets.only(left: 10,right: 10),child: TextField(
          controller: currentPassowrdController,

          decoration: InputDecoration(
            labelText: "Current Password",
          ),),

        ),
        Padding(padding: EdgeInsets.only(left: 10,right: 10),child: TextField(
          controller: newPasswordController,

          decoration: InputDecoration(
            labelText: "New Password",
          ),),

        ),
        Padding(padding: EdgeInsets.only(left: 10,right: 10),child: TextField(
          controller: repeatedPasswordController,

          decoration: InputDecoration(
            labelText: "Retype New Password",
          ),),

        ),

      ],),
    );
  }
}
