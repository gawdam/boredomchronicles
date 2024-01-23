// services/add_connection.dart
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
    await FirebaseFirestore.instance.collection('users').doc(senderUid).update({
      'connectionState': null,
      'connectedToUsername': null,
    });
  }
}
