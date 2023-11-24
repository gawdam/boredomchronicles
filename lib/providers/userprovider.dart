import 'package:boredomapp/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProvider = FutureProvider<UserData>((ref) async {
  // Perform any asynchronous operation to get the user UID
  final UserData user = await getUserUID();
  return user;
});

Future<UserData> getUserUID() async {
  final user = FirebaseAuth.instance.currentUser!;

  final userdata =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  // String uid = user.uid;
  return UserData(
      uid: user.uid,
      username: userdata.data()!['username'],
      imageURL: userdata.data()!['image_url'],
      boredomValue: userdata.data()!['boredomValue']);
}
