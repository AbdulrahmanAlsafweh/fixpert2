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
import 'package:cached_network_image/cached_network_image.dart';
import 'projectDetailsPage.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'addNewWorkerProject.dart';
import 'chooseLocation.php.dart';
import 'changeOpenTime.dart';

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
  String close_time = "";
  int availability = 0;
  String about = '';
  double? rate;

  bool showAllComments = false;

  Map<String, List<String>> projectsWithImages = {};
  List<dynamic> workerProjects = [];
  List<dynamic> workerComments = [];

  Future<void> logout() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool('loggedIn', false);
    sp.setString('acc_type ', "");
    print(sp.getBool("loggedIn"));
  }

  Future<void> updateAvailability(int? newAvailability) async {
    final url =
        "https://switch.unotelecom.com/fixpert/updateAvailability.php?user_id=$id&new_availability=$newAvailability";
    final request = await http.get(Uri.parse(url));
    if (request.statusCode == 200) {
      setState(() {
        availability = newAvailability ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "You are now ${availability == 1 ? "available" : "not available"} "),
          backgroundColor: availability == 1 ? Colors.green : Colors.red,
        ));
      });
    }
  }

  Future<void> getRate(int? id) async {
    if (id == null) {
      throw ArgumentError('The worker id cannot be null');
    }

    final url =
        "https://switch.unotelecom.com/fixpert/getWorkerRate.php?worker_id=$id";
    final request = await http.get(Uri.parse(url));

    if (request.statusCode == 200) {
      var data = jsonDecode(request.body);
      if (data is Map<String, dynamic> && data.containsKey('avg_rate')) {
        setState(() {
          rate = double.parse(data['avg_rate'].toString());
        });
        print(rate);
      } else {
        throw FormatException('Unexpected JSON format');
      }
    } else {
      print('Failed to load rate data');
    }
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
            close_time = result['closeTime'];
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

  Future<void> deleteProject(String? projectName) async {
    final url =
        "https://switch.unotelecom.com/fixpert/deleteWorkerProject.php?project_name=$projectName&worker_id=${id}";
    print("fetching $url");
    final request = await http.get(Uri.parse(url));
    if (request.statusCode == 200) {
      setState(() {
        projectsWithImages.remove(projectName);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Project deleted!"),
            backgroundColor: Colors.blueAccent,
          ),
        );
      });
    }
  }

  Future<void> _showDeleteProjectConfirmationDialog(String? projectName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Project Confirmation',
            style: TextStyle(color: Colors.red),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete it?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Yes',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                deleteProject(projectName)
                    .then((value) => Navigator.of(context).pop());
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> getWorkerComments(int? id) async {
    String url =
        "https://switch.unotelecom.com/fixpert/getComments.php?worker_id=$id";
    print("fetching $url");
    final request = await http.get(Uri.parse(url));
    if (request.statusCode == 200) {
      setState(() {
        workerComments = jsonDecode(request.body);
      });
      print("workerComments: $workerComments");
    } else {
      print("Request failed");
    }
  }

  Future<void> getWorkerProjects(int? id) async {
    String url =
        "https://switch.unotelecom.com/fixpert/getWorkerProjects.php?user_id=$id";
    print("fetching $url");
    final request = await http.get(Uri.parse(url));
    if (request.statusCode == 200) {
      List<dynamic> result = jsonDecode(request.body);
      setState(() {
        workerProjects = result;
        projectsWithImages.clear(); // Clear existing data
        for (var project in workerProjects) {
          String projectName = project['project_name'];
          String image = project['image'];

          if (projectsWithImages.containsKey(projectName)) {
            projectsWithImages[projectName]!.add(image);
          } else {
            projectsWithImages[projectName] = [image];
          }
        }
        print("projects are $workerProjects");
        print("new data $projectsWithImages");
      });
    } else {
      print("Request failed");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData().then((value) {
      getWorkerProjects(int.parse(id));
      getWorkerComments(int.parse(id));
      getRate(int.parse(id));
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AddNewWorkerProject(worker_id: id),
          ));
        },
        child: Icon(Icons.add_outlined),
      ),
      body: loading
          ? SliderDrawer(
              isDraggable: true,
              slideDirection: SlideDirection.RIGHT_TO_LEFT,
              appBar: SliderAppBar(
                  appBarColor: availability != null ? (availability == 1 ? Colors.green : Colors.red) : Colors.white,
                  title: Text('Profile',
                      style: const TextStyle(
                        color: Colors.white,
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
                            builder: (context) => EditWorkerProfile(),
                            settings: RouteSettings(arguments: {
                              'uri':
                                  "https://switch.unotelecom.com/fixpert/assets/$picUri",
                              'username': username,
                              'user_id': id,
                              'about': about
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
                      GestureDetector(
                        onLongPress: () {
                          updateAvailability(availability == 1 ? 0 : 1);
                        },
                        child: Container(
                          width: double.infinity,
                          height: screenHeight * 0.3,
                          color: availability == 1 ? Colors.green : Colors.red,
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
                      ),
                      Container(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child:Text(
                                  'Address: $address ',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ), ),

                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) =>
                                          ChooseLocationPage(),
                                    ));
                                  },
                                  icon: Icon(Icons.edit),
                                )
                              ],
                            ),
                            //
                            // SizedBox(height: 5),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ChangeOpenTimePage(),
                                ));
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'Work time: $open_time-$close_time',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Icon(Icons.edit),
                                ],
                              ),
                            ),

                            SizedBox(height: 5),

                            SizedBox(height: 10),
                            Text(
                              'About Me',
                              style: TextStyle(
                                  fontSize: 21, fontWeight: FontWeight.w500),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 0),
                              child: Divider(
                                color: Colors.grey,
                                thickness: 1,
                              ),
                            ),
                            SizedBox(height: 5),
                            if (about!.isEmpty)
                              Text(
                                "You can edit your profile and add your about !",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),

                            Text(about, style: TextStyle(fontSize: 16)),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Projects',
                              style: TextStyle(
                                  fontSize: 21, fontWeight: FontWeight.w500),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 0),
                              child: Divider(
                                color: Colors.grey,
                                thickness: 1,
                              ),
                            ),
                            SizedBox(height: 5),
                            projectsWithImages.isEmpty
                                ? SizedBox(
                                    height: 0,
                                    width: 0,
                                  )
                                : Text(
                                    'Long press on a project to delete it.',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey[600]),
                                  ),
                            SizedBox(height: 5),
                            projectsWithImages.isNotEmpty
                                ? GridView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 8.0,
                                      mainAxisSpacing: 8.0,
                                      childAspectRatio: 0.75,
                                    ),
                                    itemCount: projectsWithImages.length,
                                    itemBuilder: (context, index) {
                                      String projectName = projectsWithImages
                                          .keys
                                          .elementAt(index);
                                      List<String> images =
                                          projectsWithImages[projectName]!;

                                      return GestureDetector(
                                        onLongPress: () {
                                          _showDeleteProjectConfirmationDialog(
                                              projectName);
                                        },
                                        onTap: () {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (context) =>
                                                ProjectDetailsPage(
                                              images: images,
                                              projectName: projectName,
                                            ),
                                          ));
                                        },
                                        child: Card(
                                          elevation: 4,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      "https://switch.unotelecom.com/fixpert/assets/worker_projects/${images[0]}",
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  projectName,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Text(
                                    "No projects available",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),

                            Padding(
                              padding: EdgeInsets.only(left: 0),
                              child: Text(
                                "Reviews",
                                style: TextStyle(
                                    fontSize: 21, fontWeight: FontWeight.w500),
                              ),
                            ),
                            // ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 0),
                              child: Divider(
                                color: Colors.grey,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 0),
                              child: Text(
                                rate?.toStringAsFixed(1) ?? '0.0',
                                style: TextStyle(fontSize: 32),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(left: 0),
                              child: RatingBarIndicator(
                                rating: rate ?? 0,
                                itemBuilder: (context, index) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                itemCount: 5,
                                itemSize: 25.0,
                                direction: Axis.horizontal,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 0),
                              child: Text(
                                "${workerComments.length}  reviews",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 0),
                              child: Column(
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: showAllComments
                                        ? workerComments.length
                                        : (workerComments.length > 4
                                            ? 4
                                            : workerComments.length),
                                    itemBuilder: (context, index) {
                                      return Container(
                                        padding: EdgeInsets.all(10),
                                        margin:
                                            EdgeInsets.symmetric(vertical: 5),
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundImage:
                                                      CachedNetworkImageProvider(
                                                    "https://switch.unotelecom.com/fixpert/assets/${workerComments[index]['pic_uri']}",
                                                  ),
                                                  radius: 20,
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  workerComments[index]
                                                      ['username'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Text(workerComments[index]
                                                ['comment']),
                                            SizedBox(height: 5),
                                            RatingBarIndicator(
                                              rating: workerComments[index]
                                                          ['rate']
                                                      .toDouble() ??
                                                  0,
                                              itemBuilder: (context, index) =>
                                                  Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                              itemCount: 5,
                                              itemSize: 16.0,
                                              direction: Axis.horizontal,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  if (workerComments.length > 4)
                                    Center(
                                      child: TextButton(
                                        onPressed: () {
                                          setState(() {
                                            showAllComments = !showAllComments;
                                          });
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            showAllComments
                                                ? Row(
                                                    children: [
                                                      Text("View Less"),
                                                      Icon(Icons.arrow_upward),
                                                    ],
                                                  )
                                                : Row(
                                                    children: [
                                                      Text("View More"),
                                                      Icon(
                                                          Icons.arrow_downward),
                                                    ],
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
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
                color: Colors.blue,
                size: 50,
              ),
            ),
    );
  }
}
