import 'dart:async';

import 'package:boredomapp/providers/userprovider.dart';
import 'package:boredomapp/screens/sidedrawer.dart';
import 'package:boredomapp/services/debouncer.dart';
import 'package:boredomapp/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/boredombutton.dart';
import '../widgets/boredomgauge.dart';

String getBoredomIcon(double boredomValue) {
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

  return borednessIcon;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  late double _boredomValue = 50;
  late Timer _timer;
  final notificationManager = NotificationManager();

  @override
  void initState() {
    super.initState();

    _loadBoredomValue();
    _storeNotificationToken();

    // Set up a timer to reduce boredom every 1 minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        // Reduce boredom by 100 units
        _loadBoredomValue();
        _boredomValue = (_boredomValue);
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

  Future<void> _storeNotificationToken() async {
    await notificationManager.initNotifications();
    await notificationManager.storeToken(user!.uid);
  }

  Future<void> _onMaxBoredom(connectionUID) async {
    await _sendNotification(connectionUID);
  }

  Future<void> _sendNotification(connectionUID) async {
    await FirebaseFirestore.instance
        .collection('tokens')
        .doc(connectionUID)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        if (!(documentSnapshot.data() as Map<String, dynamic>)
            .containsKey('timestamp')) {
          await notificationManager.sendNotification(documentSnapshot['token']);
          await FirebaseFirestore.instance
              .collection('tokens')
              .doc(connectionUID)
              .update({'timestamp': Timestamp.now()});
        } else if (DateTime.now()
                .difference(documentSnapshot['timestamp'].toDate())
                .inHours >
            1) {
          await notificationManager.sendNotification(documentSnapshot['token']);
          await FirebaseFirestore.instance
              .collection('tokens')
              .doc(connectionUID)
              .update({'timestamp': Timestamp.now()});
        }
      } else {
        return '';
      }
    }).catchError((error) {
      // Handle error
      print('Error getting token request: $error');
      return ''; // or handle accordingly based on your requirement
    });
  }

  Future<void> _saveBoredomValue(boredomValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('boredomValue', boredomValue);
  }

  Future<void> _saveBoredomValueToCloud(boredomValue) async {
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update(
        {'boredomValue': boredomValue, 'updateTimestamp': Timestamp.now()});
    if (boredomValue! >= 100.0) {
      print('peaked');
      String connectionUID = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          return documentSnapshot['connectionID'] ?? '';
        } else {
          return '';
        }
      });
      ;
      String connectedtoUID = await FirebaseFirestore.instance
          .collection('connection-request')
          .doc(connectionUID)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          return documentSnapshot['sentToUID'] ?? '';
        } else {
          return '';
        }
      });

      await _sendNotification(connectedtoUID);
      await setBoredomValue(99.9);
    }
  }

  Future<void> _loadBoredomValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Load boredom value from shared preferences
      _boredomValue = prefs.getDouble('boredomValue') ?? 50;
      print(_boredomValue);
    });
  }
  // Initial value

  Future<void> setBoredomValue(double? boredomValue) async {
    setState(() {
      _boredomValue = (boredomValue ?? 50).clamp(0.0, 100.0);
      _saveBoredomValue(_boredomValue);
    });
    _timer.cancel();
    _timer = Timer(const Duration(seconds: 5), () {
      _saveBoredomValueToCloud(_boredomValue);
      boredomValue = null;
    });
  }

  Future<void> clearPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  @override
  Widget build(BuildContext context) {
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
            child: Container(
              width: 250,
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
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        getBoredomIcon(_boredomValue),
                        style: const TextStyle(fontSize: 40),
                      )
                      // You can add more widgets or information here
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          BoredomGauge(
            value: _boredomValue,
            onValueChanged: setBoredomValue,
            onMaxBoredom: (s) {},
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
