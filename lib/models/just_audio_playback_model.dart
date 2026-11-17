import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import 'audio_model.dart';
import 'audio_playback_state.dart';
import 'audio_playback_model.dart';

class JustAudioPlaybackModel implements AudioPlaybackModel {
  final _states = StreamController<AudioPlaybackState>.broadcast();
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  AudioPlayer? _player;
  bool _disposed = false;
  bool _hasPlayed = false;

  @override
  Stream<AudioPlaybackState> get states => _states.stream;

  AudioPlayer get _activePlayer {
    if (_disposed) throw StateError('Audio player has been disposed.');
    if (_player == null) {
      final player = AudioPlayer();
      _player = player;
      _subscriptions.addAll([
        player.playerStateStream.listen((_) => _emitState()),
        player.positionStream.listen((_) => _emitState()),
        player.durationStream.listen((_) => _emitState()),
        player.volumeStream.listen((_) => _emitState()),
        player.errorStream.listen((error) => _emitState(error: error.message)),
      ]);
    }
    return _player!;
  }

  void _emitState({String? error}) {
    if (_disposed) return;
    final player = _player!;
    final status = error != null
        ? AudioPlaybackStatus.error
        : switch (player.processingState) {
            ProcessingState.idle => AudioPlaybackStatus.idle,
            ProcessingState.loading ||
            ProcessingState.buffering => AudioPlaybackStatus.loading,
            ProcessingState.completed => AudioPlaybackStatus.completed,
            ProcessingState.ready =>
              player.playing
                  ? AudioPlaybackStatus.playing
                  : _hasPlayed
                  ? AudioPlaybackStatus.paused
                  : AudioPlaybackStatus.ready,
          };
    _states.add(
      AudioPlaybackState(
        status: status,
        position: player.position,
        duration: player.duration,
        volume: player.volume,
        error: error,
      ),
    );
  }

  @override
  Future<void> load(Audio audio) async {
    if (!audio.hasSource) throw ArgumentError('Audio has no playable source.');
    final player = _activePlayer;
    _hasPlayed = false;
    await player.stop();
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    await player.setLoopMode(LoopMode.one);
    switch (audio.sourceType!) {
      case AudioSourceType.asset:
        await player.setAsset(audio.source!);
      case AudioSourceType.stream:
        final uri = Uri.tryParse(audio.source!);
        if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
          throw ArgumentError('Stream audio requires an HTTPS URL.');
        }
        await player.setUrl(uri.toString());
      case AudioSourceType.file:
        await player.setFilePath(audio.source!);
    }
  }

  @override
  Future<void> play() async {
    final player = _activePlayer;
    if (player.processingState == ProcessingState.completed) {
      await player.seek(Duration.zero);
    }
    _hasPlayed = true;
    await player.play();
  }

  @override
  Future<void> pause() async {
    await _player?.pause();
  }

  @override
  Future<void> stop() async {
    _hasPlayed = false;
    await _player?.stop();
  }

  @override
  Future<void> setVolume(double volume) async {
    if (!volume.isFinite || volume < 0 || volume > 1) {
      throw ArgumentError.value(volume, 'volume');
    }
    await _activePlayer.setVolume(volume);
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _player?.dispose();
    await _states.close();
  }
}
