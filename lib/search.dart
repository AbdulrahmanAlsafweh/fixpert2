import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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
  List<dynamic> selectedServiceIds = []; // List to storre selected service ids
  bool isLoading = false;
  bool isFirstResponseDone=false;
  Future<void> searchWorker(String workerName, List<dynamic> selectedServiceIds) async {
    setState(() {
      isLoading = true;
    });
    String url = baseUrl;
    if (workerName.isNotEmpty) {
      url = "$baseUrl?workerName=$workerName";
    }
    if (selectedServiceIds.isNotEmpty) {
      url +=workerName.isNotEmpty? "&serviceIds=${selectedServiceIds.join(',')}":"?serviceIds=${selectedServiceIds.join(',')}"; // Pass selected service ids as query parameter
    }
    print (url);
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final workerData = jsonDecode(response.body);
        setState(() {
          worker.clear();
          worker = workerData;
          isLoading = false;
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
        isFirstResponseDone=true;
        if (servicesData != null) {
          setState(() {
            services.clear();
            services = servicesData.map((service) {

              service['toggled'] = false;
              if(selectedServiceIds.contains(int.parse(service['id']))){
                print("true");
                        service['toggled'] = true ;
              }
              return service;
            }).toList();

          });
          print("service $services");
        } else {
          // Handle the case when servicesData is null
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
      body:
      isFirstResponseDone ?
      Column(
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
            height:screenHeight/14 ,
            child: ListView.builder(
              padding: EdgeInsets.only(left: 10, right: 10),
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              itemBuilder: (context, index) {
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
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: services[index]['toggled'] ? Colors.grey[400] : Colors.grey[200],borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: <Widget> [
                        services[index]['toggled'] ?
                        Icon(Icons.cancel_outlined) :
                        SizedBox(width: 0, height:0 ),
                                  SizedBox(width: 5,),
                        Text(services[index]['name'],style: TextStyle(fontSize: 15,fontWeight: FontWeight.w400),),
                      ],
                    ),
                  ),
                );
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
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) =>WorkerPageByOthers(id:int.parse(worker[index]['id']) ,) ,));
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 5, bottom: 2),
                    child: Container(
                      height: screenHeight / 11,
                      child: Row(
                        children: [
                          Container(
                            width: 5,
                            color: (worker[index]['availability'].toString().trim() == "1")
                                ? Colors.green
                                : Colors.red,
                          ),
                          Image.network(
                              "https://switch.unotelecom.com/fixpert/assets/${worker[index]['profile_pic'].toString()}"),
                          SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                worker[index]['username'],
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(worker[index]['name'].toString())
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
          :Center(
            child: LoadingAnimationWidget.inkDrop(
                color: Colors.blueAccent,
                size: ((screenWidth / 15) + (screenHeight / 15)))),
    );
  }
}
