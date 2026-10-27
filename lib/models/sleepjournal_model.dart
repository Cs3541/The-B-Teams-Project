import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';


class sleepJournal {

  File userJournal;
  final String userName;
  String journalDate;

  sleepJournal({
    required this.userJournal,
    required this.userName,
    required this.journalDate,
  });

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    //Create a reference to the file's full location
    final path = await _localPath;
    return File('$path/journal.txt');
  }

  Future<File> writeJournal(String content) async {
    final file = await _localFile;
    // Write the contents of the journal to the file
    return file.writeAsString(content);
  }

  Future<String> readJournal() async {
    try {
      final file = await _localFile;
      // Read contents of the journal file
      final contents = await file.readAsString();
      return contents;

    } catch (e) {
      //If an errror occcurs, return a message
      return 'Error reading journal: $e';
    }
  }


}