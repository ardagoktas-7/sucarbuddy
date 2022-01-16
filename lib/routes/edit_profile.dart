import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:projedeneme/model/user.dart';
import 'package:projedeneme/routes/Feedview.dart';
import 'package:projedeneme/services/db.dart';

import 'dart:io';
import 'package:projedeneme/widgets/progress.dart';
import 'package:projedeneme/services/auth.dart';
import 'package:projedeneme/services/users.dart';
import 'package:image_picker/image_picker.dart';

import 'changepass.dart';

final usersRef2 = FirebaseFirestore.instance.collection('users');

class EditProfile extends StatefulWidget {
  final String? currentUserId;

  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  DBService db = DBService();
  bool ispriv =false;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  UserService _userService = UserService();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  late User user;
  File? _profileImage;
  File? _bannerImage;
  final picker = ImagePicker();
  String name = '';
  bool _displayNameValid = true;
  bool _bioValid = true;
  AuthService auth = AuthService();

  @override
  void initState() {
    super.initState();
    getUser();
  }

  Future getImage(int type) async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null && type == 0) {
        _profileImage = File(pickedFile.path);
      }
      if (pickedFile != null && type == 1) {
        _bannerImage = File(pickedFile.path);
      }
    });
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.doc(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayNameController.text = user.name;
    bioController.text = user.bio;
    isLoading = false;
    setState(() {
      isLoading = false;
    });
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Display Name",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: "Update Display Name",
            errorText: _displayNameValid ? null : "Display Name too short",
          ),
        )
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Bio",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            hintText: "Update Bio",
            errorText: _bioValid ? null : "Bio too long",
          ),
        )
      ],
    );
  }

  updateProfileData() async {
    setState(() {
      displayNameController.text
          .trim()
          .length < 3 ||
          displayNameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
      bioController.text
          .trim()
          .length > 100
          ? _bioValid = false
          : _bioValid = true;
    });

    if (_displayNameValid && _bioValid) {
      usersRef.doc(widget.currentUserId).update({
        "name": displayNameController.text,
        "bio": bioController.text,
      });
      SnackBar snackbar = SnackBar(content: Text("Profile updated!"));
      _scaffoldKey.currentState!.showSnackBar(snackbar);
    }
  }

  logout() {
    auth.signOutFromGoogle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              await _userService.updateProfile(
                  _profileImage!);
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.done,
              size: 30.0,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: new Form(
            child: Column(
              children: [
                FlatButton(
                  onPressed: () => getImage(0),
                  child: _profileImage == null
                      ? Icon(Icons.person)
                      : Image.file(
                    _profileImage!,
                    height: 100,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      buildDisplayNameField(),
                      buildBioField(),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: updateProfileData,
                  child: Text(
                    "Update Profile",
                    style: TextStyle(
                      color: Theme.of(context).shadowColor,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                      ),
                      child: OutlinedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Which action do you want to perform?"),
                                actions: [
                                  TextButton(
                                    child: Text("Delete Account", style: GoogleFonts.nunito(
                                        color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),),
                                    onPressed: () async {
                                      print("userclass userId: " + widget.currentUserId!);
                                      await db.deleteUser(widget.currentUserId!);
                                      await auth.deleteUser();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Center(
                          child: Text(
                            "Delete Account",
                            style: GoogleFonts.nunito(
                                color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                TextButton(
                  onPressed: () async {
                    print("changepass clicked");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangePass(),
                        ));
                    //ChangePass(analytics: widget.analytics, observer: widget.observer);
                  },
                  child: Center(
                    child: Text(
                      'Change Password',
                      style:
                      TextStyle(color: Colors.blueAccent, fontSize: 20),
                    ),
                  ),),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                    ),
                    child: OutlinedButton(
                      onPressed: () async {
                        db.makeAccountPrivate(widget.currentUserId, !user.isPriv);
                        setState(() {});
                      },
                      child: Center(
                        child: Text(
                          user.isPriv ? "Make Account Public" : "Make Account Private",
                          style: GoogleFonts.nunito(
                              color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextButton.icon(
                    onPressed: logout,
                    icon: Icon(Icons.cancel, color: Colors.red),
                    label: Text(
                      "Logout",
                      style: TextStyle(color: Colors.red, fontSize: 20.0),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}


