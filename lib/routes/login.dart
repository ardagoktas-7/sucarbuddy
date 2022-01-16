import 'package:flutter/cupertino.dart';
import 'package:projedeneme/utils/colors.dart';
import 'package:projedeneme/utils/dimension.dart';
import 'package:projedeneme/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:provider/provider.dart';
import 'package:projedeneme/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projedeneme/routes/feedView.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';



class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _message = '';
  final _formKey = GlobalKey<FormState>();
  String mail = "";
  String pass = "";
  bool isHidden = false;
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



  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    if(user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'LOGIN',
            style: kCountLabel,
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
                  SizedBox(height: 20,),
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
                            prefixIcon: Icon(Icons.mail),
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
                          obscureText: isHidden,
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
                            prefixIcon: Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon:
                              isHidden ? Icon(Icons.visibility_off) : Icon(
                                  Icons.visibility),
                              onPressed: togglePasswordVisibility,
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          //obscureText: true,
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


                  Container(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      child: Text('Forgotten Password?'),
                      onPressed: () {},
                    ),
                  ),


                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();

                              //showAlertDialog("Action", 'Button clicked');


                              auth.loginWithMailAndPass(mail, pass);

                              FirebaseCrashlytics.instance.setUserIdentifier(mail);

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                  SnackBar(content: Text('Logging in')));
                            }
                          },

                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              'Login',
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


                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Don\'t have an account?'),
                      TextButton(
                        child:
                        Text(
                          'SIGN UP',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                      ),
                    ],
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
      return FeedView();
    }
  }

  void togglePasswordVisibility() => setState(() => isHidden = !isHidden);


}