import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projedeneme/utils/styles.dart';
import 'package:projedeneme/utils/colors.dart';
import 'package:projedeneme/utils/dimension.dart';
import 'package:provider/provider.dart';
import 'package:projedeneme/routes/feedView.dart';
import 'package:projedeneme/services/auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:projedeneme/services/analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:projedeneme/model/user.dart' as deneme;

final GoogleSignIn googleSignIn = GoogleSignIn();
deneme.User? currentUser;





class Welcome extends StatefulWidget {
  const Welcome({Key, key, required this.analytics, required this.observer}) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;


  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  AuthService auth = AuthService();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    if(user == null) {
      return Scaffold(
        body: SafeArea(
          maintainBottomViewPadding: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20,),
              Center(
                child: Padding(
                  padding: Dimen.regularPadding,
                  child: RichText(
                    text: TextSpan(
                      text: "Welcome to ",
                      style: kCountLabel,
                      children: <TextSpan>[
                        TextSpan(
                          text: "SuBuddyCar",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15,),
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Image.network(
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ0QEQ1LwTlS1XjTqiTszS7onqfH6qNvbnw4w&usqp=CAU'),
              ),
              SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 16.0),

                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () {
                          setCurrentScreen(widget.analytics, 'Signup', 'signup.dart');

                          //FirebaseCrashlytics.instance.crash();
                          FirebaseCrashlytics.instance.log("Team 8 detected! Bailing out");
                          Navigator.pushNamed(context, '/signup');
                          throw Error();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(
                            'Signup',
                            style: kCountLabel,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                        ),
                      ),
                    ),

                    SizedBox(width: 8.0,),

                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () {
                          setCurrentScreen(widget.analytics, 'Login', 'login.dart');

                          Navigator.pushNamed(context, '/login');
                          FirebaseCrashlytics.instance.log("Higgs-Boson detected! Bailing out");
                          throw Error();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(
                            'Login',
                            style: kCountLabel,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15,),
              Text(
                'Sign up with',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 15,),
              ElevatedButton(onPressed: buttonPressed, child: Text('Facebook')
              ),
              SizedBox(height: 15,),
              ElevatedButton.icon(onPressed: () {
                auth.signInWithGoogle();

                setCurrentScreen(widget.analytics, 'Google Login', 'Feedview.dart');


              }
                  , icon: Icon(Icons.mail), label: Text('Gmail')
              ),
            ],
          ),
        ),
        backgroundColor: Colors.grey[600],

      );
    }
    else {
      return FeedView();
    }
  }
  void buttonPressed() {
    print('Button tapped');
  }
}