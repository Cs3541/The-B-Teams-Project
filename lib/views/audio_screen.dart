import 'package:flutter/material.dart';

import '../presenters/audio_presenter.dart';

class AudioListScreen extends StatefulWidget {
  const AudioListScreen({super.key});

  @override
  State<AudioListScreen> createState() => _AudioListScreenState();
}

class _AudioListScreenState extends State<AudioListScreen> {
  final AudioPresenter _presenter = AudioPresenter();

  Future<void> _showAddAudioDialog() async {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String? description;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Audio'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Audio name'),
                  onChanged: (value) => name = value,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter an audio name'
                      : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                  onChanged: (value) => description = value,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              setState(() => _presenter.addAudio(name, description));
              Navigator.pop(dialogContext);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audios = _presenter.audios;
    return Scaffold(
      appBar: AppBar(title: const Text('Audio')),
      body: audios.isEmpty
          ? const Center(child: Text('No audio entries yet. Tap + to add one.'))
          : ListView.builder(
              itemCount: audios.length,
              itemBuilder: (context, index) {
                final audio = audios[index];
                return ListTile(
                  leading: const Icon(Icons.music_note),
                  title: Text(audio.name),
                  subtitle: audio.description == null
                      ? null
                      : Text(audio.description!),
                  trailing: IconButton(
                    tooltip: 'Delete audio',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () =>
                        setState(() => _presenter.removeAudio(audio)),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addAudio',
        tooltip: 'Add audio',
        onPressed: _showAddAudioDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
