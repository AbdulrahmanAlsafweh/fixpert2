import 'package:flutter/material.dart';
import 'changePassword.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart';
import 'editCustomerProfile.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

class CustomerProfile extends StatefulWidget {
  const CustomerProfile({Key? key}) : super(key: key);

  @override
  State<CustomerProfile> createState() => _CustomerProfileState();
}

class _CustomerProfileState extends State<CustomerProfile> {
  bool loading = false;
  String baseUrl =
      'https://switch.unotelecom.com/fixpert/getCustomerProfileInfo.php';
  String username = 'username';
  String email = '';
  String picUri = "";
  String id = '';
  String address = '';
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> logout() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool('loggedIn', false);
    print(sp.getBool("loggedIn"));
  }

  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout Confirmation',style: TextStyle(color: Colors.red),),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to logout?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Logout',style: TextStyle(color: Colors.red),),
              onPressed: () {
                logout();
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => Home(),
                ));
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> fetchData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    id = sp.getString("user_id") ?? '';
    print('User ID: $id'); // Check if user ID is retrieved correctly

    if (id.isNotEmpty) {
      // Check if user ID is not empty
      String url = '$baseUrl?customer_id=$id';
      print('Fetching data from URL: $url');

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print('Response received successfully');
        Map<String, dynamic> result = jsonDecode(response.body);
        print('Result: $result');

        if (result.isNotEmpty) {
          setState(() {
            username = result['username'] ?? '';
            email = result['email'] ?? '';
            picUri = result['pic_uri'];
            address = result['address'];
            print('The pic URI is: $picUri');
          });
        } else {
          print('Result is empty');
        }
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } else {
      print('User ID is empty');
    }
    loading = true;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      home: Scaffold(

          body:
          loading  ?

          SliderDrawer(
            isDraggable: true,
        slideDirection: SlideDirection.RIGHT_TO_LEFT,
        appBar: SliderAppBar(
            appBarColor: Colors.white,
            title: Text('Profile',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700))),
        slider:Scaffold(
          appBar: AppBar(),
          body:  Column(


            crossAxisAlignment: CrossAxisAlignment.start,
            children:<Widget> [

          //     Container(
          //       padding:EdgeInsets.only(left: 10),
          // child: Image.network("https://switch.unotelecom.com/fixpert/assets/$picUri",width: screenWidth/5,),),
             SizedBox(height: 15,),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChangePasswordpage()));
                },
                child: Container(
                  child: Row(
                    children:<Widget> [
                      Icon(Icons.key, size: 32),
                      SizedBox(width: 10),
                      Text(
                        "Change Your Password",
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 15,
              ),
              GestureDetector(
                onTap: _showLogoutConfirmationDialog,
                child: Container(

                  child: Row(children:<Widget> [

                    Icon(Icons.logout_outlined,size: 32,),
                    SizedBox(width: 10,),
                    Text("Logout",style: TextStyle(color: Colors.red,fontSize: 18),),
                  ],),
                ) ,
              )

            ],
          ),
        ),
        child: Column(
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
                    radius: screenWidth / 7, // Adjust radius as needed
                    backgroundImage: NetworkImage(
                      "https://switch.unotelecom.com/fixpert/assets/$picUri",
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
                '$username',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
              ),
            ),

            SizedBox(
              height: 5,
            ),
            // address of the user is here
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                address,
                style: TextStyle(color: Colors.grey),
              ),
            ),

            // The Edit profile button
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blueAccent),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)))),
                child: Row(
                  children: [
                    Spacer(),
                    Text(
                      'Edit Your Profile',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                    Spacer()
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EditCustomerProfile(),
                      settings: RouteSettings(arguments: {
                        'uri':
                            "https://switch.unotelecom.com/fixpert/assets/$picUri",
                        'username': username,
                        'user_id': id,
                      })));
                },
              ),
            ),

            // ElevatedButton(
            //     onPressed: () {
            //       // logout()
            //       Navigator.of(context).pushReplacement(MaterialPageRoute(
            //         builder: (context) => Home(),
            //       ));
            //       setState(() {
            //         logout();
            //       });
            //     },
            //     child: Text("Logout")),
          ],
        ),
      )
              :Center(
            child: LoadingAnimationWidget.inkDrop(
                color: Colors.blueAccent,
                size: ((screenWidth / 15) + (screenHeight / 15))))
    ),
    );
  }
}
