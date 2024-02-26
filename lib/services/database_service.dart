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
          uid STRING,
          timestamp STRING,
          value FLOAT
        )
      ''');
    });
  }

  Future<int> insertBoredomData(UserHistory data) async {
    final db = await database;
    await db.rawQuery(
        "DELETE from $tableName where julianday(current_date)-julianday(timestamp)>365");
    return db.insert(tableName, data.toMap());
  }

  Future<double> getBoredomHistoryData(int timeframe) async {
    final db = await database;
    final value = await db.rawQuery(
        "SELECT sum(value)/count(*) as value from $tableName where julianday(current_date)-julianday(timestamp)<$timeframe");
    print(value.first['value']);
    List<Map<String, dynamic>> maps = await db.rawQuery(
        "SELECT sum(value)/count(*) as value from $tableName where julianday(current_date)-julianday(timestamp)<$timeframe ");
    // "SELECT sum(value)/count(*) as value from $tableName where julianday(current_date)-julianday(timestamp)<$timeframe ");
    return maps.first['value'].toDouble();
  }
}
