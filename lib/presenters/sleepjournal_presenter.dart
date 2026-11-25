import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import '../models/sleepjournal_model.dart';

class SleepJournalPresenter {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final _auth = FirebaseAuth.instance;
  final List<SleepJournal> _journals = [];

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
    debugPrint('Current user id: ${user.uid}');
    return user.uid;
  }

  //Shortcut to get folder path of user's journals
  DatabaseReference _journalReference(String userId) {
    return _database.child('users/$userId/sleepJournals');
  }

  //Loads journals from Firebase
  Future<List<SleepJournal>> loadJournals() async {
    final userId = await _getUserId();
    debugPrint('LOADING JOURNALS FOR: $userId');
    final snapshot = await _journalReference(userId).get();
    debugPrint('Snapshot exists: ${snapshot.exists}');
    debugPrint('Snapshot value: ${snapshot.value}');

    _journals.clear();

    if (!snapshot.exists || snapshot.value == null) {
      return journals;
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);
      data.forEach((key, value){
        _journals.add(SleepJournal(
          title: value['title'],
          content: value['content'],
          journalDate: DateTime.fromMillisecondsSinceEpoch(value['journalDate']),
          id: key
          ),
        );
      });
    return journals;
  }

  //Sorts journals in UI
  List<SleepJournal> get journals {
    final sortedJournals = List<SleepJournal>.from(_journals);
    sortedJournals.sort(
      (a, b) => b.journalDate.compareTo(a.journalDate),
    );
    return sortedJournals;
  }

  Future<void> addJournal({ required String title, required String content}) async {
    final userId = await _getUserId();

    final newRef = _journalReference(userId).push();

    final journal = SleepJournal(
      title: title,
      content: content,
      journalDate: DateTime.now(),
      id: newRef.key!
    );

    await newRef.set({
      'title': title,
      'content': content,
      'journalDate': journal.journalDate.millisecondsSinceEpoch
    });
    _journals.add(journal);
  }

  Future<void> editJournal({
    required SleepJournal journal,
    required String newTitle,
    required String newContent,
    required DateTime originalDate,
  }) async {
    final userId = await _getUserId();

    final updatedJournal = SleepJournal(
        title: newTitle,
        content: newContent,
        journalDate: originalDate,
        id: journal.id,
      );

    await _journalReference(userId).child(journal.id).update({
      'title': newTitle,
      'content': newContent
    });

    final index = _journals.indexWhere(
      (entry) => entry.id == journal.id
      );
    if (index != -1) {
      _journals[index] = updatedJournal;
    }
  }

  List<SleepJournal> searchJournals(String query){
    if(query.toString().isEmpty){
      return journals;
    }
    final matchingJournals = _journals.where((journal) {
      return journal.title.toLowerCase().contains(query.toLowerCase()) ||
      journal.content.toLowerCase().contains(query.toLowerCase());
    }).toList();

    matchingJournals.sort(
      (a, b) => b.journalDate.compareTo(a.journalDate)
    );
    return matchingJournals;
  }

  Future<void> deleteJournals(SleepJournal journal) async {
    final userId = await _getUserId();
    await _journalReference(userId).child(journal.id).remove();

    _journals.removeWhere((entry) => entry.id == journal.id);
  }
}