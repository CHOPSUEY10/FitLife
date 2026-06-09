import 'package:flutter/services.dart';

class EnvHelper {
  static final Map<String, String> _env = {};

  /// Loads the .env file from the assets bundle and parses its variables.
  static Future<void> load() async {
    try {
      final content = await rootBundle.loadString('.env');
      final lines = content.split('\n');
      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty || line.startsWith('#')) continue;
        
        final parts = line.split('=');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final value = parts.sublist(1).join('=').trim();
          _env[key] = value;
        }
      }
    } catch (e) {
      // Catch file not found or load errors silently or print in debug
      print('Warning: Failed to load .env file: $e');
    }
  }

  /// Retrieves a value from the env map.
  static String get(String key, {String defaultValue = ''}) {
    return _env[key] ?? defaultValue;
  }
}
