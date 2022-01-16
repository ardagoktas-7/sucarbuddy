import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  late final String username;
  late final String email;
  final String photoUrl;
  late final String name;
  final bool isPriv;
  final String surname;
  late final String bio;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.photoUrl,
    required this.name,
    required this.isPriv,
    required this.surname,
    required this.bio,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['id'],
      email: doc['email'],
      username: doc['username'],
      photoUrl: doc['photoUrl'],
      name: doc['name'],
      isPriv: doc['isPriv'],
      surname: doc['surname'],
      bio: doc['bio'],
    );
  }
}