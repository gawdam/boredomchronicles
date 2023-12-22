enum connectionStates {
  connected,
  not_connected,
  pending_incoming,
  pending_outgoing
}

class UserData {
  final String uid;
  final String username;
  final String avatar;
  final double boredomValue;
  final String imagePath;
  final Enum? connectionState;
  final String? connectedToUsername;

  UserData({
    required this.uid,
    required this.username,
    required this.boredomValue,
    required this.avatar,
    required this.imagePath,
    this.connectionState = connectionStates.not_connected,
    this.connectedToUsername,
  });
}
