import '../models/audio_model.dart';

class AudioPresenter {
  final List<Audio> _audios = [];

  List<Audio> get audios => _audios;

  void addAudio(String name, String? description) {
    _audios.add(Audio(name: name, description: description));
  }
}