import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:projedeneme/services/auth.dart';

import 'package:projedeneme/utils/dimension.dart';
import 'package:projedeneme/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:projedeneme/routes/Feedview.dart';

import 'edit_profile.dart';


class ChangePass extends StatefulWidget {
  @override

  _ChangePassState createState() => _ChangePassState();
}

class _ChangePassState extends State<ChangePass> {
  String _message = "";
  String mail = "";
  String newPass = "";
  String oldPass = "";
  String tempPass = "";
  String username = "";
  late int count;
  final _formKey = GlobalKey<FormState>();

  AuthService auth = AuthService();

  final blogText = GoogleFonts.nunito(
    color: const Color(0xFFE0E1DD),
    fontSize: 20.0,
  );

  //FirebaseAuth auth = FirebaseAuth.instance;

  void setMessage(String msg) {
    setState(() {
      _message = msg;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    count = 0;
  }

  Future<void> changePassword1(String mail, String oldpass,
      String newPass) async
  {
    var res = await auth.updatePass(newPass, mail, oldpass);

    print("RES: " + res.toString());
    if (res == "1") {
      print("passChange res should be 1");
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Password change success"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfile(),
                        ));
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              ],
            );
          });
    }
    else if (res == "3") {
      print("passChange res should be 3");
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                  "Please check your email and password and try again."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfile(),
                        ));
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              ],
            );
          });
    }
    else {
      print("passChange res should be else");
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("An error has occurred please try again."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfile(),
                        ));
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              ],
            );
          });
    }
  }

    @override
    Widget build(BuildContext context) {
      final user = Provider.of<User?>(context);
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'CHANGE PASSWORD',
            style: blogText,
          ),
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: Padding(
          padding: Dimen.regularPadding,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            fillColor: const Color(0xFF1467BA),
                            filled: true,
                            hintText: 'E-mail',
                            hintStyle: TextStyle(
                              color: const Color(0xFF778DA9),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: const Color(0xFF415A77)),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null) {
                              return 'E-mail field cannot be empty';
                            } else {
                              String trimmedValue = value.trim();
                              if (trimmedValue.isEmpty) {
                                return 'E-mail field cannot be empty';
                              }
                              if (!EmailValidator.validate(trimmedValue)) {
                                return 'Please enter a valid email';
                              }
                            }
                            return null;
                          },
                          onSaved: (value) {
                            if (value != null) {
                              this.mail = value;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          style: (TextStyle(color: const Color(0xFFE0E1DD))),
                          decoration: InputDecoration(
                            fillColor: const Color(0xFF1467BA),
                            filled: true,
                            hintText: 'Old Password',
                            hintStyle: TextStyle(
                                color: const Color(0xFF778DA9)),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: const Color(0xFF778DA9)),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          validator: (value) {
                            bool flag = true;
                            if (value == null) {
                              flag = false;
                              return 'Password field cannot be empty';
                            } else {
                              String trimmedValue = value.trim();
                              if (trimmedValue.isEmpty) {
                                flag = false;
                                return 'Password field cannot be empty';
                              }
                            }
                            return null;
                          },
                          onSaved: (value) {
                            if (value != null) {
                              oldPass = value;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          style: (TextStyle(color: const Color(0xFFE0E1DD))),
                          decoration: InputDecoration(
                            fillColor: const Color(0xFF1467BA),
                            filled: true,
                            hintText: 'New Password',
                            hintStyle: TextStyle(
                                color: const Color(0xFF778DA9)),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: const Color(0xFF778DA9)),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          validator: (value) {
                            bool flag = true;
                            if (value == null) {
                              flag = false;
                              return 'Password field cannot be empty';
                            } else {
                              String trimmedValue = value.trim();
                              if (trimmedValue.isEmpty) {
                                flag = false;
                                return 'Password field cannot be empty';
                              }
                              if (trimmedValue.length < 8) {
                                flag = false;
                                return 'Password must be at least 8 characters long';
                              }
                              if (flag) {
                                tempPass =
                                    value; //this is for to check confirm pass field
                              }
                            }
                            return null;
                          },
                          onSaved: (value) {
                            if (value != null) {
                              newPass = value;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          style: (TextStyle(color: const Color(0xFFE0E1DD))),
                          decoration: InputDecoration(
                            fillColor: const Color(0xFF1467BA),
                            filled: true,
                            hintText: 'Confirm New Password',
                            hintStyle: TextStyle(
                                color: const Color(0xFF778DA9)),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: const Color(0xFF778DA9)),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          validator: (value) {
                            if (value != tempPass) {
                              return 'Passwords must match.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            if (value != null && value == this.tempPass) {
                              newPass = value;
                              print("newpass: " + newPass);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      OutlinedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            print('Mail: ' +
                                mail +
                                "\noldPass: " +
                                oldPass
                                + "\nnewpass: " + newPass);
                            _formKey.currentState!.save();
                            print('Mail: ' +
                                mail +
                                "\noldPass: " +
                                oldPass
                                + "\nnewpass: " + newPass);
                            changePassword1(mail, oldPass, newPass);
                            setState(() {
                              count += 1;
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(
                            '   Change Password   ',
                            //Attempt: ${count!=null ? count:0}',
                            style: blogText,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF415A77),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    _message,
                    style: TextStyle(color: const Color(0xFFE0E1DD)),
                  ),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      );
    }
  }


