import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup.dart';
import 'login.dart';
import 'signup.dart';
import 'availability.dart';
class ChooseAcountType extends StatelessWidget {
  const ChooseAcountType({super.key});

  Future<void> setAccType(String acc_type) async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString("acc_type", acc_type);
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children:<Widget> [
          Text("Join As a\n Client or\n Worker",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 27,

          ),
          softWrap: true,
          textAlign: TextAlign.center,),
          SizedBox(height: screenHeight - (screenHeight * 0.8),),
          Container(
            child: GestureDetector(

              onTap: () {
                setAccType('worker');

                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Signup(accType: "worker",),));
              },
              child: Image.asset('assets/imworker.png',width: screenWidth,),
            ),
          ),
          SizedBox(height: 40,),
          Container(
            child: GestureDetector(

              onTap: () {
                setAccType('client');

                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Signup(accType: 'client',),));
              },
              child: Image.asset('assets/imclient.png',width: screenWidth,),
            ),
          ),
          Expanded(child:
          Container(

            alignment: Alignment.bottomCenter,
            margin: EdgeInsets.only(bottom: 7),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Signup(),));
              },
              child: Text(
                'Already have an account',
                style: TextStyle(color: Colors.black,
                    fontWeight: FontWeight.w500),

              ),
              style: ButtonStyle(

                  padding: MaterialStateProperty.all(EdgeInsets.only(left: screenWidth/5,right: screenWidth/5,top: 10,bottom: 10)),
                  backgroundColor:MaterialStateProperty.all<Color>(Color(0xFFF0F2F5)),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17)
                  ))
              ),

            ),
          )
          )

        ],
      ),
    );
  }
}
