import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:projedeneme/services/db.dart';
import 'package:projedeneme/utils/colors.dart';
import 'package:projedeneme/utils/dimension.dart';
import 'package:projedeneme/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:provider/provider.dart';
import 'package:projedeneme/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projedeneme/routes/feedView.dart';


class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  DBService db = DBService();
  final _formKey = GlobalKey<FormState>();
  String _message = '';
  String name = "";
  String surname = "";
  String mail = "";
  String pass = "";

  AuthService auth = AuthService();


  void setmessage(String msg) {
    setState(() {
      _message = msg;
    });

  }

  @override
  void initState() {
    super.initState();
  }


  void buttonClicked() {
    print('Button Clicked');
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    if(user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'SIGNUP',
            style: kDefaultLabel,
          ),
          backgroundColor: AppColors.primaryColor,
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          decoration: InputDecoration(
                            fillColor: Colors.yellow[700],
                            filled: true,
                            hintText: 'Name',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.primaryColor,
                              ),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(30)),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          onSaved: (value) {
                            if (value != null) {
                              name = value;
                            }
                          }
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          decoration: InputDecoration(
                            fillColor: Colors.yellow[700],
                            filled: true,
                            hintText: 'Surname',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.primaryColor,
                              ),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(30)),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          onSaved: (value) {
                            if (value != null) {
                              surname = value;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          decoration: InputDecoration(
                            fillColor: Colors.yellow[700],
                            filled: true,
                            hintText: 'E-mail',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.primaryColor,
                              ),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(30)),
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
                              mail = value;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          decoration: InputDecoration(
                            fillColor: Colors.yellow[700],
                            filled: true,
                            hintText: 'Password',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.primaryColor,
                              ),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(30)),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,

                          validator: (value) {
                            if (value == null) {
                              return 'Password field cannot be empty';
                            }
                            else {
                              String trimmedValue = value.trim();
                              if (trimmedValue.isEmpty) {
                                return 'Password field cannot be empty';
                              }
                              if (trimmedValue.length < 8) {
                                return 'Password must be at least 8 characters long';
                              }
                            }
                            return null;
                          },

                          onSaved: (value) {
                            if (value != null) {
                              pass = value;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16,),


                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();

                              //showAlertDialog("Action", 'Button clicked');

                              auth.signupWithMailAndPass(mail, pass);

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                  SnackBar(content: Text('Registering in')));
                            }
                          },

                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              'Create account',
                              style:  kCountLabel,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _message,
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),


                ],
              ),
            ),
          ),
        ),

        backgroundColor: Colors.grey[600],
      );
    }
    else {
      db.addUser(name, surname, mail,user.uid);
      return FeedView();
    }
  }
}