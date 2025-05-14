// lib/services/history_service.dart
import 'dart:convert';
import 'package:pomo_app/models/session_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static const String _historyKey = 'pomodoro_history';

  Future<void> addSession(SessionModel session) async {
    final prefs = await SharedPreferences.getInstance();
    final List<SessionModel> sessions = await getSessions();

    // Add new session to the beginning of the list
    sessions.insert(0, session);

    // Convert list of SessionModel objects to list of JSON strings
    final List<String> sessionsJson = sessions.map((s) => jsonEncode(s.toJson())).toList();

    await prefs.setStringList(_historyKey, sessionsJson);
  }

  Future<List<SessionModel>> getSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? sessionsJson = prefs.getStringList(_historyKey);

    if (sessionsJson == null) {
      return [];
    }

    // Convert list of JSON strings back to list of SessionModel objects
    return sessionsJson.map((s) => SessionModel.fromJson(jsonDecode(s) as Map<String, dynamic>)).toList();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}