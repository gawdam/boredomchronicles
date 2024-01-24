import 'package:boredomapp/models/user.dart';
import 'package:boredomapp/providers/userprovider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DisplayIncomingConnection extends StatelessWidget {
  DisplayIncomingConnection({super.key, required this.currentUser});

  final UserData currentUser;

  UserData? sender;

  Future<void> getSenderData() async {
    String SenderUid;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('connection-request')
        .where('sentToUID', isEqualTo: currentUser.uid)
        .where('connectionStatus', isEqualTo: 'pending')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      SenderUid = querySnapshot.docs.first['sentByUID'];
    } else {
      return;
    }

    sender = await getUserData(SenderUid);
  }

  @override
  Widget build(BuildContext context) {
    // getSenderData();
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
              const Text(
                'Incoming connection request',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(
                height: 20,
              ),
              Card(
                // color: Theme.of(context).colorScheme.secondary,
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(sender!.imagePath!),
                        backgroundColor: Colors.amber,
                      ),
                      SizedBox(height: 8),
                      Text(
                        sender!.username,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RawMaterialButton(
                    onPressed: () {},
                    child: Icon(
                      Icons.check_outlined,
                      color: Colors.black,
                    ),
                    shape: CircleBorder(),
                    elevation: 2,
                    fillColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  RawMaterialButton(
                    onPressed: () {},
                    child: Text(
                      'X',
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Roboto',
                          fontSize: 20,
                          fontWeight: FontWeight.w400),
                    ),
                    shape: CircleBorder(),
                    elevation: 2,
                    fillColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ],
              )
            ],
          );
        }
      },
    );
  }
}
