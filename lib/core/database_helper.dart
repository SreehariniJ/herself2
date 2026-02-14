import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database?> _initDatabase() async {
    if (kIsWeb) return null;
    try {
      String path = join(await getDatabasesPath(), 'herself_users.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    } catch (e) {
      debugPrint("Error initializing database: $e");
      return null;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        created_at TEXT
      )
    ''');
  }

  // --- User Operations ---

  Future<int> insertUser(String name, String email, String password) async {
    final db = await database;
    if (db == null) return -1;
    
    try {
      return await db.insert('users', {
        'name': name,
        'email': email,
        'password': password,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('User with this email already exists');
    }
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await database;
    if (db == null) return null;

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    if (db == null) return null;

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<int> deleteUser(String email) async {
    final db = await database;
    if (db == null) return 0;

    return await db.delete(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    if (db == null) return [];
    return await db.query('users', orderBy: 'id DESC');
  }
}
