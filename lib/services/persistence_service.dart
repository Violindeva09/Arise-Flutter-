import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_stats.dart';

class PersistenceService {
  static const String _keyPrefix = "arise_v1_"; // Updated prefix for versioning
  static const int SCHEMA_VERSION = 1;

  static Future<void> savePlayerStats(
      String playerName, PlayerStats stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'version': SCHEMA_VERSION,
        'stats': stats.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      final jsonString = jsonEncode(data);
      await prefs.setString("$_keyPrefix${playerName}_stats", jsonString);
    } catch (e) {
      // ignore: avoid_print
      print("ERROR: Persistence failure: $e");
    }
  }

  static Future<PlayerStats?> loadPlayerStats(String playerName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString("$_keyPrefix${playerName}_stats");

      if (jsonString != null) {
        final Map<String, dynamic> data = jsonDecode(jsonString);
        final int version = data['version'] ?? 0;

        if (version == SCHEMA_VERSION) {
          return PlayerStats.fromJson(data['stats']);
        } else {
          // Handle migration logic here in future
          return _handleMigration(version, data['stats']);
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print("ERROR: Load failure, using fallback: $e");
    }
    return null; // Triggers default stats in Provider
  }

  static PlayerStats? _handleMigration(
      int oldVersion, Map<String, dynamic> data) {
    // Migration logic placeholder
    return PlayerStats.fromJson(data);
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
