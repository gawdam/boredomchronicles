import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';

Future<void> handleBackgroundMessage(RemoteMessage? message) async {
  if (message == null) return;

  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");

  print("Payload: ${message.data}");
}

class NotificationManager {
  final firebaseMessaging = FirebaseMessaging.instance;
  late var token;

  Future<void> initNotifications() async {
    await firebaseMessaging.requestPermission();
    final fCMToken = await firebaseMessaging.getToken();
    print("---Token: $fCMToken");
    token = fCMToken;
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  Future<void> storeToken(uid) async {
    await FirebaseFirestore.instance
        .collection('tokens')
        .doc(uid)
        .set({'token': token});
  }

  Future<void> sendNotification(String toToken) async {
    final body = {
      "to": toToken,
      "notification": {
        "title": "Test",
        "body": "Didya get it modafaqa?",
      }
    };

    var response = await post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader:
            'key=AAAA_9Wncq0:APA91bGA_o9qDaU8GRCtWrHx5QDV8hHPt9zTMKPZ-ZAQ20X1EkN-ddnYewUdHhzcgHCvAH1Ano5mrTZTB80PvSTaihJR_oONzJbmO1Gq4Eyeoro90yTfFHV2x_wJ1cvOSbmLQPs36yFV'
      },
      body: jsonEncode(body),
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}
