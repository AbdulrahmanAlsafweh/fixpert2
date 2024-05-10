import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Availability extends StatefulWidget {
  final String? user_id;
  Availability({Key? key,this.user_id}) : super(key: key);

  @override
  State<Availability> createState() => _AvailabilityState();
}

class _AvailabilityState extends State<Availability> {
  Future<void> updateAvailability(int availability)async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    String user_id = sp.getString('user_id')!;
    String baseUrl='https://switch.unotelecom.com/fixpert/updateAvailability.php?user_id=$user_id&new_availability=$availability';
    final response=await http.get(Uri.parse(baseUrl));

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children:<Widget> [
          Image.asset("assets/availability.png"),
          SizedBox(height: 4,),
          Text("Want Additional Income?",style: TextStyle(
            fontSize: 32,fontWeight: FontWeight.bold,
          ),),
          SizedBox(height: 24,),
          Padding(padding: EdgeInsets.only(left: 22),
          child: Center(
            child: RichText(
              textAlign: TextAlign.center, // Align text content center horizontally
              text: TextSpan(
                style: TextStyle(fontSize: 21, color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                    text: 'If You Are Able To Be ',
                  ),
                  TextSpan(
                    text: 'Available',
                    style: TextStyle(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                  TextSpan(
                    text: ' 24/7 For Fast Fixing & Services, So We Can Offer This Feature For You To Have Additional Income',
                  ),
                ],
              ),
            ),
          )
            ,),
          Spacer(),
          Row(

            children:<Widget> [


              Padding(padding: EdgeInsets.only(left: 21)
              ,child:    SizedBox(
                    height: 70,
                    child:
                    ElevatedButton(onPressed:() {
                      updateAvailability(0);
                     Navigator.of(context).push(MaterialPageRoute(builder: (context) => Home(),));},
                        child: Text(
                            "Not Now"
                        ),style: ButtonStyle(

                            shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                            )
                        )),
                  ) ,),

            Spacer(),
            Padding(padding: EdgeInsets.only(right: 10),child: SizedBox(
              height: 70,
              child:   ElevatedButton(onPressed:() {
                updateAvailability(1);
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => Home(),));
              },
                child:
                Row(
                  children: [
                    Text("I will take the challenge"),
                    Icon(Icons.arrow_forward_ios_rounded)
                  ],
                ),style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.orange),
                    shape: MaterialStatePropertyAll(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    )
                )
                ,) ,),
              ),


          ],),
          Spacer(),
          Text(
            "Note : That You Can Disable This\n Feature Anytime ",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey,),
          ),
          Spacer()
                ],
      ),
    );
  }
}
