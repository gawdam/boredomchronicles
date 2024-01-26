// services/add_connection.dart
import 'package:boredomapp/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageConnection {
  static Future<String> sendConnection({
    required String username,
    required String senderUid,
  }) async {
    String? receiverUid;

    // Query Firestore to find the user with the provided username
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Get the user document
      DocumentSnapshot userDoc = querySnapshot.docs.first;
      receiverUid = userDoc.id;

      // Check the connectionStatus field
      String? connectionState = userDoc['connectionState'];

      // Return false if the connectionStatus is 'pending-outgoing' or 'connected'
      if (connectionState == 'pending_outgoing' ||
          connectionState == 'connected') {
        return Future.error('error-user-taken');
      } else {
        // Send connection request
        await FirebaseFirestore.instance
            .collection('users')
            .doc(senderUid)
            .update({
          'connectionState': 'pending_outgoing',
          'connectedToUsername': username,
        });

        //Change reciever status to pending_incoming

        await FirebaseFirestore.instance
            .collection('users')
            .doc(receiverUid)
            .update({
          'connectionState': 'pending_incoming',
          // 'connectedToUsername': username,
        });

        await FirebaseFirestore.instance
            .collection('connection-request')
            .doc(senderUid)
            .set({
          'timestamp': Timestamp.now(),
          'sentByUID': senderUid,
          'sentToUID': receiverUid,
          'connectionStatus': 'pending',
        });

        return Future.value('success');
      }
    } else {
      // The user with the provided username does not exist
      return Future.error('error-no-user');
    }
  }

  static Future<void> withdrawConnection(
    String senderUid,
  ) async {
    await FirebaseFirestore.instance
        .collection('connection-request')
        .doc(senderUid)
        .update({
      'timestamp': Timestamp.now(),
      'connectionStatus': 'withdrawn',
    });
    String receiverUid = await FirebaseFirestore.instance
        .collection('connection-request')
        .doc(senderUid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        return documentSnapshot['sentToUid'] ?? '';
      } else {
        return '';
      }
    }).catchError((error) {
      // Handle error
      print('Error getting connection request: $error');
      return ''; // or handle accordingly based on your requirement
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverUid)
        .update({
      'connectionState': null,
      // 'connectedToUsername': username,
    });

    await FirebaseFirestore.instance.collection('users').doc(senderUid).update({
      'connectionState': null,
      'connectedToUsername': null,
    });
  }

  static Future<void> acceptConnection(
      UserData sender, UserData reciever) async {
    await FirebaseFirestore.instance
        .collection('connection-request')
        .doc(sender.uid)
        .update({
      'timestamp': Timestamp.now(),
      'connectionStatus': 'accepted',
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(sender.uid)
        .update({
      'connectionState': 'connected',
      'connectedToUsername': reciever.username,
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(reciever.uid)
        .update({
      'connectionState': 'connected',
      'connectedToUsername': sender.username,
    });
  }

  static Future<void> rejectConnection(
      UserData sender, UserData reciever) async {
    await FirebaseFirestore.instance
        .collection('connection-request')
        .doc(sender.uid)
        .update({
      'timestamp': Timestamp.now(),
      'connectionStatus': 'rejected',
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(sender.uid)
        .update({
      'connectionState': null,
      'connectedToUsername': null,
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(reciever.uid)
        .update({
      'connectionState': null,
      'connectedToUsername': null,
    });
  }
}
