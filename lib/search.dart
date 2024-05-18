import 'package:fixpert/selectCategory.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:animated_rating_stars/animated_rating_stars.dart';
import 'workerPageFromCustomer.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class SearchPage extends StatefulWidget {
  final List<int>? services_id;

  const SearchPage({Key? key, this.services_id}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchTextController = TextEditingController();
  String baseUrl = "https://switch.unotelecom.com/fixpert/getWorker.php";
  List<dynamic> services = [];
  List<dynamic> worker = [];
  List<dynamic> selectedServiceIds = [];
  bool isLoading = false;
  bool isFirstResponseDone = false;

  Future<void> searchWorker(
      String workerName, List<dynamic> selectedServiceIds) async {
    setState(() {
      isLoading = true;
    });
    String url = baseUrl;
    if (workerName.isNotEmpty) {
      url = "$baseUrl?workerName=$workerName";
    }
    if (selectedServiceIds.isNotEmpty) {
      url += workerName.isNotEmpty
          ? "&serviceIds=${selectedServiceIds.join(',')}"
          : "?serviceIds=${selectedServiceIds.join(',')}";
    }
    print(url);
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final workerData = jsonDecode(response.body);
        print(workerData);
        setState(() {
          worker.clear();
          worker = workerData;
          worker.sort((a, b) {
            var avgRateA = a["avg_rate"];
            var avgRateB = b["avg_rate"];

            if (avgRateA == null && avgRateB == null) {
              return 0;
            } else if (avgRateA == null) {
              return 1;
            } else if (avgRateB == null) {
              return -1;
            } else {
              return avgRateB.compareTo(avgRateA);
            }
          });
          isLoading = false;
          print(worker);
        });
      } else {
        print('Error fetching worker data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error searching workers: $error');
    }
    print(selectedServiceIds);
  }

  Future<void> getServices() async {
    String url = 'https://switch.unotelecom.com/fixpert/getServicesFilter.php';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final servicesData = jsonDecode(response.body);
        isFirstResponseDone = true;
        if (servicesData != null) {
          setState(() {
            services.clear();
            services = servicesData.map((service) {
              service['toggled'] = false;
              if (selectedServiceIds.contains(int.parse(service['id']))) {
                print("true");
                service['toggled'] = true;
              }
              return service;
            }).toList();
          });
          print("service $services");
        } else {
          print('Error: servicesData is null');
        }
      } else {
        print('Error fetching services data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching services: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.services_id != null) {
      selectedServiceIds = widget.services_id!;
      searchWorker("", selectedServiceIds);
    } else {
      searchWorker("", selectedServiceIds);
    }
    getServices();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: isFirstResponseDone
          ? Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextField(
                    controller: searchTextController,
                    onChanged: (value) {
                      searchWorker(
                          searchTextController.text, selectedServiceIds);
                    },
                    decoration: InputDecoration(
                      labelText: 'Search by worker name',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          searchWorker(
                              searchTextController.text, selectedServiceIds);
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: screenHeight / 14,
                  child: ListView.builder(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    scrollDirection: Axis.horizontal,
                    itemCount: services.length + 1,
                    itemBuilder: (context, index) {
                      if (index < services.length){
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            services[index]['toggled'] =
                                !services[index]['toggled'];
                            if (services[index]['toggled']) {
                              selectedServiceIds
                                  .add(int.parse(services[index]['id']));
                            } else {
                              selectedServiceIds
                                  .remove(int.parse(services[index]['id']));
                            }
                            searchWorker(
                                searchTextController.text, selectedServiceIds);
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: services[index]['toggled']
                                ? Colors.grey[400]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: <Widget>[
                              services[index]['toggled']
                                  ? Icon(Icons.cancel_outlined)
                                  : SizedBox(width: 0, height: 0),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                services[index]['name'],
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                      );} else{
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => SelectCategory(services: services,),));
                      },
                      child: Container(
                        margin: EdgeInsets.all(5),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "View More",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                    );
                      }
                    },
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: worker.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => WorkerPageByOthers(
                                      serviceByWorker: worker[index]['service_name'],
                                        id: int.parse(
                                            worker[index]['worker_id']),
                                        rate: double.parse((worker[index]
                                                ['avg_rate']) ??
                                            '0')),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.only(left: 5, bottom: 2),
                                child: Container(
                                  height: screenHeight / 11,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 5,
                                        color: (worker[index]['availability']
                                                    .toString()
                                                    .trim() ==
                                                "1")
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      Image.network(
                                          width: 75,
                                          "https://switch.unotelecom.com/fixpert/assets/${worker[index]['profile_pic'].toString()}"),
                                      SizedBox(width: 10),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            constraints: BoxConstraints(
                                                maxWidth: screenWidth - 100),
                                            child: Row(
                                              children: [
                                                Text(
                                                  worker[index]['worker_name'],
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Spacer(),
                                                worker[index]['avg_rate'] !=
                                                            null &&
                                                        worker[index]
                                                                ['avg_rate'] !=
                                                            ''
                                                    ? RatingBar.builder(
                                                        initialRating: double
                                                            .parse(worker[index]
                                                                    [
                                                                    'avg_rate'] ??
                                                                "0"),
                                                        minRating: 1,
                                                        direction:
                                                            Axis.horizontal,
                                                        itemSize: 20,
                                                        maxRating: 5,
                                                        allowHalfRating: true,
                                                        itemCount: 5,
                                                        ignoreGestures: true,
                                                        itemPadding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    0.0),
                                                        itemBuilder:
                                                            (context, _) =>
                                                                Icon(
                                                          Icons.star,
                                                          color: Colors.amber,
                                                        ),
                                                        onRatingUpdate:
                                                            (rating) {},
                                                      )
                                                    : SizedBox(),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            worker[index]['service_name'],
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 18,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            )
          : Center(
              child: LoadingAnimationWidget.inkDrop(
              color: Colors.blueAccent,
              size: ((screenWidth / 15) + (screenHeight / 15)),
            )),
    );
  }
}
