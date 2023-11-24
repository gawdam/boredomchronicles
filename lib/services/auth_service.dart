import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {
  final FirebaseAuth _firebase = FirebaseAuth.instance;

  Future<void> login(String email, String password) async {
    try {
      await _firebase.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // Handle login exceptions
      print('Login failed: ${e.message}');
      rethrow; // Rethrow the exception for the UI to handle
    }
  }

  Future<void> signup(
    String email,
    String password,
    String username,
    File? selectedImage,
  ) async {
    try {
      final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: email, password: password);

      if (selectedImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredentials.user!.uid}.jpeg');
        await storageRef.putFile(selectedImage);
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': username,
          'email': email,
          'image_url': imageUrl,
        });
      }
    } on FirebaseAuthException catch (e) {
      // Handle signup exceptions
      print('Signup failed: ${e.message}');
      rethrow; // Rethrow the exception for the UI to handle
    }
  }
}
