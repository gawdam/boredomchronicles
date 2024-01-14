import 'package:boredomapp/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectionsScreen extends ConsumerWidget {
  final UserData userData;

  const ConnectionsScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print(userData.connectionState);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connections'),
        actions: const [
          Padding(
            padding: EdgeInsets.all(16.0),
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
      case null:
        return RequestConnectionWidget(userData: userData);
      case 'pending_outgoing':
        return const WithdrawConnectionRequestWidget();
      case 'pending_incoming':
        return const AcceptRejectConnectionRequestWidget();
      case 'connected':
        return const ConnectedUserWidget();
      default:
        return Container(); // Handle other states as needed
    }
  }
}

// ignore: must_be_immutable
class RequestConnectionWidget extends StatefulWidget {
  UserData userData;

  RequestConnectionWidget({super.key, required this.userData});

  @override
  State<RequestConnectionWidget> createState() =>
      _RequestConnectionWidgetState();
}

class _RequestConnectionWidgetState extends State<RequestConnectionWidget> {
  String _connectionAttempt = 'no-connection-attempt';

  void showConnectionResultDialog(
      BuildContext context, String _connectionAttempt) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (_connectionAttempt == 'error-no-user' ||
            _connectionAttempt == 'error-user-taken') {
          // Display error message for 'error-no-user'
          return AlertDialog(
            title: const Text('Connection Error'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_connectionAttempt == 'error-no-user'
                    ? 'The username does not exist!'
                    : 'This username is already taken!'),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Okay'),
                ),
              ],
            ),
          );
        } else {
          // Display success message for other cases
          return AlertDialog(
            title: const Text('Verification Done'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add any success message or content here
                const Text('Verification successful!'),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Okay'),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Future<void> sendConnection(username) async {
    String? recieverUid;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      // Get the user document
      DocumentSnapshot userDoc = querySnapshot.docs.first;
      print(userDoc.id);
      recieverUid = userDoc.id;

      // Check the connectionStatus field
      String? connectionState = userDoc['connectionState'];

      // Return false if the connectionStatus is 'pending-outgoing' or 'connected'
      if (connectionState == 'pending-outgoing' ||
          connectionState == 'connected') {
        setState(() {
          _connectionAttempt = 'error-user-taken';
        });
      } else {
        await FirebaseFirestore.instance
            .collection('connection-request')
            .doc(widget.userData.uid)
            .set({
          'timestamp': null,
          'sentByUID': widget.userData.uid,
          'sentToUID': recieverUid,
          'connectionStatus': 'pending_outgoing',
        });

        setState(() {
          _connectionAttempt = 'success';
        });
        print('user-added');
      }
    } else {
      // The user with the provided username does not exist
      setState(() {
        _connectionAttempt = 'error-no-user';
      });
    }
    showConnectionResultDialog(context, _connectionAttempt);
  }

  @override
  Widget build(BuildContext context) {
    void addConnection(BuildContext context) {
      String username = ''; // Variable to store the entered username

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Connection'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      // Update the username variable when the text changes
                      username = value;
                    },
                    decoration:
                        const InputDecoration(labelText: 'Enter Username'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Close the dialog when the 'X' button is pressed
                          Navigator.pop(context);
                        },
                        child: const Text('Close'),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Handle the submit logic, e.g., send connection request

                          // Close the dialog after handling the submit action
                          Navigator.pop(context);
                          sendConnection(username);
                        },
                        child: const Text('Submit'),
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
          label: const Text(
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
  const WithdrawConnectionRequestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Pending approval - sent'),
        // Widget for withdrawing connection request
        ElevatedButton(
          onPressed: () {
            // Implement logic to withdraw connection request
          },
          child: const Text('Withdraw Request'),
        ),
      ],
    );
  }
}

class AcceptRejectConnectionRequestWidget extends StatelessWidget {
  const AcceptRejectConnectionRequestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Pending approval - received'),
        // Widget for displaying connected user's profile picture and username
        // Widget for accepting or rejecting connection request
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                // Implement logic to accept connection request
              },
              child: const Text('Accept'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement logic to reject connection request
              },
              child: const Text('Reject'),
            ),
          ],
        ),
      ],
    );
  }
}

class ConnectedUserWidget extends StatelessWidget {
  const ConnectedUserWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Connected'),
        // Widget for displaying connected user's profile picture, username, and boredom value
      ],
    );
  }
}
