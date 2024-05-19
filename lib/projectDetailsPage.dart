import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'photoView.dart';
import 'package:http/http.dart' as http;

class ProjectDetailsPage extends StatefulWidget {
  final String projectName;
  final List<String> images;
  final String? worker_id;

  ProjectDetailsPage(
      {required this.projectName, required this.images, this.worker_id});

  @override
  _ProjectDetailsPageState createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {

  late String projectDetails;
  bool isLoadingDetails = false;

  @override
  void initState() {
    super.initState();
    getProjectDetails();
    projectDetails = ''; // Initialize projectDetails
  }

  Future<void> getProjectDetails() async {
    setState(() {
      isLoadingDetails = true;
    });

    String url = "https://switch.unotelecom.com/fixpert/getProjectDetails.php?worker_id=${widget.worker_id}&project_name=${widget.projectName}";
    print("fetching $url");
    final request = await http.get(Uri.parse(url));
    if (request.statusCode == 200) {
      setState(() {
        Map<String,dynamic> data = jsonDecode(request.body);
        projectDetails=data["details"];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch project details'),
        ),
      );
      print("Failed to fetch project details: ${request.statusCode}");
    }

    setState(() {
      isLoadingDetails = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.projectName,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: isLoadingDetails
                ? CircularProgressIndicator() // Show loading indicator
                : Text(
              projectDetails.isNotEmpty ? projectDetails : 'No details available',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: 1.0,
              ),
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ImageViewerPage(
                          imageUrl:
                          "https://switch.unotelecom.com/fixpert/assets/worker_projects/${widget.images[index]}",
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl:
                        "https://switch.unotelecom.com/fixpert/assets/worker_projects/${widget.images[index]}",
                        placeholder: (context, url) => Center(
                          child: LoadingAnimationWidget.prograssiveDots(
                            color: Colors.blueAccent,
                            size: 50,
                          ),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Icon(
                            Icons.error,
                            color: Colors.red,
                            size: 50,
                          ),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
