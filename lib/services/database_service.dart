import 'package:boredomapp/models/user_history.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;
  static const String tableName = 'user_history';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'user_history.db');
    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE $tableName(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp TEXT,
          value INTEGER
        )
      ''');
    });
  }

  Future<int> insertBoredomData(UserHistory data) async {
    final db = await database;
    return db.insert(tableName, data.toMap());
  }

  Future<List<UserHistory>> getBoredomDataForDateAndHour(
      DateTime date, int hour) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'timestamp LIKE ?',
      whereArgs: ['${_formatDate(date)} $hour%'],
    );

    return List.generate(maps.length, (i) {
      return UserHistory(
        uid: maps[i]['id'],
        timestamp: DateTime.parse(maps[i]['timestamp']),
        value: maps[i]['value'],
      );
    });
  }

  // Function to format the date to 'yyyy-MM-dd'
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
