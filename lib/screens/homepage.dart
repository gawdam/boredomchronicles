import 'dart:async';

import 'package:boredomapp/models/user_history.dart';
import 'package:boredomapp/screens/sidedrawer.dart';
import 'package:boredomapp/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../widgets/boredombutton.dart';
import '../widgets/boredomgauge.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  late double _boredomValue = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _loadBoredomValue();

    // Set up a timer to reduce boredom every 1 minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        // Reduce boredom by 100 units
        _loadBoredomValue();

        _boredomValue = (_boredomValue - 0.416666666);
        setBoredomValue(_boredomValue);
      });
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  Future<void> _saveBoredomValue(boredomValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('boredomValue', boredomValue);
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'boredomValue': _boredomValue, 'updateTimestamp': Timestamp.now()});
  }

  Future<void> _loadBoredomValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Load boredom value from shared preferences
      _boredomValue = prefs.getDouble('boredomValue') ?? 50;
    });
  }
  // Initial value

  void setBoredomValue(value) {
    setState(() {
      _boredomValue = (value).clamp(0.0, 100.0);
      _saveBoredomValue(_boredomValue);
    });
  }

  Future<void> clearPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  @override
  Widget build(BuildContext context) {
    Text getBoredomIcon(double boredomValue) {
      String borednessIcon = '😐';
      if (boredomValue >= 0 && boredomValue <= 25) {
        borednessIcon = '😐';
      } else if (boredomValue > 25 && boredomValue <= 50) {
        borednessIcon = '😕';
      } else if (boredomValue > 50 && boredomValue <= 75) {
        borednessIcon = '😟'; // Icon for medium boredom
      } else {
        borednessIcon = '😫';
      } // Icon for high boredom

      return Text(borednessIcon, style: const TextStyle(fontSize: 40));
    }

    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(
        title: const Text('Boredom Meter'),
        actions: [
          IconButton(
            onPressed: () async {
              await clearPreferences();
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.exit_to_app),
            color: Theme.of(context).colorScheme.primary,
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Card(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withOpacity(0.7),
              elevation: 15,
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Your boredom level',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                    const SizedBox(height: 10),
                    getBoredomIcon(_boredomValue)
                    // You can add more widgets or information here
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          BoredomGauge(
            value: _boredomValue,
            onValueChanged: setBoredomValue,
          ),
          const SizedBox(height: 20),
          BoredomButton(
            boredomValue: _boredomValue,
            onPressed: setBoredomValue,
          ),
        ],
      ),
    );
  }
}
