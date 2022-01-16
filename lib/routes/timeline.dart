import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projedeneme/model/user.dart';
import 'package:projedeneme/routes/Feedview.dart';
import 'package:projedeneme/routes/search.dart';
import 'package:projedeneme/widgets/header.dart';
import 'package:projedeneme/widgets/post.dart';
import 'package:projedeneme/widgets/progress.dart';

final usersRef = FirebaseFirestore.instance.collection('users');

List followers =["1234"];

class Timeline extends StatefulWidget {
  final String? currentUserId;

  Timeline({required this.currentUserId});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts = [];

  getTimeline() async {
    List followingList =[];
    QuerySnapshot snapshot = await followingRef
        .doc(widget.currentUserId)
        .collection('userFollowing')
        .get();

    followingList = snapshot.docs.map((doc) => doc.id).toList();
    followers = followingList;
    followers.add(widget.currentUserId);

    List<Post> posts2 = [];
    for( int i=0; i< followingList.length; i++)
    {
      QuerySnapshot snapshot = await postsRef
          .doc(followingList[i])
          .collection('userPosts')
          .orderBy('timestamp', descending: true)
          .get();

      snapshot.docs.forEach((doc) {
        posts2.add(Post.fromDocument(doc));

        // print('Activity Feed Item: ${doc.data}');
      });
    }
    return posts2;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white24,
      appBar: header(context, titleText: "Activity Feed"),
      body: Container(
          child: FutureBuilder(
            future: getTimeline(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              }
              return ListView(
                children: snapshot.data as List<Widget>,
              );
            },
          )
      ),
    );
  }
}
