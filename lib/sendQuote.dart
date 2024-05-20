import 'package:fixpert/home.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class AppointmentPage extends StatefulWidget {

  @override
  final String worker_id;
  final String? worker_name;
  const AppointmentPage({Key? key ,required this.worker_id, this.worker_name}) : super(key: key);
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  TextEditingController addressController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController blockController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  String? customer_id='';
  String? customer_name='';
  void _sendAppointmentRequest() {
    String address = addressController.text.trim();
    String description = descriptionController.text.trim();
    String city = cityController.text.trim();
    String state = stateController.text.trim();
    String block = blockController.text.trim();
    String phoneNumber = phoneNumberController.text.trim();

print(address);
print(description);
print(block);
print(phoneNumber);
print(state);
print(city);
    if (address.isNotEmpty && description.isNotEmpty && city.isNotEmpty && state.isNotEmpty && block.isNotEmpty && phoneNumber.isNotEmpty) {
      // Call the method to upload images or perform other actions here
      _uploadImages(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all requirements!"), backgroundColor: Colors.red));
    }
  }
  Future<void> _uploadImages(BuildContext context) async {
    print("nll");
    String address = addressController.text.trim();
    String description = descriptionController.text.trim();

    String city = cityController.text.trim();
    String state = stateController.text.trim();
    String block = blockController.text.trim();
    String phoneNumber = phoneNumberController.text.trim();
    if (_imageFiles != null && _imageFiles!.isNotEmpty) {
      print("not null");
      print(_imageFiles);


      var url = Uri.parse("https://switch.unotelecom.com/fixpert/sendQuote.php?worker_id=${widget.worker_id}&worker_name=${widget.worker_name}&customer_id=$customer_id&customer_name=$customer_name&customer_city=$city&quote_details=$description&customer_state=$state&customer_block=$block&customer_address=$address&customer_phone_number=$phoneNumber");


      print(url);

      var request = http.MultipartRequest('POST', url);

      for (var imageFile in _imageFiles!) {
        var fileStream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();
        var multipartFile = http.MultipartFile(
          'images[]',
          fileStream,
          length,
          filename: imageFile.name,
        );
        request.files.add(multipartFile);
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Images uploaded successfully');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Quote Sent !"),backgroundColor: Colors.green,));
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Home(neededPage: 2,),));
        setState(() {
          // loading=false;
        });
        print(response.reasonPhrase);

      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("There is an error,Try again!"),backgroundColor: Colors.red,));
        setState(() {
          // loading=false;
        });
        print('Failed to upload images');
      }

    }
    else{
      var url = Uri.parse("https://switch.unotelecom.com/fixpert/sendQuote.php?worker_id=${widget.worker_id}&worker_name=${widget.worker_name}&customer_id=$customer_id&customer_name=$customer_name&customer_city=$city&quote_details=$description&customer_state=$state&customer_block=$block&customer_address=$address&customer_phone_number=$phoneNumber");
      print(url);
      final request = await http.get(url);
      if(request.statusCode == 200){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Quote Sent !"),backgroundColor: Colors.green,));
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Home(neededPage: 2,),));
        setState(() {
          // loading=false;
        });
      }
    }
  }

  Future<void> fetchData() async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      customer_id = sp.getString("user_id");
      customer_name = sp.getString('username');
    });
  }
  @override
  void initState(){
    super.initState();
    fetchData();
  }
  List<XFile>? _imageFiles = [];
  Future<void> _selectImages() async {
    List<XFile>? selectedImages =
        await ImagePicker().pickMultiImage(imageQuality: 50);
    if (selectedImages != null && selectedImages.isNotEmpty) {
      setState(() {
        _imageFiles = selectedImages;
      });
    }
  }



  void _deleteImage(int index) {
    setState(() {
      _imageFiles!.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {






    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          _sendAppointmentRequest();

        },
        child: Icon(Icons.send),
      ),
      appBar: AppBar(
        title: Text('Request Appointment'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: cityController,

                    decoration: InputDecoration(labelText: 'City'),
                  ),
                ),
                SizedBox(width: 12.0),
                Expanded(
                  child: TextField(
                    controller: stateController,
                    decoration: InputDecoration(labelText: 'State'),
                  ),
                ),
                SizedBox(width: 12.0),
                Expanded(
                  child: TextField(
                    controller: blockController,
                    decoration: InputDecoration(labelText: 'Block'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.0),

            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            SizedBox(height: 12.0),

            SizedBox(height: 12.0),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),

            SizedBox(height: 20.0),
            IntlPhoneField(
              controller: phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderSide: BorderSide(),
                ),
              ),
              initialCountryCode: 'LB',
              onChanged: (phone) {
                print(phone.completeNumber);
              },
            ),
            Text(
              "You can also send  pictures to convey the idea to the worker clearly ! ",
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey),
            ),
            SizedBox(
              height: 12,
            ),

            if (_imageFiles != null && _imageFiles!.isNotEmpty)
              Container(
                height: 200,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imageFiles!.length,
                    itemBuilder: (context, index) {
                      return Stack(children: [
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
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () => _deleteImage(index),
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ]);
                    }),
              ),
            Center(
              child: IconButton(
                onPressed: _selectImages,
                icon: Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 52,
                ),
                // child: Text('Select Images'),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
