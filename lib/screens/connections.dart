import 'package:flutter/material.dart';

class ConnectionsScreen extends StatelessWidget {
  final String connectionState;

  ConnectionsScreen({required this.connectionState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connections'),
      ),
      body: Center(
        child: buildConnectionWidget(),
      ),
    );
  }

  Widget buildConnectionWidget() {
    switch (connectionState) {
      case 'Not connected':
        return RequestConnectionWidget();
      case 'Pending approval - sent':
        return WithdrawConnectionRequestWidget();
      case 'Pending approval - received':
        return AcceptRejectConnectionRequestWidget();
      case 'Connected':
        return ConnectedUserWidget();
      default:
        return Container(); // Handle other states as needed
    }
  }
}

class RequestConnectionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Not connected'),
        // Widget for sending connection request
        ElevatedButton(
          onPressed: () {
            // Implement logic to send connection request
          },
          child: Icon(Icons.person_add_alt_sharp),
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
