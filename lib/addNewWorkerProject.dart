import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
class AddNewWorkerProject extends StatefulWidget {
  final String worker_id;
  const AddNewWorkerProject({Key? key ,required this.worker_id}) : super(key: key);

  @override
  _AddNewWorkerProjectState createState() => _AddNewWorkerProjectState();
}

class _AddNewWorkerProjectState extends State<AddNewWorkerProject> {
  List<XFile>? _imageFiles = []; // List to store selected images
  bool loading=false;
  TextEditingController projectNameController= TextEditingController();
  TextEditingController projectDetailsController=TextEditingController();
  Future<void> _selectImages() async {
    List<XFile>? selectedImages =
    await ImagePicker().pickMultiImage(imageQuality: 50);
    if (selectedImages != null && selectedImages.isNotEmpty) {
      setState(() {
        _imageFiles = selectedImages;
      });
    }
  }


  // Future<void> _uploadImages() async {
  //   if (_imageFiles != null && _imageFiles!.isNotEmpty) {
  //     // Perform upload logic here, like sending images to a server or saving them in the local database
  //     // Example:
  //     for (var imageFile in _imageFiles!) {
  //       // Upload logic for each image file
  //       // Use http package or any other method to upload
  //       // http.post(...);
  //     }
  //   }
  // }
  Future<void> _uploadImages() async {
    if (_imageFiles != null && _imageFiles!.isNotEmpty) {
      // Example PHP script URL
      String project_name=projectNameController.text.trim();
      String project_details=projectDetailsController.text.trim();

      if (project_name.isNotEmpty ) {
        // Encode parameters
        String encodedProjectName = Uri.encodeComponent(project_name);
        String encodedProjectDetails = Uri.encodeComponent(project_details);

        var url = Uri.parse("https://switch.unotelecom.com/fixpert/addNewWorkerProject.php?worker_id=${widget.worker_id}&project_name=$encodedProjectName");
        print(url);
        // Check if project details is not empty and add it to the URL if not
        if (encodedProjectDetails.isNotEmpty) {
          url = Uri.parse("$url&project_details=$encodedProjectDetails");
        }
        print(url);
      // var url = Uri.parse("https://switch.unotelecom.com/fixpert/addNewWorkerProject.php?worker_id=${widget.worker_id}&project_name=${project_name}&project_details=${project_details}");
      // print(url);
      // Create a multipart request
      var request = http.MultipartRequest('POST', url);

      // Add images to the request
      for (var imageFile in _imageFiles!) {
        var fileStream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();
        var multipartFile = http.MultipartFile(
          'images[]', // This should match the name attribute in your PHP script
          fileStream,
          length,
          filename: imageFile.name,
        );
        request.files.add(multipartFile);
      }

      // Send the request
      var response = await request.send();

      // Check the response status
      if (response.statusCode == 200) {
        // Request successful
        print('Images uploaded successfully');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Project added successfully"),backgroundColor: Colors.green,));
        setState(() {
          loading=false;
        });
        print(response.reasonPhrase);

      } else {
        // Request failed
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("There is an error,Try again!"),backgroundColor: Colors.red,));
        setState(() {
          loading=false;
        });
        print('Failed to upload images');
      }
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New  Project'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return  _imageFiles!.isNotEmpty ? ( projectNameController.text.isNotEmpty ? AlertDialog(
                    title: Text("Upload Project"),
                    content: Text("Do you want to upload the project?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                        },
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            loading=true;
                          });
                          _uploadImages(); // Call the method to upload images
                          Navigator.pop(context); // Close the dialog
                        },
                        child: Text("Upload"),
                      ),
                    ],
                  ) : AlertDialog(

                    title:Center(
                      child: Text("Caution!",style: TextStyle(color: Colors.red,fontSize: 18),),
                    ) ,
                    content: Text("Please fill the project name",textAlign:TextAlign.center),

                  ))
                  :AlertDialog(
                    title: Center(child: Text("Caution!",style: TextStyle(color: Colors.red,fontSize: 18),),),
                    content: Text("Please add photos then try to upload the project",textAlign:TextAlign.center),

                  );
                },
              );
            },
            icon: Icon(Icons.upload_sharp,size: 32,),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'select images',
        onPressed: () {
          _selectImages();
        },
        child: Icon(Icons.add),
      ),
      body:
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
              SizedBox(height: 10,),
            Padding(padding: EdgeInsets.only(left: 10,right: 10),child: TextField(
              controller: projectNameController,
            maxLength: 30,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              decoration: InputDecoration(
                labelText: "Project Name",
              ),),

            ),

            SizedBox(height: 10,),
            Padding(padding: EdgeInsets.only(left: 10,right: 10),child: TextField(
              maxLength: 120,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              controller: projectDetailsController,

              decoration: InputDecoration(

                hintMaxLines: 2,
                labelText: "Project Details",
              ),),

            ),
            // GestureDetector(
            //
            //   onTap: _selectImages,
            //   child: Container(
            //       height: 100,
            //       width:50,
            //       color: Colors.grey,
            //       child:
            //       Row(
            //         children: <Widget>[
            //           Icon(Icons.add),
            //
            //           Text('Select Images'),
            //
            //         ],
            //       )
            //
            //   ),
            // )

            if (_imageFiles != null && _imageFiles!.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _imageFiles!.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.all(4),
                                width: 200,
                                height: 200,
                                child: Image.file(
                                  File(_imageFiles![index].path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _imageFiles!.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red,
                                    ),
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            loading?
                Center(
                  child:CircularProgressIndicator() ,
                )
            :SizedBox(height: 0,),
            // if (_imageFiles != null && _imageFiles!.isNotEmpty)
            //   Expanded(
            //     child: ListView.builder(
            //       itemCount: _imageFiles!.length,
            //       itemBuilder: (context, index) {
            //
            //         return ListTile(
            //           title: Image.file(
            //             File(_imageFiles![index].path),
            //             fit: BoxFit.cover,
            //           ),
            //         );
            //       },
            //     ),
            //   ),
            // ElevatedButton(
            //   onPressed: _uploadImages,
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.blue, // Background color
            //     // onPrimary: Colors.white, // Text color
            //     padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24), // Button padding
            //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Button border radius
            //     textStyle: TextStyle(fontSize: 16), // Text style
            //   ),
            //   child: Text('Upload the project'),
            // )
          ],
        ),
      )
    );
  }
}
