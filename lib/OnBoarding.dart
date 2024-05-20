import 'home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:flutter/cupertino.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  @override
  Widget build(BuildContext context) {
    final _introKey = GlobalKey<IntroductionScreenState>();
    String _status = 'Waiting...';
    return IntroductionScreen(
      resizeToAvoidBottomInset: true,
      allowImplicitScrolling: true,
      dotsDecorator: DotsDecorator(
        color: Colors.grey,
        activeColor: Colors.blue,
        // shapes:
      ),
      globalBackgroundColor: Colors.white,

      pages: [

        PageViewModel(
          decoration: PageDecoration(
            imagePadding: EdgeInsets.only(top: 10),
            imageFlex: 3,
            bodyFlex: 1,
            bodyAlignment: Alignment.bottomCenter
          ),
            title: "Why Fixpert ?",
            image: Image.asset('assets/logo.png',height: 240,),
        body: "WRITE WHY!!!"

        ),
        PageViewModel(
          decoration: PageDecoration(
            imagePadding: EdgeInsets.only(top: 10),
            imageFlex: 3,
            bodyFlex: 1,
            bodyAlignment: Alignment.bottomCenter
          ),

          image:Center(

        child:Image.asset('assets/workers.png'),
        ) ,
          title: "As a worker",
          body: 'Fixpert provides you with professional features to develop your work and helps you exposure your services'
        ),

        PageViewModel(
            decoration: PageDecoration(
              imageFlex: 3,
                bodyFlex: 1,
                imagePadding: EdgeInsets.only(top: 10),
                bodyAlignment: Alignment.bottomCenter
            ),

            image:Center(

              child:Image.asset('assets/superman.png'),
            ) ,
            title: "As a Client",
            body: 'Fixpert secure your needs as a client and helps you find the right worker with the best experience'
        )
      ],
      skip:Text('skip'),
      back: Icon(Icons.arrow_back_ios),
      next: Icon(Icons.arrow_forward_ios),
      done: Icon(Icons.done),
      onDone: () async {
            SharedPreferences sp = await SharedPreferences.getInstance();
            sp.setBool('LandingFlag', true);
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>Home() ,));
      },

      showSkipButton: false,
      showBackButton: true,
      showNextButton:true,
      showDoneButton: true,
    );
  }
}
