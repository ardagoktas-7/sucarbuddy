import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:projedeneme/routes/Feedview.dart';
import 'package:projedeneme/widgets/header.dart';
import 'package:projedeneme/widgets/post.dart';
import 'package:projedeneme/widgets/progress.dart';

import 'activity_feed.dart';

class TopicSearch extends StatefulWidget {
  @override
  _TopicSearchState createState() => _TopicSearchState();
}

class _TopicSearchState extends State<TopicSearch> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot>? searchResultsFuture;

  handleSearch(String query)  {
    Future<QuerySnapshot> post = postsRef
        .doc()
        .collection('userPosts')
        .get();
    setState(() {
      searchResultsFuture = post;
    });
  }

  getTimeline() async {
    List<Post> posts2 = [];

    QuerySnapshot snapshot = await postsRef
        .doc()
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();

    snapshot.docs.forEach((doc) {
      posts2.add(Post.fromDocument(doc));
      // print('Activity Feed Item: ${doc.data}');
    });

    return posts2;
  }


  clearSearch() {
      searchController.clear();
    }

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white54,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search for a topic...",
          filled: true,
          prefixIcon: Icon(
            Icons.account_box,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  Container buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/search.svg',
              height: orientation == Orientation.portrait ? 300.0 : 200.0,
            ),
            Text(
              "Find Topic included post",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 60.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        print(snapshot.data?.size);
        List<PostResult> searchResults = [];
        snapshot.data!.docs.forEach((doc) {
          Post post = Post.fromDocument(doc);
          PostResult searchresults = PostResult(post);
          searchResults.add(searchresults);
        });
        print(searchResults.length);
        return ListView(
          children: searchResults,
        );
      },
    );
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

  /*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      appBar: buildSearchField(),
      body:
      searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }

   */
}

class PostResult extends StatelessWidget {
  late final Post post;

  PostResult(this.post);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: post.ownerId),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(post.username),
              ),
              title: Text(
                post.topic,
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                post.description,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }

}