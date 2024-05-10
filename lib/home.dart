import 'package:flutter/material.dart';
import 'login.dart';
import 'ChooseTheAccountType.dart';
import 'signup.dart';
import 'getServices.dart';
import 'customerProfile.dart';
import 'profile.dart';
import 'homePage.dart';
import 'search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'workerProfile.dart';
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  bool isLoggedIn = false;
  String acc_type='';
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print(_selectedIndex);
    });
  }

  Future<void> loadData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = sp.getBool('loggedIn') ?? false;
      print('hellomister');
      acc_type=sp.getString('acc_type')!;
      print("Account type is $acc_type");
      print(isLoggedIn);
    });
  }

  @override
  void initState() {
    // super.initState();
    loadData();
    print(isLoggedIn);
  }

  // void updateLoggedInStatus(bool status) {
  //   setState(() {
  //     isLoggedIn = status;
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    // the list to disply the selected widget
    List<Widget> _widgetOptions = [
      // first item
      HomePage(),
      // second item
      SearchPage(),
      // third item
      isLoggedIn? Text('Chat Page',style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)): LoginOrSignup(),
      // fourth item
      isLoggedIn ? (acc_type=='customer'? CustomerProfile() : WorkerProfile()) : LoginOrSignup(),
    ];

    return Scaffold(
        body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
        bottomNavigationBar: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Image.asset('assets/home.png', height: 24, width: 24),
                  label: ('Home'),
                  tooltip: ('Home'),
                  // backgroundColor: Color(0xFFE2E2E2)
                ),
                BottomNavigationBarItem(
                  icon: Image.asset('assets/search.png', height: 24, width: 24),
                  label: ('Search'),
                  tooltip: ('Search'),
                  backgroundColor: Colors.white,
                ),
                BottomNavigationBarItem(
                  icon: Image.asset('assets/chat.png', width: 24, height: 24),
                  label: ('Chat'),
                  tooltip: ('Chat'),
                  backgroundColor: Colors.white,
                ),
                BottomNavigationBarItem(
                  icon:
                      Image.asset('assets/profile.png', width: 24, height: 24),
                  label: ('Profile'),
                  tooltip: ('Profile'),
                  backgroundColor: Colors.white,
                ),
              ],
              type: BottomNavigationBarType.shifting,
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.black,
              iconSize: 24,
              elevation: 5,
              onTap: _onItemTapped,
            )));
  }
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// This function is to tell the user that he is not logged in so he can login || signup to reach the chat widget or profile//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class LoginOrSignup extends StatelessWidget {
  const LoginOrSignup({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Sorry!",
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "You're Not Logged In",
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Login()));
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(color: Colors.blue, fontSize: 24),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "or,",
                    style: TextStyle(fontSize: 24),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ChooseAcountType()));
                    },
                    child: Text(
                      ' Signup',
                      style: TextStyle(color: Colors.blue, fontSize: 24),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // End of LoginOrSignup Function
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

}
