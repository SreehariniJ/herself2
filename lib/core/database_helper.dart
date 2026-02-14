import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// A simple multi-user database built on SharedPreferences.
/// Works on all platforms (mobile, web, desktop) without native dependencies.
/// Stores users as a JSON-encoded list under a single key.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  final String _usersKey = 'db_users_list';
  SharedPreferences? _prefs;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  /// Initialize with a SharedPreferences instance
  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
  }

  /// Get all stored users
  List<Map<String, dynamic>> _getUsers() {
    final jsonStr = _prefs?.getString(_usersKey);
    if (jsonStr == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  /// Save users list back to storage
  Future<void> _saveUsers(List<Map<String, dynamic>> users) async {
    await _prefs?.setString(_usersKey, jsonEncode(users));
  }

  /// Insert a new user (signup)
  Future<int> insertUser(String name, String email, String password) async {
    final users = _getUsers();

    // Check for duplicate email
    final exists = users.any((u) => u['email'] == email);
    if (exists) {
      throw Exception('User with this email already exists');
    }

    final newId = (users.isEmpty) ? 1 : (users.last['id'] as int) + 1;
    users.add({
      'id': newId,
      'name': name,
      'email': email,
      'password': password,
      'created_at': DateTime.now().toIso8601String(),
    });

    await _saveUsers(users);
    return newId;
  }

  /// Get user by email and password (login)
  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final users = _getUsers();
    try {
      return users.firstWhere(
        (u) => u['email'] == email && u['password'] == password,
      );
    } catch (_) {
      return null;
    }
  }

  /// Check if a user with this email already exists
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final users = _getUsers();
    try {
      return users.firstWhere((u) => u['email'] == email);
    } catch (_) {
      return null;
    }
  }

  /// Delete a user account
  Future<int> deleteUser(String email) async {
    final users = _getUsers();
    final initialLength = users.length;
    users.removeWhere((u) => u['email'] == email);
    await _saveUsers(users);
    return initialLength - users.length;
  }
}
