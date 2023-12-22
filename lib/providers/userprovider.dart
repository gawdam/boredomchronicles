import 'package:boredomapp/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userProvider = StreamProvider<UserData?>((ref) {
  // Listen to the authentication state changes
  return FirebaseAuth.instance.authStateChanges().asyncMap((user) async {
    if (user != null) {
      return await getUserData(user.uid);
    } else {
      return null;
    }
  });
});

Future<UserData> getUserData(String userId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final user =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
  return UserData(
    uid: userId,
    username: user.data()!['username'],
    avatar: user.data()![
        'avatar'], // You might want to fetch the imageURL from Firestore as well
    boredomValue: user.data()!['boredomValue'],
    imagePath: prefs.getString('user_image_path') ?? 'assets/images/sloth.png',
  );
}
