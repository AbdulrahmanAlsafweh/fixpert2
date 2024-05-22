import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'replyQuote.dart';
import 'dart:convert';
class WorkerCommunicationPage extends StatefulWidget {
  const WorkerCommunicationPage({super.key});

  @override
  State<WorkerCommunicationPage> createState() => _WorkerCommunicationPageState();
}

class _WorkerCommunicationPageState extends State<WorkerCommunicationPage> {
  String? worker_name;
  String? communication_id;
  String? communication_type;
  List<Map<String, String>> communications = [];
  String? worker_id;
  String? status;
  @override
  void initState() {
    super.initState();
    fetchData().then((value) => getCommunications());
  }
  void dispose() {

    super.dispose();
  }

  Future<void> fetchData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      worker_id = sp.getString('user_id');
    });
  }

  Future<void> getCommunications() async {
    String url =
        "https://switch.unotelecom.com/fixpert/getWorkerQuote.php?worker_id=$worker_id";
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Map<String, String>> fetchedCommunications = [];
      for (var item in data) {
        fetchedCommunications.add({
          'client_name': item['customer_name'],
          'communication_id': item['id'],
          'status' : item['status'],
          'city' :item['customer_city'],
          'block' :item['customer_block'],
          'address' :item['customer_address'],
          'details' :item['customer_description'],
          'offerd_date':item['offerd_date'] ?? "",
          'appro_price' : item['approximated_price'] ,
          'type':item['type'],
          'note' : item['worker_note'] ?? "no note",
          'customer_phone_number' : item['customer_number'] ,
          'worker_phone_number' : item['worker_phone_number'] ,

          // 'communication_type': item['communication_type'],
        });
      }
      setState(() {
        communications = fetchedCommunications;
      });
    } else {
      print('Failed to fetch communications: ${response.statusCode}');
    }
  }


  Future<void> deleteQuote(int index) async {
    String? id = communications[index]['communication_id'];
    String url =
        "https://switch.unotelecom.com/fixpert/cancelQuote.php?quote_id=$id";
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        communications.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Quote deleted!"),backgroundColor: Colors.green,));
    } else {
      print('Failed to fetch communications: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 3,
          backgroundColor: Colors.white,
          // shadowColor: Colors.w,
          title: Center(
            child: Text('Communications'),
          ) ,
        ),
        body: communications.isNotEmpty
            ? ListView.builder(
          itemCount: communications.length,
          itemBuilder: (context, index) {
            bool isRejected =
            communications[index]['status']!.contains('Rejected !');
            bool isDone = communications[index]['status']!.contains('Done');
            return InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ReplyQuotePage(
                      communications: communications,
                      index: index,
                    ),
                  ));
                },
                onLongPress: () {
                  deleteQuote(index);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Type: ${communications[index]['type']}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Clien Name: ${communications[index]['client_name']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Communication ID: ${communications[index]['communication_id']}',
                      ),
                      SizedBox(height: 8),
                      // Text(
                      //   'Address: ${communications[index]['address']}',
                      // ),
                      SizedBox(height: 8),
                      Text(
                        'Status: ${communications[index]['status']}',
                        style: TextStyle(
                          color: isRejected
                              ? Colors.red
                              : (isDone ? Colors.green : Colors.black),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          deleteQuote(index);
                        },
                      ),
                      Divider(),

                    ],

                  ),
                )
            );
          },
        )
            : Center(
          child: Text(
            "No Communications yet!",
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
    );
  }
}
