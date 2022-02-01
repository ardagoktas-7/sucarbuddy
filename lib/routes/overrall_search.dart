import 'package:flutter/material.dart';
import 'package:projedeneme/routes/recommended.dart';
import 'package:projedeneme/routes/search.dart';
import 'package:projedeneme/routes/topic_search.dart';
import 'package:projedeneme/widgets/header.dart';




class overall_search extends StatefulWidget {
  @override
  _overall_searchState createState() => _overall_searchState();
}

class _overall_searchState extends State<overall_search> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: header(context, titleText: "Search"),
      body: Container(
        padding: EdgeInsets.only(left: 16, top: 25, right: 16),
        child: ListView(
          children: [
           Row(
            children: [
              Icon(
                Icons.person,
                color: Colors.green,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                "Select type of Search",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Divider(
            height: 15,
            thickness: 2,
          ),
          SizedBox(
            height: 10,
          ),
            buildEmailOptionRow(context, "Email Search"),
            buildContentOptionRow(context, "Content Search"),
            buildTopicOptionRow(context, "Topic Search"),
      ],
        ),
      ),
    );
  }

  GestureDetector buildEmailOptionRow(BuildContext context, String title) {
    return GestureDetector(
      onTap: () async {
        print("changepass clicked");
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Search(),
            ));
        //ChangePass(analytics: widget.analytics, observer: widget.observer);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
  GestureDetector buildContentOptionRow(BuildContext context, String title) {
    return GestureDetector(
      onTap: () async {
        print("changepass clicked");
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Search(),
            ));
        //ChangePass(analytics: widget.analytics, observer: widget.observer);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
  GestureDetector buildTopicOptionRow(BuildContext context, String title) {
    return GestureDetector(
      onTap: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TopicSearch(),
            ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

}