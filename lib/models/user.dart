import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String uid;
  String username;
  String avatar;
  double boredomValue;
  String? imagePath;
  String? connectionState;
  String? connectedToUsername;
  Timestamp? updateTimestamp;
  String? connectionID;

  UserData(
      {required this.uid,
      required this.username,
      required this.boredomValue,
      required this.avatar,
      this.imagePath,
      this.connectionState = 'not_connected',
      this.connectedToUsername,
      this.updateTimestamp,
      this.connectionID});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'boredomValue': boredomValue,
      'avatar': avatar,
      'imagePath': imagePath,
      'connectionState': connectionState,
      'connectedToUsername': connectedToUsername,
      'updateTimestamp': updateTimestamp,
      'connectionID': connectionID
    };
  }
}
