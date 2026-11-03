import '../models/audio_model.dart';

class AudioPresenter {
  final List<Audio> _audios = [];

  List<Audio> get audios => List.unmodifiable(_audios);

  void addAudio(String name, String? description) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return;
    final trimmedDescription = description?.trim();
    _audios.add(
      Audio(
        name: trimmedName,
        description: trimmedDescription == null || trimmedDescription.isEmpty
            ? null
            : trimmedDescription,
      ),
    );
  }

  void removeAudio(Audio audio) => _audios.remove(audio);
}
