import 'dart:convert';

import 'package:boredomapp/firebase_options.dart';
import 'package:boredomapp/screens/auth.dart';
import 'package:boredomapp/screens/homepage.dart';
import 'package:boredomapp/screens/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:json_theme/json_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final themeStr =
      await rootBundle.loadString('assets/themes/base_theme_3.json');
  final themeJson = jsonDecode(themeStr);
  final theme = ThemeDecoder.decodeThemeData(themeJson)!;

  runApp(ProviderScope(
      child: App(
    theme: theme,
  )));
}

class App extends StatelessWidget {
  const App({super.key, required this.theme});
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
