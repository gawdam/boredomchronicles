import 'package:flutter/material.dart';

class DisplayIncomingConnection extends StatelessWidget {
  const DisplayIncomingConnection({super.key});

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
