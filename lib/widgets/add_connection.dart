import 'package:boredomapp/models/user.dart';
import 'package:boredomapp/providers/userprovider.dart';
import 'package:boredomapp/services/manage_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RequestConnection extends ConsumerStatefulWidget {
  UserData userData;

  RequestConnection({super.key, required this.userData});

  @override
  ConsumerState<RequestConnection> createState() =>
      _RequestConnectionWidgetState();
}

class _RequestConnectionWidgetState extends ConsumerState<RequestConnection> {
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
            title: const Text('Connection sent'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add any success message or content here
                const Text('Your connection request has been sent!'),
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
    try {
      String result = await ManageConnection.sendConnection(
        username: username,
        senderUid: widget.userData.uid,
      );

      setState(() {
        _connectionAttempt = result;
      });
    } catch (error) {
      setState(() {
        _connectionAttempt = error.toString();
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
                        onPressed: () async {
                          // TODO: Handle the submit logic, e.g., send connection request

                          // Close the dialog after handling the submit action
                          Navigator.pop(context);
                          await sendConnection(username);
                          ref.invalidate(userProvider);
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
