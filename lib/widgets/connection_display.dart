import 'package:boredomapp/models/user.dart';
import 'package:boredomapp/providers/userprovider.dart';
import 'package:boredomapp/screens/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ConnectedUser extends StatelessWidget {
  ConnectedUser({super.key, required this.currentUser});

  UserData? connectedUser;
  UserData currentUser;
  int? connectedFor;

  Future<void> getSenderData() async {
    String SenderUid;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('connection-request')
        .where('sentToUID', isEqualTo: currentUser.uid)
        .where('connectionStatus', isEqualTo: 'accepted')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      SenderUid = querySnapshot.docs.first['sentByUID'];
      Timestamp connectionTimestamp = querySnapshot.docs.first['timestamp'];
      connectedFor =
          DateTime.now().difference(connectionTimestamp.toDate()).inDays;
      connectedUser = await getUserData(SenderUid);
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getSenderData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError)
            return Text('Error:${snapshot.error}');
          else {
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
                                NetworkImage(connectedUser!.imagePath!),
                            backgroundColor:
                                Theme.of(context).colorScheme.background,
                          ),
                          SizedBox(height: 8),
                          Text(
                            connectedUser!.username,
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
                            getBoredomIcon(connectedUser!.boredomValue),
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
                    onPressed: () {},
                    child: Text(
                      'Remove connection',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ))
              ],
            );
          }
        });
  }
}
