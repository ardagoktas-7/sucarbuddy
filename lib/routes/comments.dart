import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as deneme;
import 'package:flutter/material.dart';
import 'package:projedeneme/routes/Feedview.dart';
import 'package:projedeneme/services/auth.dart';
import 'package:projedeneme/widgets/header.dart';
import 'package:projedeneme/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:projedeneme/model/user.dart';

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;

  Comments({
    required this.postId,
    required this.postOwnerId,
  });

  @override
  CommentsState createState() => CommentsState(
    postId: this.postId,
    postOwnerId: this.postOwnerId,
  );
}

class CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  final String postId;
  final String postOwnerId;
  String urlcontroller = "";
  String idcontroller = "";
  String usernamecontroller = "";
  AuthService auth = AuthService();
  late User user;
  deneme.User? firebaseUser = deneme.FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    DocumentSnapshot doc = await usersRef.doc(firebaseUser?.uid).get();
    user = User.fromDocument(doc);
    usernamecontroller = user.username;
    idcontroller = user.id;
    urlcontroller = user.photoUrl;
  }

  CommentsState({
    required this.postId,
    required this.postOwnerId,
  });

  buildComments() {
    return StreamBuilder(
        stream: commentsRef
            .doc(postId)
            .collection('comments')
            .orderBy("timestamp", descending: false)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<Comment> comments = [];
          snapshot.data!.docs.forEach((doc) {
            comments.add(Comment.fromDocument(doc));
          });
          return ListView(
            children: comments,
          );
        });
  }

  addComment() {
    getUser();
    commentsRef.doc(postId).collection("comments").add({
      "username": usernamecontroller,
      "comment": commentController.text,
      "timestamp": timestamp,
      "avatarUrl": urlcontroller,
      "userId": idcontroller,
    });
    bool isNotPostOwner = postOwnerId != idcontroller;
    if (isNotPostOwner) {
      activityFeedRef.doc(postOwnerId).collection('feedItems').add({
        "type": "comment",
        "commentData": commentController.text,
        "timestamp": timestamp,
        "postId": postId,
        "userId": idcontroller,
        "username": usernamecontroller,
        "userProfileImg": urlcontroller,
      });
    }
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Comments"),
      body: Column(
        children: <Widget>[
          Expanded(child: buildComments()),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: InputDecoration(labelText: "Write a comment..."),
            ),
            trailing: OutlinedButton(
              onPressed: addComment,
              child: Text("Post"),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;

  Comment({
    required this.username,
    required this.userId,
    required this.avatarUrl,
    required this.comment,
    required this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
      avatarUrl: doc['avatarUrl'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(comment),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          subtitle: Text(timeago.format(timestamp.toDate())),
        ),
        Divider(),
      ],
    );
  }
}
