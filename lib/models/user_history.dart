class UserHistory {
  final String uid; // Primary key
  final DateTime timestamp;
  final double value;

  UserHistory({
    required this.uid,
    required this.timestamp,
    required this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'timestamp': timestamp.toIso8601String(), // Store DateTime as a string
      'value': value,
    };
  }

  factory UserHistory.fromMap(Map<String, dynamic> map) {
    return UserHistory(
      uid: map['id'],
      timestamp: DateTime.parse(map['timestamp']),
      value: map['value'],
    );
  }
}
