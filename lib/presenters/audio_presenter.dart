import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/audio_model.dart';
import '../models/audio_playback_state.dart';
import '../models/audio_playback_model.dart';
import '../models/just_audio_playback_model.dart';

class AudioPresenter extends ChangeNotifier {
  final AudioPlaybackModel _playback;
  StreamSubscription<AudioPlaybackState>? _subscription;
  AudioPlaybackState _playbackState = const AudioPlaybackState();
  Audio? _selectedAudio;
  bool _disposed = false;
  final List<Audio> _audios = [];

  AudioPresenter({AudioPlaybackModel? playback})
      : _playback = playback ?? JustAudioPlaybackModel();

  List<Audio> get audios => List.unmodifiable(_audios);
  AudioPlaybackState get playbackState => _playbackState;
  Audio? get selectedAudio => _selectedAudio;

  Future<void> prepareAudio(Audio audio) async {
    if (_disposed) throw StateError('Audio presenter has been disposed.');
    if (!audio.hasSource) throw ArgumentError('Audio has no playable source.');
    _subscription ??= _playback.states.listen((state) {
      if (_disposed) return;
      _playbackState = state;
      notifyListeners();
    });
    _selectedAudio = null;
    _playbackState = const AudioPlaybackState(status: AudioPlaybackStatus.loading);
    notifyListeners();
    try {
      await _playback.load(audio);
    } catch (error) {
      if (!_disposed) {
        _playbackState = AudioPlaybackState(
          status: AudioPlaybackStatus.error,
          error: error.toString(),
        );
        notifyListeners();
      }
      rethrow;
    }
    if (_disposed) return;
    _selectedAudio = audio;
    notifyListeners();
  }

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
    notifyListeners();
  }

  void removeAudio(Audio audio) {
    _audios.remove(audio);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_subscription?.cancel());
    unawaited(_playback.dispose());
    super.dispose();
  }
}
