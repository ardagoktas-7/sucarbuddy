import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projedeneme/routes/profile.dart';
import 'package:projedeneme/routes/search.dart';
import 'package:projedeneme/routes/upload.dart';
import 'package:projedeneme/routes/chatrooms.dart';
import 'package:projedeneme/routes/timeline.dart';
import 'package:projedeneme/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:provider/provider.dart';
import 'activity_feed.dart';
import 'package:projedeneme/model/user.dart' as deneme;

final firebase_storage.Reference storageRef = firebase_storage.FirebaseStorage.instance.ref();
final usersRef = FirebaseFirestore.instance.collection('users');
final commentsRef = FirebaseFirestore.instance.collection('comments');
final activityFeedRef = FirebaseFirestore.instance.collection('feed');
final followersRef = FirebaseFirestore.instance.collection('followers');
final followingRef = FirebaseFirestore.instance.collection('following');
final DateTime timestamp = DateTime.now();
final postsRef = FirebaseFirestore.instance.collection('posts');
deneme.User? currentuser;

class FeedView extends StatefulWidget {
  @override
  _FeedViewState createState() => _FeedViewState();
}


class _FeedViewState extends State<FeedView>  {

  AuthService auth = AuthService();
  bool isAuth = false;
  final PageController pageController = PageController();
  int pageIndex = 0;
  int count = 0;



  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }


  void buttonClicked() {
    setState(() {
      count++;
    });
    print('Button Clicked');
  }
  logout() {
    auth.signOutFromGoogle();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print('initState');
  }

  @override
  Widget build(BuildContext context) {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Timeline(currentUserId: firebaseUser?.uid),
          ActivityFeed(),
          Upload(currentUserId: firebaseUser?.uid),
          People(),
          Search(),
          Profile(profileId: firebaseUser?.uid),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
          currentIndex: pageIndex,
          onTap: onTap,
          activeColor: Theme.of(context).primaryColor,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.photo_camera,
                size: 35.0,
              ),
            ),
            BottomNavigationBarItem(icon: Icon(Icons.comment)),
            BottomNavigationBarItem(icon: Icon(Icons.search)),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
          ]),
    );

  }
}
