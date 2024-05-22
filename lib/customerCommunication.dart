import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'replyQuote.dart';

class CustomerCommunicationPage extends StatefulWidget {
  const CustomerCommunicationPage({Key? key}) : super(key: key);

  @override
  State<CustomerCommunicationPage> createState() =>
      _CustomerCommunicationPageState();
}

class _CustomerCommunicationPageState extends State<CustomerCommunicationPage> {
  String? customer_id;
  List<Map<String, dynamic>> communications = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      customer_id = sp.getString('user_id');
    });
    getCommunications();
  }

  Future<void> getCommunications() async {
    String url =
        "https://switch.unotelecom.com/fixpert/getQuote.php?customer_id=$customer_id";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Map<String, dynamic>> fetchedCommunications = [];
      for (var item in data) {
        fetchedCommunications.add({
          'worker_name': item['worker_name'],
          'client_name': item['customer_name'],
          'communication_id': item['id'],
          'status': item['status'],
          'city': item['customer_city'],
          'block': item['customer_block'],
          'address': item['customer_address'],
          'details': item['customer_description'],

          'offerd_date': item['offerd_date'] ?? "",
          'type': item['type'],
          'appro_price': item['approximated_price'],
          'note': item['worker_note'] ?? "no note",
          'customer_phone_number': item['customer_number'],
          'worker_phone_number': item['worker_phone_number'],
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
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        communications.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Quote deleted!"),
        backgroundColor: Colors.green,
      ));
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
        title: Text('Communications'),
        centerTitle: true,
      ),
      body: communications.isNotEmpty
          ? ListView.builder(
        itemCount: communications.length,
        itemBuilder: (context, index) {
          bool isRejected =
          communications[index]['status'].contains('Rejected !');
          bool isDone = communications[index]['status'].contains('Done');
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
                    'Worker Name: ${communications[index]['worker_name']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Communication ID: ${communications[index]['communication_id']}',
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Address: ${communications[index]['address']}',
                  ),
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
