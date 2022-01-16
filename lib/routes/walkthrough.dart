import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:projedeneme/routes/welcome.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';


class WalkThrough extends StatefulWidget {
  @override
  _WalkThroughState createState() => _WalkThroughState();
}

class _WalkThroughState extends State<WalkThrough> {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);
  @override
  Widget build(BuildContext context) => SafeArea(
    child: IntroductionScreen(
      pages: [
        PageViewModel(
          title: 'No more missing the shuttle',
          body: 'Thanks to SuBuddyCar.',
          image: buildImage('assets/resim1.jpg'),
          decoration: getPageDecoration(),
        ),
        PageViewModel(
          title: 'Just with one click',
          body: 'You are wherever you want whenever you want.',
          image: buildImage('assets/resim2.jpg'),
          decoration: getPageDecoration(),
        ),
        PageViewModel(
          title: 'No worries on the road alone',
          body: 'Because now you have a buddy',
          image: buildImage('assets/resim3.jpg'),
          decoration: getPageDecoration(),
        ),
        PageViewModel(
          title: 'New journeys bring new adventures',
          body: 'Are you ready to start your journey?',
          image: buildImage('assets/resim4.jpg'),
          decoration: getPageDecoration(),
        ),
      ],
      done: Text('Read', style: TextStyle(fontWeight: FontWeight.w600)),
      onDone: () => goToHome(context),
      showSkipButton: true,
      skip: Text('Skip'),
      next: Icon(Icons.arrow_forward),

      dotsDecorator: getDotDecoration(),
      onChange: (index) => print('Page $index selected'),
      globalBackgroundColor: Colors.white,
      skipFlex: 0,
      nextFlex: 0,
      // isProgressTap: false,
      // isProgress: false,
      // showNextButton: false,
      // freeze: true,
      animationDuration: 500,
    ),
  );

  void goToHome(context) => Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (_) => Welcome(analytics: analytics, observer: observer)),
  );

  Widget buildImage(String path) =>
      Center(child: Image.asset(path, width: 350));

  DotsDecorator getDotDecoration() => DotsDecorator(
    color: Colors.grey,
    activeColor: Colors.blue,
    size: Size(10, 10),
    activeSize: Size(22, 10),
  );



  PageDecoration getPageDecoration() => PageDecoration(
    titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    bodyTextStyle: TextStyle(fontSize: 20),
    descriptionPadding: EdgeInsets.all(16).copyWith(bottom: 0),
    imagePadding: EdgeInsets.all(24),
    pageColor: Colors.white,
  );

}