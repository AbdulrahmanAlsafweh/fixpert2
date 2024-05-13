import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
class ChooseLocationPage extends StatefulWidget {
  const ChooseLocationPage({Key? key}) : super(key: key);

  @override
  State<ChooseLocationPage> createState() => _ChooseLocationPageState();
}

class _ChooseLocationPageState extends State<ChooseLocationPage> {
  List<dynamic> locations = [];
  int? selectedIndex;
  String acc_type = '';
  String user_id = '' ;
  String selectedLocation ='' ;
  int? id ;
  String baseUrl='https://switch.unotelecom.com/fixpert/updateLocation.php';
  TextEditingController searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchLocations();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    acc_type = sp.getString('acc_type') ?? '';
    user_id = sp.getString('user_id') ?? '';
    print(user_id);
  }
  Future<void> updateLocation() async{
    String url ="$baseUrl?user_id=$user_id&acc_type=$acc_type&address=$selectedLocation";
    final request = await http.get(Uri.parse(url));
    if (request.statusCode == 200){
      String message = jsonDecode(request.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }
  Future<void> fetchLocations() async {
    String url = 'https://switch.unotelecom.com/fixpert/assets/lib.json';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        locations = jsonDecode(response.body);
        print(locations);
      });
    }
  }

  void filterLocations(String query) {
    List<dynamic> filteredLocations = locations.where((location) {
      String city = location['CITY / VILLAGE'].toString().toLowerCase();
      String district = location['DISTRICT '].toString().toLowerCase();
      String area = location['AREA'].toString().toLowerCase();

      return city.contains(query.toLowerCase()) ||
          district.contains(query.toLowerCase()) ||
          area.contains(query.toLowerCase());
    }).toList();

    setState(() {
      locations = filteredLocations;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child:Icon(Icons.done) ,
        onPressed: () {
            selectedLocation.isEmpty ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Choose address"),backgroundColor: Colors.red,)) : Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Home(),));
        },
      ),
      appBar: AppBar(
        title: Center(
          child:Text('Choose your location') ,
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchTextController,
              onChanged: (value) {
                filterLocations(value);
                if(value.isEmpty)
                  fetchLocations();
              },
              decoration: InputDecoration(
                labelText: 'Search (ex : Mina) ',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    filterLocations(searchTextController.text);
                  },
                ),
              ),
            ),
          ),


          Expanded(
            child: Container(
              child: ListView.builder(
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                         selectedLocation =
                            "${locations[index]['CITY / VILLAGE'] ?? ""}, ${locations[index]['DISTRICT ']}, ${locations[index]['AREA']}";
                        print(selectedLocation);
                      });
                    },
                    child: Container(
                      color: selectedIndex == index ? Colors.blue[100] : Colors.transparent,
                      child: ListTile(
                        title: Text("${locations[index]['CITY / VILLAGE'] ?? ""}, ${locations[index]['DISTRICT ']}, ${locations[index]['AREA']}"),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
