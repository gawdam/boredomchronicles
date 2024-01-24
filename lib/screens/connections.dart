import 'package:boredomapp/models/user.dart';
import 'package:boredomapp/providers/userprovider.dart';
import 'package:boredomapp/services/manage_connection.dart';
import 'package:boredomapp/widgets/connection_add.dart';
import 'package:boredomapp/widgets/connection_incoming.dart';
import 'package:boredomapp/widgets/connection_withdraw.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectionsScreen extends ConsumerWidget {
  ConnectionsScreen();

  // @override
  // void initState() {
  //   super.initState();
  //   connectionColor = Color.fromARGB(204, 228, 37, 24);
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var user = ref.watch(userProvider);
    // ref.invalidate(userProvider);
    // setState(() {});
    // return Builder(builder: builder);
    return user.when(data: (UserData? data) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Connections'),
          actions: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: CircleAvatar(
                backgroundColor: Colors.red,
                radius: 5,
              ),
            )
          ],
        ),
        body: Center(
          child: buildConnectionWidget(data!, ref),
        ),
      );
    }, error: (Object error, StackTrace stackTrace) {
      return Text('Please login again. $error');
    }, loading: () {
      return const CircularProgressIndicator();
    });
  }

  Widget buildConnectionWidget(UserData userData, WidgetRef ref) {
    switch (userData.connectionState) {
      case 'pending_outgoing':
        {
          // setState(() {
          // connectionColor = Colors.yellow;
          // });
          return WithdrawConnectionRequest(userData: userData);
        }
      case 'pending_incoming':
        {
          // setState(() {
          //   connectionColor = Colors.yellow;
          // });

          return DisplayIncomingConnection(
            currentUser: userData,
          );
        }
      case 'connected':
        {
          // setState(() {
          //   connectionColor = Colors.green;
          // });
          return const ConnectedUser();
        }
      default:
        {
          // setState(() {
          //   connectionColor = Colors.red;
          // });
          return RequestConnection(userData: userData);
        }
    }
  }
}

class ConnectedUser extends StatelessWidget {
  const ConnectedUser({super.key});

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
