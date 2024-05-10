import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'home.dart';
import 'package:shared_preferences/shared_preferences.dart';


class EditCustomerProfile extends StatefulWidget {
  const EditCustomerProfile({super.key});

  @override
  State<EditCustomerProfile> createState() => _EditCustomerProfileState();
}

class _EditCustomerProfileState extends State<EditCustomerProfile> {


  TextEditingController usernameController=TextEditingController();
  TextEditingController addressController=TextEditingController();
  String user_id="";
  String username="";
  String address='';
  Future<void> _getImage(String userId) async {
    final picker = ImagePicker();
  print('i clicked on picker');
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      print('i clicked on picke22222222222222r');
      // Upload the picked image to the server
      _uploadImage(File(pickedFile.path),userId=user_id);
    }
  }
  Future<void> _uploadImage(File imageFile,String userId) async {
    SharedPreferences sp=await SharedPreferences.getInstance();
    user_id=sp.getString('user_id')!;

    var request = http.MultipartRequest('POST', Uri.parse("https://switch.unotelecom.com/fixpert/updateCustomerPic.php?user_Id=$user_id"));
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        // Image uploaded successfully
        print('Image uploaded successfully');
        print(user_id);
      } else {
        // Handle error
        print('Error uploading image: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Handle error
      print('Error uploading image: $e');
    }
  }
  // This func will hhelp us to rebuild the customerProfile page
  void _navigateBackAndRefresh(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => EditCustomerProfile(),
      ),
    );
  }
  Future<void> updateChanges(String newUsername, String newAddress) async {
    String url = 'https://switch.unotelecom.com/fixpert/updateCustomerInfo.php';
    SharedPreferences sp = await SharedPreferences.getInstance();

    if (newAddress.isNotEmpty) {
      url += "?new_address=$newAddress&user_id=$user_id";
    } else {
      url += "?user_id=$user_id";
    }
    if (newUsername.isNotEmpty) {
      url += "&new_username=$newUsername";
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(jsonDecode(response.body)['message'])));
      sp.setString('address', newAddress);
      sp.setString('username', newUsername);
      print("the new username is $newUsername");
      Map<String,dynamic> result=jsonDecode(response.body);
      print(result['message']);
      print(url);
      _fetchInitialValues();
      print(address);
    }
  }
  @override
  void initState() {
    super.initState();
    // Fetch initial values from wherever you want, such as SharedPreferences
    _fetchInitialValues();
  }
  Future<void> _fetchInitialValues() async {


    SharedPreferences sp= await SharedPreferences.getInstance();
    setState(() {
      // Set the initial values to the TextEditingController
        print('the username is ${sp.getString('username')}');
      usernameController.text = sp.getString('username')!;
      user_id=sp.getString('user_id')!;
      address=sp.getString('address')!;
      username=sp.getString('username')!;
      addressController.text = sp.getString("address")!;
    });
  }
  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Map<String, dynamic>? args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    // Access the 'uri' key from the args Map, or set it to an empty string if args is null or 'uri' is not found
    String src = args?['uri'] ?? "";
    //  username=args?['username'] ?? "" ;
    // String userId=args?['user_id'] ?? "";





    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Edit Profile',style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 21
          ),),
          actions: [
            TextButton(onPressed: () {
              updateChanges(usernameController.text.trim(), addressController.text.trim());

              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>Home() ,));
            }, child: Text(
              'Done',style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w400,color: Colors.black54
            ),
            ))
          ],

          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();

            },
          ),

        ),
        body: Column(
          children: <Widget> [
            GestureDetector(
              child:
              Image.network(src,width: screenWidth/4,),
              onTap: () => _getImage(user_id),
            ),
            SizedBox(height: 15,),

            // This field is to change the usernaem
            Padding(padding: EdgeInsets.only(left: 10,right: 10),child: TextField(
              controller: usernameController,

              decoration: InputDecoration(
                labelText: "Username",
              ),),

            ),

            SizedBox(height: 10,),

            // This field is to change the address
            Padding(padding: EdgeInsets.only(left: 10,right: 10),child:TextField(
              controller: addressController,
              decoration: InputDecoration(

                  labelText: 'Address',

              ),
            ) ,),

          ],
        ),
      ),
    );
  }
}
