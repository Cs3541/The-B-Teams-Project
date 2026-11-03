
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/sleep_log_model.dart';

/// Stores each signed-in user's sleep logs in Firebase Realtime Database.
///
/// Database path: users/{userId}/sleepLogs/{logId}
class SleepLogPresenter {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> _getUserId() async {
    User? user = _auth.currentUser;

    // Sign in anonymously if no user is signed in.
    if (user == null) {
      final credential = await _auth.signInAnonymously();
      user = credential.user;
    }

    if (user == null) {
      throw Exception('Could not sign in to Firebase.');
    }

    return user.uid;
  }

  DatabaseReference _logsReference(String userId) {
    return _database.ref('users/$userId/sleepLogs');
  }

  // Load all sleep logs belonging to the current user.
  Future<List<SleepLog>> loadLogs() async {
    final userId = await _getUserId();
    final snapshot = await _logsReference(userId).get();

    if (!snapshot.exists || snapshot.value == null) {
      return [];
    }

    final value = snapshot.value;

    if (value is! Map) {
      throw const FormatException(
        'Sleep logs in Firebase have an unexpected format.',
      );
    }

    final logs = <SleepLog>[];

    for (final entry in value.entries) {
      final logId = entry.key.toString();
      final rawLog = entry.value;

      if (rawLog is! Map) continue;

      final data = Map<String, dynamic>.from(
        rawLog.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      );

      // Use the Firebase database key as the log ID.
      data['id'] = logId;

      logs.add(SleepLog.fromJson(data));
    }

    // Show newest sleep logs first.
    logs.sort(
      (a, b) => b.bedtime.compareTo(a.bedtime),
    );

    return logs;
  }

  // Save a sleep log to Firebase.
  Future<void> saveLog(SleepLog log) async {
    final userId = await _getUserId();

    await _logsReference(userId)
        .child(log.id)
        .set(log.toJson());
  }

  // Delete a sleep log from Firebase.
  Future<void> deleteLog(String id) async {
    final userId = await _getUserId();

    await _logsReference(userId)
        .child(id)
        .remove();
  }
}
