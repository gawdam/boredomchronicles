import 'package:boredomapp/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionsScreen extends ConsumerWidget {
  final UserData userData;

  ConnectionsScreen({required this.userData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connections'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircleAvatar(
              backgroundColor: Color.fromARGB(204, 228, 37, 24),
              radius: 5,
            ),
          )
        ],
      ),
      body: Center(
        child: buildConnectionWidget(),
      ),
    );
  }

  Widget buildConnectionWidget() {
    switch (userData.connectionState) {
      case 'not_connected':
        return RequestConnectionWidget(userData: userData);
      case 'pending_outgoing':
        return WithdrawConnectionRequestWidget();
      case 'pending_incoming':
        return AcceptRejectConnectionRequestWidget();
      case 'connected':
        return ConnectedUserWidget();
      default:
        return Container(); // Handle other states as needed
    }
  }
}

class RequestConnectionWidget extends StatefulWidget {
  UserData userData;

  RequestConnectionWidget({required this.userData});

  @override
  State<RequestConnectionWidget> createState() =>
      _RequestConnectionWidgetState();
}

class _RequestConnectionWidgetState extends State<RequestConnectionWidget> {
  String _connectionAttempt = 'no-connection-attempt';

  Future<void> sendConnection(username) async {
    String? reciever_uid;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      // Get the user document
      DocumentSnapshot userDoc = querySnapshot.docs.first;
      reciever_uid = userDoc.id;

      // Check the connectionStatus field
      String connectionStatus = userDoc['connectionStatus'];

      // Return false if the connectionStatus is 'Pending' or 'Connected'
      if (connectionStatus == 'Pending' || connectionStatus == 'Connected') {
        setState(() {
          _connectionAttempt = 'error-user-taken';
        });
      } else {
        await FirebaseFirestore.instance
            .collection('connection-request')
            .doc(widget.userData.uid)
            .update({
          'timestamp': null,
          'sentByUID': widget.userData.uid,
          'sentToUID': reciever_uid,
          'connectionStatus': 'pending_outgoing',
        });

        setState(() {
          _connectionAttempt = 'success';
        });
      }
    } else {
      // The user with the provided username does not exist
      setState(() {
        _connectionAttempt = 'error-no-user';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    void addConnection(BuildContext context) {
      String username = ''; // Variable to store the entered username

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return _connectionAttempt == 'error-no-user'
              ? StatefulBuilder(builder: (context, setState) {
                  return AlertDialog(
                    title: Text('Connection Error'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('There is no such user!'),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            // Reset _connectionAttempt to 'not connected'
                            _connectionAttempt = 'not connected';
                            Navigator.pop(context);
                          },
                          child: Text('Okay'),
                        ),
                      ],
                    ),
                  );
                })
              : StatefulBuilder(builder: (context, setState) {
                  return AlertDialog(
                    title: Text('Add Connection'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          onChanged: (value) {
                            // Update the username variable when the text changes
                            username = value;
                          },
                          decoration:
                              InputDecoration(labelText: 'Enter Username'),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                // Close the dialog when the 'X' button is pressed
                                Navigator.pop(context);
                              },
                              child: Text('Close'),
                            ),
                            TextButton(
                              onPressed: () {
                                // TODO: Handle the submit logic, e.g., send connection request
                                sendConnection(username);
                                // Close the dialog after handling the submit action
                                // Navigator.pop(context);
                              },
                              child: Text('Submit'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                });
        },
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextButton.icon(
          icon: Image.asset(
            'assets/images/add_friend.png',
            scale: 20,
          ),
          label: Text(
            'Add Connection',
            style: TextStyle(fontSize: 22),
          ),
          onPressed: () {
            addConnection(context);
          },
        ),
      ],
    );
  }
}

class WithdrawConnectionRequestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Pending approval - sent'),
        // Widget for withdrawing connection request
        ElevatedButton(
          onPressed: () {
            // Implement logic to withdraw connection request
          },
          child: Text('Withdraw Request'),
        ),
      ],
    );
  }
}

class AcceptRejectConnectionRequestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Pending approval - received'),
        // Widget for displaying connected user's profile picture and username
        // Widget for accepting or rejecting connection request
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                // Implement logic to accept connection request
              },
              child: Text('Accept'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement logic to reject connection request
              },
              child: Text('Reject'),
            ),
          ],
        ),
      ],
    );
  }
}

class ConnectedUserWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Connected'),
        // Widget for displaying connected user's profile picture, username, and boredom value
      ],
    );
  }
}
