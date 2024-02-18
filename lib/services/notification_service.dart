import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationManager {
  final firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await firebaseMessaging.requestPermission();
    final fCMToken = await firebaseMessaging.getToken();
    print("Token: $fCMToken");
  }
}
