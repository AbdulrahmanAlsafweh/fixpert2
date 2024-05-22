import 'package:flutter/material.dart';
import 'changePassword.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart';
import 'editCustomerProfile.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'chooseLocation.php.dart';

class CustomerProfile extends StatefulWidget {
  const CustomerProfile({Key? key}) : super(key: key);

  @override
  State<CustomerProfile> createState() => _CustomerProfileState();
}

class _CustomerProfileState extends State<CustomerProfile> {
  bool loading = false;
  String baseUrl = 'https://switch.unotelecom.com/fixpert/getCustomerProfileInfo.php';
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
    sp.setString('acc_type', ""); // Removed extra space after 'acc_type'

    print(sp.getBool("loggedIn"));
  }

  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout Confirmation',
            style: TextStyle(color: Colors.red),
          ),
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
              child: Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
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
        body: loading
            ? SliderDrawer(
          isDraggable: true,
          slideDirection: SlideDirection.RIGHT_TO_LEFT,
          appBar: SliderAppBar(
              appBarColor: Colors.indigoAccent,
              title: Text('Profile',
                  style: const TextStyle(color: Colors.white,
                      fontSize: 22, fontWeight: FontWeight.w700))),
          slider: Scaffold(
            appBar: AppBar(),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 15),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => EditCustomerProfile(),
                        settings: RouteSettings(arguments: {
                          'uri':
                          "https://switch.unotelecom.com/fixpert/assets/$picUri",
                          'username': username,
                          'user_id': id,
                        })));
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                          "https://switch.unotelecom.com/fixpert/assets/$picUri"),
                    ),
                    title: Text(
                      'Edit Profile',
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChangePasswordpage(),
                    ));
                  },
                  child: ListTile(
                    leading: Icon(Icons.lock, color: Colors.black),
                    title: Text(
                      'Change Password',
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _showLogoutConfirmationDialog();
                  },
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text(
                      'Logout',
                      style: TextStyle(color: Colors.red, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
          child: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: screenHeight * 0.3,
                    color: Colors.indigoAccent,
                    child: Column(
                      children: [
                        SizedBox(height: 50),
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: CachedNetworkImageProvider(
                              "https://switch.unotelecom.com/fixpert/assets/$picUri"),
                        ),
                        SizedBox(height: 10),
                        Text(username,
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Text(email,
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row(
                        //   children: [
                        //     Text(
                        //       'Address: $address ',
                        //       style: TextStyle(
                        //           fontSize: 16,
                        //           fontWeight: FontWeight.w500),
                        //     ),
                        //     IconButton(
                        //       onPressed: () {
                        //         Navigator.of(context)
                        //             .push(MaterialPageRoute(
                        //           builder: (context) =>
                        //               ChooseLocationPage(),
                        //         ));
                        //       },
                        //       icon: Icon(Icons.edit),
                        //     )
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
            : Center(
            child: LoadingAnimationWidget.inkDrop(
                color: Colors.blueAccent,
                size: ((screenWidth / 15) + (screenHeight / 15)))),
      ),
    );
  }
}
