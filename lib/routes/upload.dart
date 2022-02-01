import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projedeneme/model/user.dart';
import 'package:projedeneme/routes/Feedview.dart';
import 'package:projedeneme/widgets/progress.dart';

import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';


import 'package:uuid/uuid.dart';
User? user;

class Upload extends StatefulWidget {
  final String? currentUserId;

  Upload({required this.currentUserId});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload>
    with AutomaticKeepAliveClientMixin<Upload> {
  TextEditingController captionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController topicController = TextEditingController();
  bool isUploading = false;
  bool done = false;
  String postId = Uuid().v4();
  var latitude = 'Getting Latitude..';
  var longitude = 'Getting Longitude..';
  var address = 'Getting Address..';
  late StreamSubscription<Position> streamSubscription;

  @override
  void initState() {
    super.initState();
    getUser();
  }


  getUser() async {
    DocumentSnapshot doc = await usersRef.doc(widget.currentUserId).get();
    user = User.fromDocument(doc);
  }



  createPostInFirestore(
      {required String? mediaUrl,required String? topic, required String location, required String description}) {
    postsRef
        .doc(user?.id)
        .collection("userPosts")
        .doc(postId)
        .set({
      "postId": postId,
      "ownerId": user?.id,
      "username": user?.username,
      "mediaUrl": mediaUrl,
      "topic": topic,
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "likes": {},
    });
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    createPostInFirestore(
      mediaUrl: user?.photoUrl,
      topic: topicController.text,
      location: locationController.text,
      description: captionController.text,
    );
    topicController.clear();
    captionController.clear();
    locationController.clear();
    setState(() {
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          "Caption Post",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: isUploading ? null : () => handleSubmit(),
            child: Text(
              "Post",
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(""),
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
              CachedNetworkImageProvider(user!.photoUrl),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: topicController,
                decoration: InputDecoration(
                  hintText: "Write your current location or just click it",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                  hintText: "Please write a begining point and ending point.",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
              CachedNetworkImageProvider(user!.photoUrl),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: "Write description.",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
            Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
            label: Text(
            "Use Current Location",
            style: TextStyle(color: Colors.white),
            ),
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
            ),
            color: Colors.blue,
            onPressed: getLocation,
            icon: Icon(
            Icons.my_location,
            color: Colors.white,
            ),
            ),
            ),
          ],
           ),
    );
  }


  getLocation() async {
    bool serviceEnabled;

    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    streamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
          latitude = 'Latitude : ${position.latitude}';
          longitude = 'Longitude : ${position.longitude}';
          getAddressFromLatLang(position);
        });
  }

  Future<void> getAddressFromLatLang(Position position) async {
    List<Placemark> placemark =
    await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemark[0];
    address = 'Address : ${place.locality},${place.country}';
    String formattedAddress = "${place.locality}, ${place.country}";
    topicController.text = formattedAddress;
  }


  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return buildUploadForm();
  }
}

