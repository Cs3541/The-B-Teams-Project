import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sleep_log_model.dart';

class SleepLogPresenter {
  static const String _storageKey = 'sleep_logs';

  Future<List<SleepLog>> loadLogs() async {
    final preferences = await SharedPreferences.getInstance();
    final storedData = preferences.getString(_storageKey);

    if (storedData == null || storedData.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(storedData) as List<dynamic>;

      final logs = decoded.map((item) {
        return SleepLog.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
      }).toList();

      logs.sort((a, b) => b.bedtime.compareTo(a.bedtime));
      return logs;
    } catch (_) {
      throw Exception(
        'Could not read saved sleep logs. '
        'Your stored data was not overwritten.',
      );
    }
  }

  Future<void> saveLog(SleepLog log) async {
    final preferences = await SharedPreferences.getInstance();
    final logs = await loadLogs();

    logs.removeWhere((existing) => existing.id == log.id);
    logs.add(log);
    logs.sort((a, b) => b.bedtime.compareTo(a.bedtime));

    final encoded = jsonEncode(
      logs.map((item) => item.toJson()).toList(),
    );

    final saved = await preferences.setString(_storageKey, encoded);

    if (!saved) {
      throw Exception('Could not save the sleep log.');
    }
  }

  Future<void> deleteLog(String id) async {
    final preferences = await SharedPreferences.getInstance();
    final logs = await loadLogs();

    logs.removeWhere((log) => log.id == id);

    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(logs.map((log) => log.toJson()).toList()),
    );

    if (!saved) {
      throw Exception('Could not delete the sleep log.');
    }
  }
}
