import 'package:boredomapp/models/user.dart';
import 'package:boredomapp/providers/userprovider.dart';
import 'package:boredomapp/screens/homepage.dart';
import 'package:boredomapp/services/manage_connection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectedUser extends ConsumerWidget {
  ConnectedUser({super.key, required this.currentUser});

  UserData? connectedUser;
  UserData currentUser;
  int connectedFor = 0;

  Future<UserData?> getSenderData() async {
    final connection = await FirebaseFirestore.instance
        .collection('connection-request')
        .doc(currentUser.connectionID)
        .get();

    Timestamp connectionTimestamp = connection.data()!['timestamp'];
    connectedFor =
        DateTime.now().difference(connectionTimestamp.toDate()).inDays;
    return await getConnection(currentUser);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
        future: getSenderData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError)
            return Text('Error:${snapshot.error}');
          else {
            if (snapshot.data != null) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    child: Card(
                      // color: Theme.of(context).colorScheme.secondary,
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  NetworkImage(snapshot.data!.imagePath!),
                              backgroundColor:
                                  Theme.of(context).colorScheme.background,
                            ),
                            SizedBox(height: 8),
                            Text(
                              snapshot.data!.username!,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Connected for ${(connectedFor.toString())} days",
                              style: const TextStyle(fontSize: 11),
                            ),
                            SizedBox(height: 12),
                            Text(
                              getBoredomIcon(snapshot.data!.boredomValue),
                              style: TextStyle(fontSize: 30),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[900]),
                      onPressed: () async {
                        await ManageConnection.removeConnection(
                            currentUser, snapshot.data!);
                        ref.invalidate(userProvider);
                      },
                      child: Text(
                        'Remove connection',
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ))
                ],
              );
            } else {
              return CircularProgressIndicator();
            }
          }
        });
  }
}
