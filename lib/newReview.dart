import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:animated_rating_stars/animated_rating_stars.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WriteReviewPage extends StatefulWidget {
  final int? worker_id;
  const WriteReviewPage({Key? key, this.worker_id}) : super(key: key);

  @override
  State<WriteReviewPage> createState() => _WriteReviewPageState();
}



class _WriteReviewPageState extends State<WriteReviewPage> {
  String? username;
  String? userPicUri;
  double? rate;
  String? customer_id;
  String baseUrl='https://switch.unotelecom.com/fixpert/newReview';
  TextEditingController descriptionController = TextEditingController();

  Future<void> addNewReview( double rate) async{

    String url = "$baseUrl?rate=$rate&comment=${descriptionController.text}&commenter_id=$customer_id&worker_id=${widget.worker_id}";
    print("adding new comment with $url");
    final request = await http.get(Uri.parse(url));
    if(request.statusCode == 200){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Comment added sucessfully"),backgroundColor: Colors.green,));
      Navigator.of(context).pop();
    }
  }
  Future<void> fetchWriterInfo() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {

      username = sp.getString('username');
      userPicUri= sp.getString('profile_pic');
      customer_id = sp.getString('user_id') ;
    });
  }
  @override
  void initState(){
    super.initState();
    fetchWriterInfo();

  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;
    return

          Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: [
                TextButton(onPressed: () {

                    addNewReview( rate!);
                }, child: Text('Add comment',style: TextStyle(fontSize: 13,color: Colors.blueAccent,fontWeight: FontWeight.w500),))
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                    //
                    // Image.network("https://switch.unotelecom.com/fixpert/assets/$userPicUri",width:screenWidth / 4 ,),
                    // Text(username ?? 'username' ),


                Padding(
                  padding: EdgeInsets.only(left: 10),
                   child:
                   Row(

                    children: [
                      userPicUri != null
                          ? Image.network(
                          width: screenWidth / 4,
                          "https://switch.unotelecom.com/fixpert/assets/${userPicUri??"defaultprofile.png"}")
                          : Container(),
                      SizedBox(width: 10),
                      Column(
                        // mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username ?? 'username',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Note That Your Name Will Be Public For All',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                AnimatedRatingStars(
                  interactiveTooltips: true,
                  halfFilledIcon: Icons.star_half,
                  initialRating: 0.5,
                  emptyIcon: Icons.star_border,
                  maxRating: 5.0,
                  displayRatingValue: true,
                  starSize: screenWidth / 7,
                  animationDuration: Duration(microseconds: 300),
                  readOnly: false,
                  onChanged: (value) {
                    setState(() {
                      rate = value;
                    });
                  },
                  customFilledIcon: Icons.star,
                  customHalfFilledIcon: Icons.star_half,
                  customEmptyIcon: Icons.star_border,
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: "Describe Your Own Experience With This Worker",
                    ),
                  ),
                ),

              ],
            ),
          );


  }}