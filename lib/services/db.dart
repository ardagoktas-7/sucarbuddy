import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projedeneme/routes/Feedview.dart';
import 'package:uuid/uuid.dart';

class DBService {
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final firestoreInstance = FirebaseFirestore.instance;

  Future addUserAutoID(String name, String mail, String token) async {
    var uuid = Uuid();
    final String userId = uuid.v4();
    userCollection
        .doc(token)
        .set({
          'id' : token,
          'name': name,
          'isPriv': false,
          'surname': name,
          'email': mail,
          'bio' : "",
          'photoUrl' : "",
          'username' : mail.substring(0,mail.indexOf('@'))
    })
    .then((value) => print('User added'))
    .catchError((error) => print('Error: ${error.toString()}'));

    DocumentSnapshot doc = await usersRef.doc(token).get();

    await followersRef
        .doc(token)
        .collection('userFollowers')
        .doc(token)
        .set({});

    doc = await usersRef.doc(token).get();
  }

  Future makeAccountPrivate(String? token, bool? isPrivate) async {
    firestoreInstance.collection("users").doc(token).update({
      'isPriv': isPrivate,
    });
    print("Updated");
  }

  Future deleteUser(String userId) async {
    firestoreInstance
        .collection("users")
        .where("userId", isEqualTo: userId)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        result.reference.delete();
      });
    });

    firestoreInstance
        .collection("chats")
        .where("userId", isEqualTo: userId)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        result.reference.delete();
      });
    });

    firestoreInstance
        .collection("posts")
        .where("userId", isEqualTo: userId)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        result.reference.delete();
      });
    });

    firestoreInstance
        .collection("followers")
        .where("userId", isEqualTo: userId)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        result.reference.delete();
      });
    });

    firestoreInstance
        .collection("following")
        .where("userId", isEqualTo: userId)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        result.reference.delete();
      });
    });


    firestoreInstance
        .collection("comments")
        .where("userId", isEqualTo: userId)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        result.reference.delete();
      });
    });

  }

  Future addUser(String name, String surname, String mail,String id) async {
    userCollection.doc(id).set({
      'id' : id,
      'name': name,
      'isPriv': false,
      'surname': surname,
      'email': mail,
      'bio' : "",
      'photoUrl' : "",
      'username' : mail.substring(0,mail.indexOf('@'))
    });

    DocumentSnapshot doc = await usersRef.doc(id).get();

    await followersRef
        .doc(id)
        .collection('userFollowers')
        .doc(id)
        .set({});

    doc = await usersRef.doc(id).get();
  }

}
