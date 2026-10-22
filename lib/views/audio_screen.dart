import 'package:flutter/material.dart';
import '../presenters/audio_presenter.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final AudioPresenter presenter = AudioPresenter();

  void _showAddCourseDialog() {
    String name = '';
    String? description;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('add Audio'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Audio name'),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Description (optional)'),
                onChanged: (value) => description = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), //Cancel button
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (name.trim().isNotEmpty) {
                  setState(() {
                    presenter.addAudio(name.trim(), description?.trim());
                  });
                  Navigator.pop(context); //Close dialog
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final audios = presenter.audios;

    return Scaffold(
      appBar: AppBar(title: const Text('Audio Tab')),
      body: ListView.builder(
        itemCount: audios.length,
        itemBuilder: (context, index) {
          final audio = audios[index];
          return ListTile(
            title: Text(audio.name),
            subtitle: audio.description != null ? Text(audio.description!) : null,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCourseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}