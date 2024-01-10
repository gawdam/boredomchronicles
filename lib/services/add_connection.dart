import 'package:cloud_firestore/cloud_firestore.dart';

class AddConnection {
  static const String errorNoUser = 'error-no-user';
  static const String errorUserTaken = 'error-user-taken';

  static Future<String> addConnection(String userFrom, String userTo) async {
    // Check if the user_to exists
    QuerySnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .where('username', isEqualTo: userTo)
        .get();

    if (userSnapshot.docs.isEmpty) {
      // User_to not found
      return errorNoUser;
    }

    // Get user data for user_to
    String recieverUid = userSnapshot.docs.first.id;

    // Check if the other user's Connection status is connectionStates.connected
    // or connectionStates.pending_outgoing
    QuerySnapshot<Map<String, dynamic>> existingConnectionSnapshot =
        await FirebaseFirestore.instance
            .collection('connection-request')
            .doc(recieverUid)
            .collection('connections')
            .where('sentToUID', isEqualTo: recieverUid)
            .where('connectionStatus',
                whereIn: ['connected', 'pending_outgoing']).get();

    if (existingConnectionSnapshot.docs.isNotEmpty) {
      // User_to is already connected or has a pending outgoing request
      return errorUserTaken;
    }

    // No errors, update Firestore collection
    await FirebaseFirestore.instance
        .collection('connection-request')
        .doc(userFrom)
        .update({
      'timestamp': null,
      'sentByUID': userFrom,
      'sentToUID': recieverUid,
      'connectionStatus': 'pending_outgoing',
    });

    // Return success
    return 'success';
  }
}
