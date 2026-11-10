import '../models/audio_model.dart';
import '../models/audio_playback_state.dart';

abstract class AudioPlaybackService {
  Stream<AudioPlaybackState> get states;

  Future<void> load(Audio audio);
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> setVolume(double volume);
  Future<void> dispose();
}
