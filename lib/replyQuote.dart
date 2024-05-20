import 'package:fixpert/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'photoView.dart';
import 'replyDialog.dart';
class ReplyQuotePage extends StatefulWidget {
  final List<Map<String, String>> communications;
  final int index;
  const ReplyQuotePage({Key? key, required this.communications , required this.index}) : super(key: key);

  @override
  State<ReplyQuotePage> createState() => _ReplyQuotePageState();
}

class _ReplyQuotePageState extends State<ReplyQuotePage> {
  List<Map<String, String>> images = [];

  @override
  void initState() {
    super.initState();
    getCommunications();
  }

  Future<void> getCommunications() async {
    String url = "https://switch.unotelecom.com/fixpert/getQuoteImages.php?quote_id=${widget.communications[widget.index]['communication_id']}";
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
  void _showReplyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ReplyDialog(
          onReply: (String price, DateTime time, String notes) {
            // Handle sending the reply here
            print('Approximation Price: $price');
            print('Offered Time: $time');
            print('Notes: $notes');
          },
        );
      },
    );
  }

  Future<void> rejectQuote(String? id) async {
    String url = "https://switch.unotelecom.com/fixpert/rejectQuote.php?quote_id=$id";
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => Home(neededPage: 2,),));
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
        ),
        body: Center(
          child: Text(
            'No communications available.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }
bool isRejected = widget.communications[widget.index]['status']!.contains('Rejected !');
    final communication = widget.communications[widget.index];
    return Scaffold(
      appBar: AppBar(
        title: Text('Reply to Quote'),
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Client Name: ${communication['client_name']}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildInfoRow('Communication ID:', communication['communication_id']),
                      _buildInfoRow('Status:', communication['status']),
                      _buildInfoRow('City:', communication['city']),
                      _buildInfoRow('Block:', communication['block']),
                      _buildInfoRow('Address:', communication['address']),
                      _buildInfoRow('Details:', communication['details']),
                      SizedBox(height: 16),
                      !isRejected ?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
        backgroundColor:Colors.blue,
                              foregroundColor: Colors.white,

                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // Rounded corners
                              ),
                              elevation: 5, // Shadow elevation
                            ),
                            onPressed: () {
                               _showReplyDialog();
                            },
                            child: Text('Reply'),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // Rounded corners
                              ),
                              elevation: 5, // Shadow elevation
                            ),
                            onPressed: () {
                              rejectQuote( communication['communication_id'] );
                            },
                            child: Text('Reject'),
                          ),
                        ],
                      ):
                          SizedBox(height: 0,width: 0,)

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
                  final imageUrl = "https://switch.unotelecom.com/fixpert/assets/quotes/${images[index]['image_uri']!}";
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageViewerPage(imageUrl: imageUrl),
                        ),
                      );
                    },
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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
            style: TextStyle(fontWeight: FontWeight.bold),
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
