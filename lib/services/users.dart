import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:projedeneme/services/utils.dart';

class UserService {
  UtilsService _utilsService = UtilsService();
  Future<void> updateProfile(
      File _profileImage) async {
    String photoUrl = '';

    if (_profileImage != null) {
      photoUrl = await _utilsService.uploadFile(_profileImage,
          'user/profile/${FirebaseAuth.instance.currentUser?.uid}/profile');
    }

    Map<String, Object> data = new HashMap();
    if (photoUrl != '') data['photoUrl'] = photoUrl;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update(data);
  }
}