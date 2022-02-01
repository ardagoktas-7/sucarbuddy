import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'db.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DBService db = DBService();

  User? _userFromFirebase(User? user) {
    return user ?? null;
  }

  Stream<User?> get user {
    return _auth.authStateChanges().map(_userFromFirebase);
  }

  Future deleteUser() async {
    User user = await FirebaseAuth.instance.currentUser!;
    user.delete();
  }

  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User user = result.user!;
      return _userFromFirebase(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future updatePass(String newPass, String mail, String oldPass) async
  {
    print("mail is: "+mail + "\noldpass is: " + oldPass + "\nnewpass is: " + newPass);

    AuthCredential credential = EmailAuthProvider.credential(email: mail, password: oldPass);

    try{
      var credRes = await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(credential);

      await _auth.currentUser!.updatePassword(newPass);
      print("UPDATE PASS RES: "+ "1 SUCCESS");
      return ("1");
    }
    on FirebaseAuthException catch (e){
      print(e.code.toString());
      if(e.code.toString() == 'user-not-found' || e.code.toString() == 'wrong-password')
      {
        return ("3");
      }
      else if (e.code.toString() == 'weak-password' || e.code.toString() == 'requires-recent-login') {
        //signupWithMailAndPass(mail, pass);
        return ("3");
      } else if (e.code.toString() == 'too-many-requests') {
        return ("4");
      }
      else {
        return("3");
      }
    } catch (e) {
      print(e.toString());
      return ("4");
    }
  }

  Future signupWithMailAndPass(String mail, String pass) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: mail, password: pass);
      User user = result.user!;
      return _userFromFirebase(user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future loginWithMailAndPass(String mail, String pass) async {
    try {
      UserCredential result =
      await _auth.signInWithEmailAndPassword(email: mail, password: pass);
      User user = result.user!;
      return _userFromFirebase(user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);


    UserCredential result = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    bool isUserNew = result.additionalUserInfo!.isNewUser;

    User? user = result.user;
    print(user.toString());

    if(user!.displayName != null && isUserNew)
    {
      db.addUserAutoID(user.displayName!, user.email!, user.uid);
    }
    return _userFromFirebase(user);
    // Once signed in, return the UserCredential
    //return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }


  Future<DocumentSnapshot> fetchCurrentUser(String uuid) async {
    return await FirebaseFirestore.instance.collection('users').doc(uuid).get();
  }


  Future signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    print(credential.toString());
    UserCredential result = await FirebaseAuth.instance.signInWithCredential(credential);
    bool isUserNew = result.additionalUserInfo!.isNewUser;

    User? user = result.user;
    print(user.toString());

    if(user!.displayName != null && isUserNew)
    {
      db.addUserAutoID(user.displayName!, user.email!, user.uid);
    }


    return _userFromFirebase(user);
  }



  Future<void> signOutFromGoogle() async{
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    await _googleSignIn.signOut();
    await _auth.signOut();

  }

}