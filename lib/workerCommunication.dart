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
        body: communications.length >0 ? ListView.builder(
          itemCount: communications.length,
          itemBuilder: (context, index) {
            bool isRejected = communications[index]['status']!.contains('Rejected !');
            return GestureDetector(
              onLongPress: () {
                deleteQuote(index);
              },
              onTap: () {
Navigator.of(context).push(MaterialPageRoute(builder: (context) => ReplyQuotePage(communications: communications,index:index),));
              },
              child: Card(

                color: isRejected? Colors.red : Colors.grey[200] ,
                margin: EdgeInsets.all(8.0),

                child:  ListTile(

                  title: Text(
                      'client Name: ${communications[index]['client_name']}'),
                  subtitle: Text(
                      'Communication ID: ${communications[index]['communication_id']}'),
                  trailing: Text(
                      'status: ${communications[index]['status']}'),
                ),
              ),
            ) ;
          },
        ) : Center(
          child: Text("No Communications yet!",style: TextStyle(color: Colors.red,fontSize: 18),),
        )
    );
  }
}
