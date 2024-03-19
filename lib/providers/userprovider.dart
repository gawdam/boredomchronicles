import 'package:boredomapp/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

Future<UserData?> getUserData(String userId) async {
  final user =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
  if (user.data() == null) {
    return null;
  }
  return UserData(
      uid: userId,
      username: user.data()!['username'],
      avatar: user.data()![
          'avatar'], // You might want to fetch the imageURL from Firestore as well
      boredomValue: user.data()!['boredomValue'],
      imagePath: user.data()!['imagePath'],
      connectionState: user.data()!['connectionState'],
      connectedToUsername: user.data()!['connectedToUsername'],
      connectionID: user.data()!['connectionID']);
}

Future<void> saveUserDataToCloud(UserData user) async {
  try {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'username': user.username,
      'boredomValue': user.boredomValue,
      'avatar': user.avatar,
      'imagePath': user.imagePath,
      'connectionState': user.connectionState,
      'connectedToUsername': user.connectedToUsername,
      'updateTimestamp': Timestamp.now(),
      'connectionID': user.connectionID
    });
  } catch (e) {
    print('Error saving user data to cloud: $e');
    // Handle the error as needed
  }
}

Future<UserData?> getConnection(UserData? userData) async {
  if (userData == null) {
    return null;
  }
  if (userData.connectedToUsername != null) {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: userData.connectedToUsername)
        .limit(1)
        .get();

    var connectionID = querySnapshot.docs.first['uid'];
    return await getUserData(connectionID);
  } else {
    return null;
  }

  // sender = await getUserData(connectionID);

  // return null;
}
