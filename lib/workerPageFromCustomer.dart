import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'newReview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'home.dart';
import 'projectDetailsPage.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WorkerPageByOthers extends StatefulWidget {
  final int? id;
  final double? rate;
  final String? serviceByWorker;
  const WorkerPageByOthers({Key? key, this.id, this.rate, this.serviceByWorker})
      : super(key: key);

  @override
  State<WorkerPageByOthers> createState() => _WorkerPageByOthersState();
}

class _WorkerPageByOthersState extends State<WorkerPageByOthers> {
  String baseUrl =
      'https://switch.unotelecom.com/fixpert/getWorkerProfileInfoForOthers';
  List<dynamic> workerData = [];
  List<dynamic> workerProjects = [];
  bool loading = false;
  bool? loggedIn;
  String? address;
  String? workerPic;
  String? open_time;
  String? workerName;
  String? about;
  String? email;
  String? availability;
  String? close_time;
  String? acc_type = '';
  Map<String, List<String>> projectsWithImages = {};
  List<dynamic> workerComments = [];
  bool showAllComments = false;

  Future<void> getWorkerProfileInfo(int? id) async {
    setState(() {
      loading = true;
    });

    String url = "$baseUrl?worker_id=$id";
    print("fetching $url");
    final request = await http.get(Uri.parse(url));
    if (request.statusCode == 200) {
      if (request.body.isNotEmpty) {
        try {
          Map<String, dynamic> result = jsonDecode(request.body);
          setState(() {
            workerData = [result];
            workerName = workerData[0]['username'] ?? "";
            open_time = workerData[0]['openTime'];
            workerPic = workerData[0]['profile_pic'];
            about = workerData[0]['about'];
            address = workerData[0]['address'];
            email = workerData[0]['email'];
            close_time = workerData[0]['closeTime'];
            availability = workerData[0]['availability'];
            loading = false;
          });
          print("workerData: $workerData");
        } catch (e) {
          print("Error parsing JSON: $e");
          setState(() {
            loading = false;
          });
        }
      } else {
        print("Empty response body");
        setState(() {
          loading = false;
        });
      }
    } else {
      setState(() {
        loading = false;
      });
      print("Request failed with status: ${request.statusCode}");
    }
  }

  Future<void> getWorkerComments(int? id) async {
    String url =
        "https://switch.unotelecom.com/fixpert/getComments.php?worker_id=$id";
    print("fetching $url");
    final request = await http.get(Uri.parse(url));
    if (request.statusCode == 200) {
      if (request.body.isNotEmpty) {
        try {
          setState(() {
            workerComments = jsonDecode(request.body);
          });
          print("workerComments: $workerComments");
        } catch (e) {
          print("Error parsing JSON: $e");
        }
      } else {
        print("Empty response body");
      }
    } else {
      print("Request failed with status: ${request.statusCode}");
    }
  }

  Future<void> getWorkerProjects(int? id) async {
    String url =
        "https://switch.unotelecom.com/fixpert/getWorkerProjects.php?user_id=$id";
    print("fetching $url");
    final request = await http.get(Uri.parse(url));
    if (request.statusCode == 200) {
      if (request.body.isNotEmpty) {
        try {
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
            print("new  shi $projectsWithImages");
          });
        } catch (e) {
          print("Error parsing JSON: $e");
        }
      } else {
        print("Empty response body");
      }
    } else {
      print("Request failed with status: ${request.statusCode}");
    }
  }

  @override
  void initState() {
    super.initState();
    print('initState called');
    getWorkerProfileInfo(widget.id);
    getWorkerProjects(widget.id);
    getWorkerComments(widget.id);
    SharedPreferences.getInstance().then((sp) {
      setState(() {
        loggedIn = sp.getBool('loggedIn') ?? false;
        acc_type = sp.getString("acc_type") ?? '';
      });
      print("Logged in $loggedIn");
      print(acc_type);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white), // Change the color here
    onPressed: () {
    Navigator.of(context).pop();
    },),
        backgroundColor: availability == null ? Colors.white :( availability == "1" ?Colors.green : Colors.red ),
        title: workerName != null ? Text(workerName!,style: TextStyle(color: Colors.white),) : Text("worker name",style: TextStyle(color: Colors.white),)
      ),
      body: loading
          ? Center(
          child: LoadingAnimationWidget.inkDrop(
              color: Colors.blueAccent,
              size: ((screenWidth / 15) + (screenHeight / 15))))
          : SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: screenHeight * 0.3,
              color: availability == '1' ? Colors.green : Colors.red,
              child: Column(
                children: [
                  SizedBox(height: 50),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: CachedNetworkImageProvider(
                        "https://switch.unotelecom.com/fixpert/assets/$workerPic"),
                  ),
                  SizedBox(height: 10),
                  Text(workerName ?? "",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(email ?? "", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Address: $address ',
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Work time: $open_time-$close_time',
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 5),
                  SizedBox(height: 10),
                  Text(
                    'About',
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
                      "No Available About !",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  Text(about ?? "", style: TextStyle(fontSize: 16)),
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
                      String projectName = projectsWithImages.keys
                          .elementAt(index);
                      List<String> images =
                      projectsWithImages[projectName]!;

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ProjectDetailsPage(
                                        images: images,
                                        projectName: projectName,
                                        worker_id: widget.id.toString() ,
                                      )));
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
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  projectName,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
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
                      widget.rate?.toStringAsFixed(1) ?? '0.0',
                      style: TextStyle(fontSize: 32),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 0),
                    child: RatingBarIndicator(
                      rating: widget.rate ?? 0,
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
                  acc_type!.contains('worker')
                      ? SizedBox()
                      : TextButton(
                      onPressed: () {
                        if (loggedIn ?? false) {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                            builder: (context) => WriteReviewPage(
                              worker_id: widget.id,
                            ),
                          ));
                        } else {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                            builder: (context) => Home(neededPage: 3),
                          ));
                        }
                      },
                      child: Text("Write a review")),
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
                              margin: EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
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
                                        workerComments[index]['username'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Text(workerComments[index]['comment']),
                                  SizedBox(height: 5),
                                  RatingBarIndicator(
                                    rating: workerComments[index]['rate']
                                        .toDouble() ??
                                        0,
                                    itemBuilder: (context, index) => Icon(
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
                                      Icon(Icons.arrow_downward),
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
    );
  }
}
