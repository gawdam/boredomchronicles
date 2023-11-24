class userHistory {
  final int id; // Primary key
  final DateTime dateTime;
  final int value;

  userHistory({required this.id, required this.dateTime, required this.value});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': dateTime.toIso8601String(), // Store DateTime as a string
      'value': value,
    };
  }

  factory userHistory.fromMap(Map<String, dynamic> map) {
    return userHistory(
      id: map['id'],
      dateTime: DateTime.parse(map['date']),
      value: map['value'],
    );
  }
}
