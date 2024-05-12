import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'newReview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
class WorkerPageByOthers extends StatefulWidget {
  final int? id;
  const WorkerPageByOthers({Key? key, this.id}) : super(key: key);

  @override
  State<WorkerPageByOthers> createState() => _WorkerPageByOthersState();
}

class _WorkerPageByOthersState extends State<WorkerPageByOthers> {
  String baseUrl = 'https://switch.unotelecom.com/fixpert/getWorkerProfileInfoForOthers';
  List<dynamic> workerData = [];
  bool loading=false;
  bool? loggedIn ;
  String? address ;
  String? workerPic;
  String? openTime;
  String? workerName;
  String? about;
  String? availability;
  Future<void> getWorkerProfileInfo(int? id) async {
    String url = "$baseUrl?worker_id=$id";
    print("fetching $url");
    final request = await http.get(Uri.parse(url));
    if (request.statusCode == 200) {
      Map<String,dynamic> result=jsonDecode(request.body);
      setState(() {
        workerData =[result];
        workerName = workerData[0]['username'];
        openTime=workerData[0]['openTime'];
        workerPic = workerData[0]['profile_pic'];
        about = workerData[0]['about'];
        address = workerData[0]['address'];
        availability = workerData[0]['availability'];

        loading = true;
      });
      print("workerData: $workerData");
    } else {
      print("Request failed");
    }
  }

  @override
  void initState()  {
    super.initState();
    print('initState called');
    getWorkerProfileInfo(widget.id);
    SharedPreferences.getInstance().then((sp) {
      loggedIn = sp.getBool('loggedIn')!;
      print("Logged in $loggedIn");

    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return
 Scaffold(
        appBar: AppBar(),
        body:
        loading ?
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // SizedBox(
            //   height: screenHeight / 20,
            // ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: CircleAvatar(
                    radius:
                    screenWidth / 7, // Adjust radius as needed
                    backgroundImage: NetworkImage(
                      "https://switch.unotelecom.com/fixpert/assets/$workerPic",
                    ),
                  ),
                ),
                Spacer(),
                // Padding(
                //   padding: EdgeInsets.only(right: 4, bottom: 20),
                //   child: IconButton(
                //       onPressed: () {},
                //       icon: Icon(
                //         Icons.menu,
                //         size: screenWidth / 10,
                //       )),
                // )
              ],
            ),

            SizedBox(
              height: 15,
            ),

            // Username is here
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                '$workerName',
                style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 24),
              ),
            ),

            SizedBox(
              height: 5,
            ),
            // address of the user is here
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                '$address',
                style: TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'Open Time: $openTime',
                style: TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ),

            SizedBox(
              height: 10,
            ),

            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "About",
                style: (TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 18)),
              ),
            ),
            SizedBox(
              height: 3,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "$about",
                style: TextStyle(),
              ),
            ),

            SizedBox(height: 10,),

            /////////////////////////////////////
            ////reviwes section/////////////////
            /////////////////////////////////////
            Padding(padding: EdgeInsets.only(left: 10)
            ,child:Text("Reviews",style: TextStyle(fontSize: 21,fontWeight: FontWeight.w500),) ,),

            TextButton(onPressed:() {
              loggedIn! ? Navigator.of(context).push(MaterialPageRoute(builder: (context) => WriteReviewPage(worker_id: widget.id,),)) : Navigator.of(context).push(MaterialPageRoute(builder: (context) => Login(),));
            } , child: Text("Write a review"))

          ],

      )
            : Center(
    child: LoadingAnimationWidget.inkDrop(
    color: Colors.blueAccent,
        size: ((screenWidth / 15) + (screenHeight / 15)))
      ),
    );
  }
}
