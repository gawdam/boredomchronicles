import 'package:boredomapp/models/user_history.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;
  static const String tableName = 'boredom_data';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'boredom_data.db');
    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE $tableName(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          dateTime TEXT,
          value INTEGER
        )
      ''');
    });
  }

  Future<int> insertBoredomData(userHistory data) async {
    final db = await database;
    return db.insert(tableName, data.toMap());
  }

  Future<List<userHistory>> getBoredomDataForDate(DateTime date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'date = ?',
      whereArgs: [_formatDate(date)],
    );

    return List.generate(maps.length, (i) {
      return userHistory(
        id: maps[i]['id'],
        dateTime: DateTime.parse(maps[i]['date']),
        value: maps[i]['value'],
      );
    });
  }

  // Function to format the date to 'yyyy-MM-dd'
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
