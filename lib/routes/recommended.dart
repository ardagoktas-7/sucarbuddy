import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projedeneme/routes/chat.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projedeneme/routes/timeline.dart';
import 'package:projedeneme/widgets/progress.dart';

import 'activity_feed.dart';

class Recommended extends StatefulWidget {
  @override
  _TopicRecommendedState createState() => _TopicRecommendedState();
}

class _TopicRecommendedState extends State<Recommended> {

  var currentUser = FirebaseAuth.instance.currentUser!.uid;


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .where('id', isNotEqualTo: currentUser,whereIn: recfollowers)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Something went wrong"),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return circularProgress();
          }

          if (snapshot.hasData) {
            return CustomScrollView(
              slivers: [
                CupertinoSliverNavigationBar(
                  largeTitle: Text("Recommended People"),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    snapshot.data!.docs.map(
                          (DocumentSnapshot document) {
                        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                        return ListTile(
                          onTap: () => showProfile(context, profileId: data['id']),
                          title: Text(data['name']),
                          subtitle: Text(data['username']),
                        );
                      },
                    ).toList(),
                  ),
                )

              ],
            );
          }
          return Container();
        });
  }

}
