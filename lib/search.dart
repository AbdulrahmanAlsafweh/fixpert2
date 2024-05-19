import 'package:fixpert/selectCategory.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'workerPageFromCustomer.dart';

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

  Future<void> searchWorker(String workerName, List<dynamic> selectedServiceIds) async {
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Center(child: Text('Search Workers'),) ,
      //   backgroundColor: Colors.blueAccent,
      ),
      body: isFirstResponseDone
          ? Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              controller: searchTextController,
              onChanged: (value) {
                searchWorker(searchTextController.text, selectedServiceIds);
              },
              decoration: InputDecoration(
                labelText: 'Search by worker name',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    searchWorker(searchTextController.text, selectedServiceIds);
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: screenHeight / 14,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 10),
              scrollDirection: Axis.horizontal,
              itemCount: services.length + 1,
              itemBuilder: (context, index) {
                if (index < services.length) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        services[index]['toggled'] = !services[index]['toggled'];
                        if (services[index]['toggled']) {
                          selectedServiceIds.add(int.parse(services[index]['id']));
                        } else {
                          selectedServiceIds.remove(int.parse(services[index]['id']));
                        }
                        searchWorker(searchTextController.text, selectedServiceIds);
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: services[index]['toggled'] ? Colors.blueAccent : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: <Widget>[
                          if (services[index]['toggled']) Icon(Icons.cancel_outlined, color: Colors.white),
                          if (services[index]['toggled']) SizedBox(width: 5),
                          Text(
                            services[index]['name'],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: services[index]['toggled'] ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => SelectCategory(services: services)));
                    },
                    child: Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "View More",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
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
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => WorkerPageByOthers(
                          serviceByWorker: worker[index]['service_name'],
                          id: int.parse(worker[index]['worker_id']),
                          rate: double.parse((worker[index]['avg_rate']) ?? '0'),
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 5,
                            height: screenHeight / 11,
                            color: (worker[index]['availability'].toString().trim() == "1") ? Colors.green : Colors.red,
                          ),
                          SizedBox(width: 10),
                          ClipOval(
                            child: Image.network(
                              "https://switch.unotelecom.com/fixpert/assets/${worker[index]['profile_pic'].toString()}",
                              width: screenWidth / 6,
                              height: screenWidth / 6,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      worker[index]['worker_name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                      ),
                                    ),
                                    worker[index]['avg_rate'] != null && worker[index]['avg_rate'] != ''
                                        ?
                                    RatingBarIndicator(
                                      rating: double.parse(worker[index]['avg_rate'] ?? "0") ,
                                      itemBuilder: (context, index) => Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      itemCount: 5,
                                      itemSize: 18.0,
                                      direction: Axis.horizontal,
                                    )
                                        : SizedBox(),
                                  ],
                                ),
                                Text(
                                  worker[index]['service_name'],
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
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
        ),
      ),
    );
  }
}
