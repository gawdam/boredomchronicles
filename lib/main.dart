import 'dart:convert';

import 'package:boredomapp/firebase_options.dart';
import 'package:boredomapp/screens/auth.dart';
import 'package:boredomapp/screens/homepage.dart';
import 'package:boredomapp/screens/splash.dart';
import 'package:boredomapp/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_theme/json_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'models/user_history.dart';

final DatabaseService databaseService = DatabaseService();

Future<void> storeDataInDatabase(uid) async {
  final db = databaseService;

  final now = DateTime.now();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final boredomValue = prefs.getDouble('boredomValue') ?? 0;
  final data = UserHistory(uid: uid, timestamp: now, value: boredomValue);
  db.insertBoredomData(data);
}

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      storeDataInDatabase(user.uid);
    } else {
      print('User not logged in!');
    }
    print(
        "Native called background task: $task"); //simpleTask will be emitted here.
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final boredomValue = prefs.getDouble('boredomValue') ?? 50;

  Workmanager().registerPeriodicTask(
    "periodic-task-identifier",
    "simplePeriodicTask",
    frequency: const Duration(hours: 1),
    inputData: {
      'boredomValue': boredomValue,
    },
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
