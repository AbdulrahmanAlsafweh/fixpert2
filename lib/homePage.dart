import 'package:fixpert/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'search.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

List<dynamic> services = [];
Future<void> getServices() async {
  final url = 'https://switch.unotelecom.com/fixpert/getServicesWithImage.php';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    List<dynamic> responseData = jsonDecode(response.body);
    services = responseData;
    print(services);
  }
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    getServices();
    super.initState();

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
          actions: [
            Spacer(),
            Container(child: Image.asset('assets/homeLogo.png')),
            SizedBox(
              width: 3,
            ),
            Text(
              'Fixpert',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
            ),
            Spacer(),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              CarouselSlider(
                options: CarouselOptions(
                    height: 400.0,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 3)),
                items: [1, 2, 3, 4, 5].map((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(color: Colors.amber),
                          child: Text(
                            'text $i',
                            style: TextStyle(fontSize: 16.0),
                          ));
                    },
                  );
                }).toList(),
              ),
              // Spacer(),
              SizedBox(
                height: 100,
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Browse By Category",
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Container(
                height: screenHeight / 4,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      child:Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: ClipRRect(
                                  child: Image.network(
                                    "https://switch.unotelecom.com/fixpert/assets/services_image/${services[index]['image_uri']}",
                                    width: screenWidth / 1.5,
                                    height: screenHeight / 4,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                )),
                          ),
                          ClipRRect(

                            child:  Container(

                              child: Align(
                                  child: Text(services[index]['name'],style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,),),
                                  alignment: Alignment.center
                              ),

                              color: Colors.grey[300]!.withOpacity(0.6),
                              width: screenWidth / 1.5,

                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),



                        ],
                      ) ,
                      onTap: () {
                        List<int> idOfServices=[int.parse(services[index]['id'])];
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) =>SearchPage(services_id: idOfServices ,),));
                      },
                    ) ;
                  },
                ),
              ),
              SizedBox(
                height: 100,
              ),
              Stack(
                fit: StackFit.passthrough,
                children: [
                  Container(
                    width: screenWidth,
                    height: screenHeight / 1.7,
                    color: Colors.grey[200],
                  ),
                  // Positioned(
                  //   left: 20,
                  //   top: -15,
                  //   child: Container(
                  //     width: screenWidth / 2.3,
                  //     height: screenHeight / 3,
                  //     decoration: BoxDecoration(
                  //       color: Colors.grey[300],
                  //       borderRadius: BorderRadius.circular(15),
                  //     ),
                  //     child:
                  //     SizedBox(), // You can add child widgets here if needed
                  //   ),
                  // ),
                  Positioned(
                    left: 23,
                    top: 5,
                    width: screenHeight / 2.3,
                    height: screenHeight / 3,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            20.0), // Adjust the value as needed
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5), // Shadow color
                            spreadRadius: 5, // Spread radius
                            blurRadius: 7, // Blur radius
                            offset: Offset(0, 3), // Offset
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            20.0), // Adjust the value as needed
                        child: Image.asset(
                          'assets/homedesign.jpg',
                          fit: BoxFit
                              .cover, // Optional: adjust the fit as per your requirement
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
                          fontWeight: FontWeight.w500,
                          color: Colors.black, // Set default text color
                        ),
                        children: [
                          TextSpan(
                            text: 'All Your Home \n ',
                          ),
                          TextSpan(
                            text: 'Needs',
                            style: TextStyle(
                              backgroundColor:
                                  Colors.red, // Set red background for "Needs"
                            ),
                          ),
                          TextSpan(
                            text: ' In One Place',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
              // Image.asset('assets/allYourHomeNeeds.png',width: screenWidth,height: screenHeight,),
            ],
          ),
        ));
  }
}
