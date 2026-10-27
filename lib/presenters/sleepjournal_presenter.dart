import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/sleepjournal_model.dart';

class SleepJournalPresenter {
  final List<sleepJournal> _journals = [];

  List<sleepJournal> get journals => _journals;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/journal.txt');
  }

  List<sleepJournal> searchJournals(String query){
    if(query.toString().isEmpty){
      return _journals;
    }
    return _journals.where((journals){
      return journals.journalDate.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  void _deleteJournals(int index){
    _journals.removeWhere((journals) => _journals.contains(journals),);
  }

  Future<File> addJournal(String date) async{
    final file = await _localFile;
    return file.writeAsString('$journals');
  }

  Future<String> readJournal() async{
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File journal = File('$directory/journal.text');
      return await journal.readAsString();
    } catch (e) {
     return 'Error reading journal: $e'; 
    }
  }
}