import 'package:boredomapp/models/user.dart';
import 'package:boredomapp/providers/userprovider.dart';
import 'package:boredomapp/widgets/connection_add.dart';
import 'package:boredomapp/widgets/connection_display.dart';
import 'package:boredomapp/widgets/connection_incoming.dart';
import 'package:boredomapp/widgets/connection_withdraw.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectionsScreen extends ConsumerWidget {
  const ConnectionsScreen({super.key});

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
      Color connectionColor;
      switch (data!.connectionState) {
        case 'connected':
          connectionColor = Colors.green;
        case null:
          connectionColor = Colors.red;
        default:
          connectionColor = Colors.yellow;
      }
      return Scaffold(
        appBar: AppBar(
          title: const Text('Connection'),
          actions: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                backgroundColor: connectionColor,
                radius: 5,
              ),
            )
          ],
        ),
        body: Center(
          child: buildConnectionWidget(data, ref),
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
          return ConnectedUser(
            currentUser: userData,
          );
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
