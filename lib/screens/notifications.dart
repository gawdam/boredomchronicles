import 'dart:async';
import 'dart:io';

import 'package:boredomapp/models/user.dart';
import 'package:boredomapp/providers/userprovider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  UserData userData;
  NotificationsScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _incomingNotificationsEnabled = true;
  bool _outgoingNotificationsEnabled = true;
  bool _isSaving = false;
  String? _connectionUID;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  @override
  initState() {
    super.initState();

    getNotificationData();
  }

  Future<void> getNotificationData() async {
    UserData? connectionData = await getConnection(widget.userData);
    if (connectionData == null) {
      setState(() {
        _connectionUID = 'NotConnected';
      });
    } else {
      var snapshot = await FirebaseFirestore.instance
          .collection('tokens')
          .doc(connectionData.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          return documentSnapshot;
        }
      });
      setState(() {
        if (snapshot != null) {
          print('snapshot not null');
          _incomingNotificationsEnabled = snapshot['incoming'];
          _outgoingNotificationsEnabled = snapshot['outgoing'];
          _titleController.text = snapshot['notificationTitle'];
          _bodyController.text = snapshot['notificationBody'];
          _connectionUID = connectionData.uid;
        } else {
          print("null snapshot");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_connectionUID == null) {
      return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('Notification Settings'),
          ),
          body: const Center(child: CircularProgressIndicator()));
    }
    if (_connectionUID != 'NotConnected') {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Notification Settings'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Incoming notifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 80),
                  Switch(
                    value: _incomingNotificationsEnabled,
                    activeColor: Theme.of(context).colorScheme.primaryContainer,
                    onChanged: (value) {
                      setState(() {
                        _incomingNotificationsEnabled = value;
                      });
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Outgoing notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 80),
                  Switch(
                    value: _outgoingNotificationsEnabled,
                    activeColor: Theme.of(context).colorScheme.primaryContainer,
                    onChanged: (value) {
                      setState(() {
                        _outgoingNotificationsEnabled = value;
                      });
                    },
                  ),
                ],
              ),
              const Divider(height: 30, thickness: 1),
              RichText(
                text: TextSpan(
                  text: 'Notifications to ',
                  style:
                      const TextStyle(fontFamily: 'PixelifySans', fontSize: 20),
                  children: <TextSpan>[
                    TextSpan(
                      text: widget.userData.connectedToUsername,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary, // You can set your desired color
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Title',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        TextFormField(
                          // initialValue: "Attention! Peak boredom reached!",
                          controller: _titleController,
                          enabled: _outgoingNotificationsEnabled,
                          maxLength: 35,
                          decoration: const InputDecoration(
                            hintText: 'Enter notification title',
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Body',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                        TextFormField(
                          // initialValue:
                          //     ,
                          controller: _bodyController,
                          enabled: _outgoingNotificationsEnabled,
                          maxLength: 500,
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration(
                            hintText: 'Enter notification body',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // SizedBox(height: 200),
              Expanded(
                child: Container(),
              ),
              _isSaving
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          _isSaving = true;
                          await _saveNotificationSettings();
                          // await Future.delayed(Duration(seconds: 1));
                          _isSaving = false;
                        },
                        child: const Text('Save'),
                      ),
                    ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: const Center(
        child: Text(
          'Notifications are disabled.\n\n You need to be connected to another person to enable notifications.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Future<void> _saveNotificationSettings() async {
    // Implement your logic to save notification settings
    String title = _titleController.text;
    String body = _bodyController.text;
    // print(connectionUID);

    print(_connectionUID);

    await FirebaseFirestore.instance
        .collection('tokens')
        .doc(_connectionUID)
        .update({
      'incoming': _incomingNotificationsEnabled,
      'outgoing': _outgoingNotificationsEnabled,
      'notificationTitle': title,
      'notificationBody': body,
    });
    await getNotificationData();
    // You can add logic here to save these settings to your preferred storage mechanism
  }

  @override
  void dispose() {
    // Clean up controllers
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }
}
