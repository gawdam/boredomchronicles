import 'package:boredomapp/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> clearPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  Future<void> logout(BuildContext context, UserData data) async {
    try {
      Navigator.of(context).pop(); // Close the dialog

      await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(
        EmailAuthProvider.credential(
          email: '${data.username}@boredomapp.com',
          password: '12345678',
        ),
      );

      await clearPreferences();

      await _firestore.collection('users').doc(data.uid).delete();
      await _firestore.collection('tokens').doc(data.uid).delete();

      // 1. Delete user account
      await _auth.currentUser?.delete();

      // 3. Sign out the user

      await _auth.signOut();
    } catch (error) {
      // Handle errors as needed
      print('Error during logout: $error');
    }
  }
}
