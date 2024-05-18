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
  String? openTime;
  String? workerName;
  String? about;
  String? availability;
  String? acc_type = '';

  Future<void> getWorkerProfileInfo(int? id) async {
    String url = "$baseUrl?worker_id=$id";
    print("fetching $url");
    final request = await http.get(Uri.parse(url));
    if (request.statusCode == 200) {
      Map<String, dynamic> result = jsonDecode(request.body);
      setState(() {
        workerData = [result];
        workerName = workerData[0]['username'];
        openTime = workerData[0]['openTime'];
        workerPic = workerData[0]['profile_pic'];
        about = workerData[0]['about'];
        address = workerData[0]['address'];
        availability = workerData[0]['availability'];
        loading = false;
      });
      print("workerData: $workerData");
    } else {
      setState(() {
        loading = false;
      });
      print("Request failed");
    }
  }

  Map<String, List<String>> projectsWithImages = {};

  Future<void> getWorkerProjects(int? id) async {
    String url =
        "https://switch.unotelecom.com/fixpert/getWorkerProjects.php?user_id=$id";
    print("fetching $url");
    final request = await http.get(Uri.parse(url));
    if (request.statusCode == 200) {
      List<dynamic> result = jsonDecode(request.body);
      setState(() {
        workerProjects = result;
        workerProjects.forEach((project) {
          String projectName = project['project_name'];
          String image = project['image'];

          if (projectsWithImages.containsKey(projectName)) {
            projectsWithImages[projectName]!.add(image);
          } else {
            projectsWithImages[projectName] = [image];
          }
        });
        print("projects are $workerProjects");
        print("new  shi $projectsWithImages");
        projectsWithImages.forEach((project, images) {
          print('Project: $project');
          print('Images: $images');
          print('\n');
        });
      });
    } else {
      print("Request failed");
    }
  }

  @override
  void initState() {
    super.initState();
    print('initState called');
    setState(() {
      loading = true;
    });
    getWorkerProfileInfo(widget.id);
    getWorkerProjects(widget.id);
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
      appBar: AppBar(),
      body: loading
          ? Center(
          child: LoadingAnimationWidget.inkDrop(
              color: Colors.blueAccent,
              size: ((screenWidth / 15) + (screenHeight / 15))))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: CircleAvatar(
                    radius: screenWidth / 7,
                    backgroundImage: NetworkImage(
                      "https://switch.unotelecom.com/fixpert/assets/$workerPic",
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
                '$workerName',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                widget.serviceByWorker ?? "service",
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    color: Colors.grey),
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                '$address',
                style: TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'Open Time: $openTime',
                style: TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "About",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              ),
            ),
            SizedBox(height: 3),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "$about",
                style: TextStyle(),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "Reviews",
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: RatingBar.builder(
                initialRating: widget.rate ?? 0,
                minRating: 1,
                direction: Axis.horizontal,
                itemSize: 20,
                maxRating: 5,
                allowHalfRating: true,
                itemCount: 5,
                ignoreGestures: true,
                itemPadding: EdgeInsets.symmetric(horizontal: 0.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {},
              ),
            ),
            acc_type!.contains('worker')
                ? SizedBox()
                : TextButton(
                onPressed: () {
                  if (loggedIn ?? false) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => WriteReviewPage(
                        worker_id: widget.id,
                      ),
                    ));
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Home(neededPage: 3),
                    ));
                  }
                },
                child: Text("Write a review")),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Projects",
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
                itemCount: projectsWithImages.length,
                itemBuilder: (context, index) {
                  String projectName =
                  projectsWithImages.keys.elementAt(index);
                  List<String> images =
                  projectsWithImages.values.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ProjectDetailsPage(
                          projectName: projectName,
                          images: images,
                        ),
                      ));
                    },
                    child: Card(
                      elevation: 5, // Add elevation for shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl:
                                  "https://switch.unotelecom.com/fixpert/assets/worker_projects/${images[0]}",
                                  placeholder: (context, url) => Center(
                                    child: LoadingAnimationWidget
                                        .staggeredDotsWave(
                                      color: Colors.blueAccent,
                                      size: 50,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Icon(
                                        Icons.error,
                                        size: 50,
                                      ),
                                  width: double.infinity,
                                  height: screenHeight * 0.2,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.image,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        images.length.toString(),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              projectName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 49,
            )
          ],
        ),
      ),
    );
  }
}
