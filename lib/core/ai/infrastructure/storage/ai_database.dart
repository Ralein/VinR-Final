import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight, fast, on-device structured storage engine for AI entities.
class AiDatabase {
  static final AiDatabase instance = AiDatabase._internal();
  AiDatabase._internal();

  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> setJson(String key, dynamic value) async {
    final prefs = await _getPrefs();
    await prefs.setString(key, jsonEncode(value));
  }

  Future<dynamic> getJson(String key) async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> remove(String key) async {
    final prefs = await _getPrefs();
    await prefs.remove(key);
  }

  Future<List<String>> getKeysStartingWith(String prefix) async {
    final prefs = await _getPrefs();
    return prefs.getKeys().where((k) => k.startsWith(prefix)).toList();
  }

  Future<void> clearNamespace(String prefix) async {
    final prefs = await _getPrefs();
    final keys = prefs.getKeys().where((k) => k.startsWith(prefix)).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}
