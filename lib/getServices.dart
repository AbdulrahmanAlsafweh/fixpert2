import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'availability.dart';
import 'home.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Services extends StatefulWidget {
  final String? email;
  final String? password;
  Services({Key? key, this.email, this.password}) : super(key: key);

  @override
  State<Services> createState() => _ServicesState();
}




class _ServicesState extends State<Services> {
  String baseUrl = "https://switch.unotelecom.com/fixpert/getservices.php";
  List<dynamic> services = [];
  TextEditingController searchTextController = TextEditingController();
  bool isServiceSelected = false;
  int selectedServiceIndex = -1;
  String? selectedService;
  String? selectedServiceId;

  Future<void> fetchData(String serviceName) async {
    String url = baseUrl;

    if (serviceName.isNotEmpty) {
      url += "?service=$serviceName";
    }
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        services.clear();
        services = json.decode(response.body);
      });
    }
  }
// this function will insert new worker
  Future<void> signup() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String baseURL = 'https://switch.unotelecom.com/fixpert/newWorker.php';
    String email=widget.email!;
    String password=widget.password!;
    String url = '$baseURL?user_email=$email&user_password=$password&user_service=$selectedServiceId';
    print(selectedServiceId);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(responseData['message']),
        duration: Duration(seconds: 3),
        backgroundColor:
        responseData['message'].toLowerCase().contains('ready')
            ? Colors.green
            : Colors.red,
      ));


      if (responseData['message'].toLowerCase().contains('ready')) {
        sp.setBool("loggedIn", true);//we set true to the logged in varuable so i can track if the user is logged in or not
          String urlToGetUserId='https://switch.unotelecom.com/fixpert/getUserInfo.php?user_email=$email';
          final response=await http.get(Uri.parse(urlToGetUserId));
          if(response.statusCode == 200){
            Map<String , dynamic> responseData=jsonDecode(response.body);
            sp.setString('user_id', responseData['user_id']);//i save the new user id that create new account
            sp.setString('username', responseData['username']);
            sp.setString('address',responseData['address']);

          }
        // Navigate to the home page to trigger rebuild
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Availability(user_id: responseData['user_id'],)),
        );
      } else {
        sp.setBool("loggedIn", false);
      }
    }
  }
  @override
  void initState() {
    super.initState();
    fetchData(""); // Fetch all services initially
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Services'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchTextController,
              onChanged: (value) {
                fetchData(value);
              },
              decoration: InputDecoration(
                labelText: 'Search by service name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    fetchData(searchTextController.text);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isServiceSelected = true;
                      selectedServiceIndex = index;
                      selectedService = services[index]['name'].toString();
                      selectedServiceId=services[index]['id'];
                      print(selectedService);
                    });
                  },
                  child: Container(
                    color: selectedServiceIndex == index ? Colors.blue[100] : null,
                    child: ListTile(
                      title: Text(services[index]['name'].toString()),
                    ),
                  ),
                );
              },
            ),
          ),
          Visibility(
            visible: isServiceSelected,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  signup();
                  // Use selectedService here
                  print('Selected service: $selectedService');
                },
                child: Text('Continue'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

