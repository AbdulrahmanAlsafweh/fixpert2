import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'home.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'changePassword.dart';
import 'editWorkerProfile.dart';
import 'addNewWorkerProject.dart';

class WorkerProfile extends StatefulWidget {
  const WorkerProfile({Key? key}) : super(key: key);

  @override
  State<WorkerProfile> createState() => _WorkerProfileState();
}

class _WorkerProfileState extends State<WorkerProfile> {
  bool loading = false;
  String baseUrl =
      'https://switch.unotelecom.com/fixpert/getWorkerProfileInfo.php';
  String username = 'username';
  String email = '';
  String picUri = "";
  String id = '';
  String address = '';
  String open_time = "";
  int availability = 0;
  String about = '';

  Future<void> logout() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool('loggedIn', false);
    sp.setString('acc_type ', "");
    print(sp.getBool("loggedIn"));
  }

  Future<void> fetchData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    id = sp.getString("user_id") ?? '';
    print('User ID: $id');

    if (id.isNotEmpty) {
      String url = '$baseUrl?worker_id=$id';
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
            picUri = result['profile_pic'];
            address = result['address'];
            open_time = result['openTime'];
            availability = int.parse(result['availability']);
            about = result['about'];
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

  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
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

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: loading
          ? SliderDrawer(
              isDraggable: true,
              slideDirection: SlideDirection.RIGHT_TO_LEFT,
              appBar: SliderAppBar(
                  appBarColor: Colors.white,
                  title: Text('Worker Page',
                      style: const TextStyle(
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
                            builder: (context) => ChangePasswordpage()));
                      },
                      child: ListTile(
                        leading: Icon(Icons.key, size: 32),
                        title: Text(
                          "Change Your Password",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 18),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _showLogoutConfirmationDialog,
                      child: ListTile(
                        leading: Icon(
                          Icons.logout_outlined,
                          size: 32,
                          color: Colors.red,
                        ),
                        title: Text(
                          "Logout",
                          style: TextStyle(color: Colors.red, fontSize: 18),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: CircleAvatar(
                          radius: screenWidth / 7,
                          backgroundImage: NetworkImage(
                            "https://switch.unotelecom.com/fixpert/assets/$picUri",
                          ),
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      '$username',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
                    ),
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      address,
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'Open Time: $open_time',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.blueAccent),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)))),
                      child: Row(
                        children: [
                          Spacer(),
                          Text(
                            'Edit Your Profile',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(width: 5),
                          Icon(Icons.edit, color: Colors.white),
                          Spacer()
                        ],
                      ),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => EditWorkerProfile(),
                            settings: RouteSettings(arguments: {
                              'uri':
                                  "https://switch.unotelecom.com/fixpert/assets/$picUri",
                              'username': username,
                              'user_id': id,
                            })));
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      "About",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                    ),
                  ),
                  SizedBox(height: 3),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      about,
                      style: TextStyle(),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                AddNewWorkerProject(worker_id: id),
                          ));
                        },
                        child: Text('Add New Project'),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: LoadingAnimationWidget.inkDrop(
                  color: Colors.blueAccent,
                  size: ((screenWidth / 15) + (screenHeight / 15)))),
    );
  }
}
