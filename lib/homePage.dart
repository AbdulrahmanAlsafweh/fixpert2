import 'package:fixpert/workerPageFromCustomer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'search.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'selectCategory.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

List<dynamic> services = [];

class _HomePageState extends State<HomePage> {
  Future<void> getServices() async {
    final url = 'https://switch.unotelecom.com/fixpert/getServicesWithImage.php';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        services = jsonDecode(response.body);
      });
    }
  }

  @override
  void initState() {
    getProjects();
    getServices().then((value) => setState(() {}));
    super.initState();
  }

  List<dynamic> projects = [];

  Future<void> getProjects() async {
    final url = 'https://switch.unotelecom.com/fixpert/getWorkerProjects.php';
    final request = await http.get(Uri.parse(url));
    if (request.statusCode == 200) {
      setState(() {
        projects = jsonDecode(request.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.grey[100],
        elevation: 2,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/homeLogo.png', height: 40),
            SizedBox(width: 10),
            Text(
              'Fixpert',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            // projects.isNotEmpty ? Text("Our Best Team’s Project This Day",textAlign: TextAlign.start,style: TextStyle(fontSize: ),):SizedBox(height: 0,),
            projects.isNotEmpty
                ? CarouselSlider(

              options: CarouselOptions(
                height: 400.0,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                enlargeCenterPage: true,
              ),
              items: projects.map((i) {

                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child:
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => WorkerPageByOthers(
                                id: int.parse(i['worker_id']),
                                rate: double.parse(i['average_rate'] ?? "0")  ,
                                serviceByWorker: i['service_id'],
                              ),
                            ));
                          },
                          child: CachedNetworkImage(
                            imageUrl: "https://switch.unotelecom.com/fixpert/assets/worker_projects/${i['image']}",
                            placeholder: (context, url) => Stack(
                              alignment: Alignment.center,
                              children: [
                                Opacity(
                                  opacity: 0.7,
                                  child: Image.asset(
                                    "assets/logo.png",
                                    width: 1000,
                                    height: 2000,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                LoadingAnimationWidget.prograssiveDots(
                                  color: Colors.blueAccent,
                                  size: 50,
                                ),
                              ],
                            ),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                            width: 1000,
                            fit: BoxFit.cover,
                          ),
                        ),

                      ),
                    );
                  },
                );
              }).toList(),
            )
                : Container(
              height: 400,
              child: Center(
                child: LoadingAnimationWidget.fourRotatingDots(
                  color: Colors.blueAccent,
                  size: 50.0,
                ),
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Browse By Category",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            services.isNotEmpty
                ? Container(
              height: screenHeight / 4,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: services.length + 1, // Add 1 for the hard-coded item
                itemBuilder: (context, index) {
                  if (index < services.length) {
                    // Display items from the database
                    return GestureDetector(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: CachedNetworkImage(
                                  imageUrl: "https://switch.unotelecom.com/fixpert/assets/services_image/${services[index]['image_uri']}",
                                  placeholder: (context, url) => LoadingAnimationWidget.prograssiveDots(
                                    color: Colors.blueAccent,
                                    size: 50,
                                  ),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                  width: screenWidth / 1.5,
                                  height: screenHeight / 4,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              width: screenWidth / 1.5,
                              height: screenHeight / 4,
                              color: Colors.black.withOpacity(0.4),
                              child: Center(
                                child: Text(
                                  services[index]['name'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        List<int> idOfServices = [int.parse(services[index]['id'])];
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SearchPage(services_id: idOfServices),
                        ));
                      },
                    );
                  } else {
                    // Display the hard-coded item at the end
                    return GestureDetector(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  "assets/viewMore.jpg",
                                  width: screenWidth / 1.5,
                                  height: screenHeight / 4,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              width: screenWidth / 1.5,
                              height: screenHeight / 4,
                              color: Colors.black.withOpacity(0.4),
                              child: Center(
                                child: Text(
                                  "View More",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SelectCategory(services: services),
                        ));
                      },
                    );
                  }
                },
              ),
            )
                : LoadingAnimationWidget.fourRotatingDots(color: Colors.blueAccent, size: 50.0),

            SizedBox(height: 30),
            Stack(
              children: [
                Container(
                  width: screenWidth,
                  height: screenHeight / 1.7,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey[300]!, Colors.grey[100]!],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  top: 10,
                  width: screenWidth - 40,
                  height: screenHeight / 3,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.asset(
                        'assets/homedesign.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: screenHeight / 14,
                  left: 20,
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(text: 'All Your Home \n'),
                        TextSpan(
                          text: 'Needs ',
                          style: TextStyle(
                            backgroundColor: Colors.red,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(text: 'in One Place'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
