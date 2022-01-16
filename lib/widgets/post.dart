import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:projedeneme/model/user.dart';
import 'package:projedeneme/routes/Feedview.dart';
import 'package:projedeneme/routes/activity_feed.dart';
import 'package:projedeneme/routes/comments.dart';
import 'package:projedeneme/routes/timeline.dart' as deneme;
import 'package:projedeneme/widgets/progress.dart';

import 'custom_image.dart';

User? user;
class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final dynamic likes;

  Post({
    required this.postId,
    required this.ownerId,
    required this.username,
    required this.location,
    required this.description,
    required this.likes,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      likes: doc['likes'],
    );
  }

  int getLikeCount(likes) {
    // if no likes, return 0
    if (likes == null) {
      return 0;
    }
    int count = 0;
    // if the key is explicitly set to true, add a like
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
    postId: this.postId,
    ownerId: this.ownerId,
    username: this.username,
    location: this.location,
    description: this.description,
    likes: this.likes,
    likeCount: getLikeCount(this.likes),
  );
}

class _PostState extends State<Post> {
  auth.User? firebaseUser = auth.FirebaseAuth.instance.currentUser;

  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  int likeCount;
  Map likes;
  bool isLiked = false;
  String? currentUserId = "";
  String? urlcontroller = "";
  String? idcontroller = "";
  String? usernamecontroller = "";

  @override
  void initState() {
    super.initState();
    getUser();
  }


  getUser() async {
    DocumentSnapshot doc = await usersRef.doc(firebaseUser?.uid).get();
    user = User.fromDocument(doc);
    currentUserId = user?.id;
    usernamecontroller = user?.username;
    urlcontroller = user?.photoUrl;
  }


  _PostState({
    this.currentUserId,
    required this.postId,
    required this.ownerId,
    required this.username,
    required this.location,
    required this.description,
    required this.likes,
    required this.likeCount,
  });

  handleDelete() async {
    getUser();
    bool isPostOwner = currentUserId == ownerId;

    if (isPostOwner) {
      await postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .delete();
      print('deleted post');
    }
    else
      {
        print("not your post");
      }

  }

  buildPostHeader() {
    return FutureBuilder(
      future: usersRef.doc(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data as DocumentSnapshot<Object?>);
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: Text(
              user.username,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(location),
          trailing: IconButton(
            onPressed: () => handleDelete(),
            icon: Icon(Icons.delete),
          ),
        );
      },
    );
  }
  handleLikePost() {
    getUser();
    bool _isLiked = likes[currentUserId] == true;

    if (_isLiked) {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': false});
      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': true});
      addLikeToActivityFeed();
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
      });
    }
  }

  addLikeToActivityFeed() {
    getUser();
    // add a notification to the postOwner's activity feed only if comment made by OTHER user (to avoid getting notification for our own like)
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .doc(ownerId)
          .collection("feedItems")
          .doc(postId)
          .set({
        "type": "like",
        "commentData":"-",
        "username": usernamecontroller,
        "userId": currentUserId,
        "userProfileImg": urlcontroller,
        "postId": postId,
        "timestamp": timestamp,
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .doc(ownerId)
          .collection("feedItems")
          .doc(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  reShare(
      {required String location, required String description,required String postId, required String ownerId, required String username}) {
    postsRef
        .doc(currentUserId)
        .collection("userPosts")
        .doc(postId)
        .set({
      "postId": postId,
      "ownerId": currentUserId,
      "username": username,
      "mediaUrl": "",
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "likes": {},
    });
  }

  report(String? currentUserId)
  {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Post Reported"),
          );
        });

  }


  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              onTap: handleLikePost,
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28.0,
                color: Colors.pink,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 20.0)),
            GestureDetector(
              onTap: () => showComments(
                context,
                postId: postId,
                ownerId: ownerId,
              ),
              child: Icon(
                Icons.chat,
                size: 28.0,
                color: Colors.blue[900],
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 20.0)),
            GestureDetector(
              onTap: () => reShare(
                location: location,
                description: description,
                postId: postId,
                ownerId: ownerId,
                username: username,
              ),
              child: Icon(
                Icons.share,
                size: 28.0,
                color: Colors.blue[900],
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 210.0)),
            GestureDetector(
              onTap: () => report(currentUserId),
              child: Icon(
                Icons.report,
                size: 28.0,
                color: Colors.red[900],
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$likeCount likes",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$username ",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(child: Text(description))
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    getUser();
    isLiked = (likes[currentUserId] == true);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostFooter()
      ],
    );
  }
}

showComments(BuildContext context,
    {required String postId, required String ownerId}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId,
      postOwnerId: ownerId,
    );
  }));
}