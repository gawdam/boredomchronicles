import 'dart:convert';

import 'package:boredomapp/firebase_options.dart';
import 'package:boredomapp/screens/auth.dart';
import 'package:boredomapp/screens/homepage.dart';
import 'package:boredomapp/screens/splash.dart';
import 'package:boredomapp/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_theme/json_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'models/user_history.dart';

final DatabaseService db = DatabaseService();

Future<void> storeDataInDatabase(uid, boredomValue) async {
  final now = DateTime.now();
  debugPrint("Checkpoint 3");
  final data = UserHistory(uid: uid, timestamp: now, value: boredomValue);
  await db.insertBoredomData(data);
}

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    late double cloudBoredomValue = 0;
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      cloudBoredomValue = await FirebaseFirestore.instance
          .collection('users')
          .doc()
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          return documentSnapshot['boredomValue'];
        }
        return 0.0;
      });
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double boredomValue = prefs.getDouble('boredomValue') ?? cloudBoredomValue;
    await Firebase.initializeApp();

    switch (task) {
      case "storeValues":
        if (inputData != null) {
          final userID = inputData['userID'];
          await storeDataInDatabase(userID, boredomValue);
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userID)
              .update({
            'boredomValue': boredomValue,
            'updateTimestamp': Timestamp.now()
          });
        }
      case "boredomTicker":
        boredomValue = (boredomValue - 6.25).clamp(0.0, 99.9);
        prefs.setDouble('boredomValue', boredomValue);
    }
    //simpleTask will be emitted here.
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().cancelAll();

  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Workmanager().registerPeriodicTask(
    "boredomTicker",
    "boredomTicker",
    frequency: const Duration(minutes: 15),
  );

  final themeStr =
      await rootBundle.loadString('assets/themes/base_theme_3.json');
  final themeJson = jsonDecode(themeStr);
  final theme = ThemeDecoder.decodeThemeData(themeJson)!;

  runApp(ProviderScope(
      child: MyApp(
    theme: theme,
  )));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boredom Meter',
      theme: theme.copyWith(
          textTheme: theme.textTheme.apply(fontFamily: 'PixelifySans')),
      themeMode: ThemeMode.dark,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.hasData) {
            return const HomePage();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
