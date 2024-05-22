import 'package:fixpert/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'photoView.dart';
import 'replyDialog.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ReplyQuotePage extends StatefulWidget {
  final List<Map<String, dynamic>> communications;
  final int index;
  const ReplyQuotePage(
      {Key? key, required this.communications, required this.index})
      : super(key: key);

  @override
  State<ReplyQuotePage> createState() => _ReplyQuotePageState();
}

class _ReplyQuotePageState extends State<ReplyQuotePage> {
  List<Map<String, String>> images = [];

  @override
  void initState() {
    super.initState();
    fetchData().then((value) => getCommunications());
  }

  String? acc_type;
  Future<void> fetchData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      acc_type = sp.getString("acc_type");
    });
  }

  Future<void> getCommunications() async {
    String url =
        "https://switch.unotelecom.com/fixpert/getQuoteImages.php?quote_id=${widget.communications[widget.index]['communication_id']}";
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Map<String, String>> fetchedCommunications = [];
      for (var item in data) {
        fetchedCommunications.add({'image_uri': item['image']});
      }
      setState(() {
        images = fetchedCommunications;
      });
    } else {
      print('Failed to fetch communications: ${response.statusCode}');
    }
  }

  String? price;
  DateTime? date;
  String? notes;
  void _showReplyDialog(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isFast =widget.communications[widget.index]['type']  =="fast fixing" ? true :false ;

        return ReplyDialog(
          fastFixing: isFast,
          onReply:
              (String price,  DateTime date, String notes, String phoneNumber ) {
            replyQoute(id, price, notes, date, phoneNumber);
            setState(() {
              this.price = price;
              this.date = date;
              this.notes = notes;
            });
            // Handle sending the reply here
            print('Approximation Price: $price');
            print('Offered Date: $date');
            print('Notes: $notes');
            print('Notes: $phoneNumber');
          },
        );
      },
    );
  }

  Future<void> replyQoute(String? id, String price, String notes, DateTime date,
      String phoneNumber) async {
    String url =
        "https://switch.unotelecom.com/fixpert/replyQuote.php?quote_id=$id&approximated_price=$price&offerd_date=$date&note=$notes&worker_phone_number=$phoneNumber";
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Home(neededPage: 2),
      ));
    } else {
      print('Failed to fetch communications: ${response.statusCode}');
    }
  }

  Future<void> rejectQuote(String? id) async {
    String url =
        "https://switch.unotelecom.com/fixpert/rejectQuote.php?quote_id=$id";
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Home(neededPage: 2),
      ));
    } else {
      print('Failed to fetch communications: ${response.statusCode}');
    }
  }

  Future<void> customerAccept(String? id) async {
    String url =
        "https://switch.unotelecom.com/fixpert/customerAccept.php?quote_id=$id";
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Home(neededPage: 2),
      ));
    } else {
      print('Failed to fetch communications: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.communications.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Reply to Quote'),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
        ),
        body: Center(
          child: Text(
            'No communications available.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    bool isRejected =
        widget.communications[widget.index]['status']!.contains('Rejected !');
    bool waiting = widget.communications[widget.index]['status']!
        .contains("waiting for customer");
    bool waitingWorker = widget.communications[widget.index]['status']!
        .contains("waiting for worker");
    bool isDone =
        widget.communications[widget.index]['status']!.contains("Done");
    final communication = widget.communications[widget.index];

    return Scaffold(
      appBar: AppBar(
        title: Text('Reply to Quote'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      acc_type!.contains('worker')
                          ? Text(
                              'Client Name: ${communication['client_name']}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            )
                          : Text(
                              'Worker Name: ${communication['worker_name']}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                      SizedBox(height: 8),
                      _buildInfoRow('Communication ID:',
                          communication['communication_id']),
                      _buildInfoRow('Status:', communication['status']),
                      _buildInfoRow('City:', communication['city']),
                      _buildInfoRow('Block:', communication['block']),
                      _buildInfoRow('Address:', communication['address']),
                      _buildInfoRow('Details:', communication['details']),
                      ...(!communication['status']!
                                  .contains('waiting for customer') &&
                              !communication['status']!
                                  .contains('Rejected !') &&
                              !communication['status']!.contains('Done')
                          ? [
                              _buildInfoRow('client phone number:',
                                  communication['customer_phone_number'])
                            ]
                          : []),
                      ...(!communication['status']!
                              .contains('waiting for worker')
                          ? [
                              if (acc_type!.contains("worker"))
                                _buildInfoRow('Your Offered Date:',
                                    communication['offered_date'])
                              else
                                _buildInfoRow('Worker Offered Date:',
                                    communication['offered_date']),
                              if (acc_type!.contains("worker"))
                                _buildInfoRow('Your approximated price:',
                                    communication['appro_price'])
                              else
                                _buildInfoRow('Worker approximated price:',
                                    communication['appro_price']),
                              if (acc_type!.contains("worker"))
                                _buildInfoRow(
                                    'Your note:', communication['note'])
                              else
                                _buildInfoRow(
                                    'Worker note:', communication['note']),
                              if (acc_type!.contains("worker"))
                                _buildInfoRow('client phone number:',
                                    communication['customer_phone_number'])
                              else
                                _buildInfoRow('Worker phone number:',
                                    communication['worker_phone_number']),
                            ]
                          : []),
                      SizedBox(height: 16),
                      if (!isRejected &&
                          !waiting &&
                          acc_type!.contains('worker') &&
                          !isDone)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 5,
                              ),
                              onPressed: () {
                                _showReplyDialog(
                                    communication['communication_id']!);
                              },
                              child: Text('Reply'),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 5,
                              ),
                              onPressed: () {
                                rejectQuote(communication['communication_id']);
                              },
                              child: Text('Reject'),
                            ),
                          ],
                        ),
                      if (!isRejected &&
                          !waitingWorker &&
                          !acc_type!.contains('worker') &&
                          !isDone)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 5,
                              ),
                              onPressed: () {
                                customerAccept(
                                    communication['communication_id']!);
                              },
                              child: Text('Accept'),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 5,
                              ),
                              onPressed: () {
                                rejectQuote(communication['communication_id']);
                              },
                              child: Text('Reject'),
                            ),
                          ],
                        )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Images:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              images.isEmpty
                  ? Center(
                      child: Text('No images available.'),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        final imageUrl =
                            "https://switch.unotelecom.com/fixpert/assets/quotes/${images[index]['image_uri']!}";
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ImageViewerPage(imageUrl: imageUrl),
                              ),
                            );
                          },
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
