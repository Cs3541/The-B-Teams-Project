import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/audio_model.dart';
import '../models/audio_catalog.dart';
import '../models/audio_playback_state.dart';
import '../models/audio_playback_model.dart';
import '../models/just_audio_playback_model.dart';

class AudioPresenter extends ChangeNotifier {
  final AudioPlaybackModel _playback;
  StreamSubscription<AudioPlaybackState>? _subscription;
  AudioPlaybackState _playbackState = const AudioPlaybackState();
  Audio? _selectedAudio;
  Audio? _loadingAudio;
  double _volume = 0.5;
  String? _errorMessage;
  bool _loading = false;
  bool _disposed = false;
  final List<Audio> _audios;

  AudioPresenter({AudioPlaybackModel? playback, Iterable<Audio>? catalog})
    : _playback = playback ?? JustAudioPlaybackModel(),
      _audios = List.of(catalog ?? sleepAudioCatalog);

  List<Audio> get audios => List.unmodifiable(_audios);
  AudioPlaybackState get playbackState => _playbackState;
  Audio? get selectedAudio => _selectedAudio;
  Audio? get loadingAudio => _loadingAudio;
  double get volume => _volume;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _loading;
  bool get isPlaying => _playbackState.status == AudioPlaybackStatus.playing;

  Future<void> prepareAudio(Audio audio) async {
    if (_disposed) throw StateError('Audio presenter has been disposed.');
    if (!audio.hasSource) throw ArgumentError('Audio has no playable source.');
    if (_loading) return;
    _subscription ??= _playback.states.listen((state) {
      if (_disposed) return;
      final changed =
          _playbackState.status != state.status ||
          _playbackState.duration != state.duration ||
          _playbackState.error != state.error;
      _playbackState = state.copyWith(volume: _volume);
      if (state.status == AudioPlaybackStatus.error) {
        _errorMessage = 'Could not play this sound. Tap a sound to try again.';
      }
      if (changed) notifyListeners();
    }, onError: _reportError);
    _loading = true;
    _loadingAudio = audio;
    _errorMessage = null;
    _selectedAudio = null;
    _playbackState = const AudioPlaybackState(
      status: AudioPlaybackStatus.loading,
    );
    notifyListeners();
    try {
      await _playback.load(audio);
    } catch (error) {
      _reportError(error);
      rethrow;
    } finally {
      _loading = false;
      _loadingAudio = null;
      if (!_disposed) notifyListeners();
    }
    if (_disposed) return;
    _selectedAudio = audio;
    notifyListeners();
  }

  Future<void> toggleAudio(Audio audio) async {
    if (_disposed || _loading) return;
    try {
      if (_selectedAudio == audio && isPlaying) {
        await pauseAudio();
        return;
      }
      if (_selectedAudio != audio ||
          _playbackState.status == AudioPlaybackStatus.error) {
        await prepareAudio(audio);
      }
      if (_disposed || _selectedAudio != audio) return;
      await _playback.setVolume(_volume);
      if (_disposed || _selectedAudio != audio) return;
      _errorMessage = null;
      _playbackState = AudioPlaybackState(
        status: AudioPlaybackStatus.playing,
        position: _playbackState.position,
        duration: _playbackState.duration,
        volume: _volume,
      );
      notifyListeners();
      unawaited(_playback.play().catchError(_reportError));
    } catch (error) {
      _reportError(error);
    }
  }

  Future<void> pauseAudio() async {
    if (_disposed || _loading || _selectedAudio == null) return;
    try {
      await _playback.pause();
      if (_disposed) return;
      _playbackState = AudioPlaybackState(
        status: AudioPlaybackStatus.paused,
        position: _playbackState.position,
        duration: _playbackState.duration,
        volume: _volume,
      );
      notifyListeners();
    } catch (error) {
      _reportError(error);
    }
  }

  Future<void> stopAudio() async {
    if (_disposed || _loading) return;
    try {
      await _playback.stop();
      if (_disposed) return;
      _selectedAudio = null;
      _errorMessage = null;
      _playbackState = AudioPlaybackState(volume: _volume);
      notifyListeners();
    } catch (error) {
      _reportError(error);
    }
  }

  Future<void> setVolume(double volume) async {
    if (!volume.isFinite || volume < 0 || volume > 1) {
      throw ArgumentError.value(volume, 'volume');
    }
    if (_disposed) return;
    final previousVolume = _volume;
    _volume = volume;
    _playbackState = _playbackState.copyWith(volume: volume);
    notifyListeners();
    if (_selectedAudio == null) return;
    try {
      await _playback.setVolume(volume);
    } catch (error) {
      if (_volume == volume) _volume = previousVolume;
      _reportError(error);
    }
  }

  void _reportError(Object error) {
    if (_disposed) return;
    _errorMessage = 'Could not play this sound. Tap a sound to try again.';
    _playbackState = AudioPlaybackState(
      status: AudioPlaybackStatus.error,
      volume: _volume,
      error: error.toString(),
    );
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
