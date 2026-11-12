import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:the_b_teams_project/models/audio_model.dart';
import 'package:the_b_teams_project/models/audio_playback_state.dart';
import 'package:the_b_teams_project/presenters/audio_presenter.dart';
import 'package:the_b_teams_project/models/audio_playback_model.dart';
import 'package:the_b_teams_project/models/just_audio_playback_model.dart';

void main() {
  test('Metadata entries remain valid without a playable source', () {
    final playback = FakeAudioPlaybackModel();
    final presenter = AudioPresenter(playback: playback, catalog: const []);
    addTearDown(presenter.dispose);

    presenter.addAudio('  Rain  ', '  Gentle rain  ');
    presenter.addAudio(' ', null);

    expect(presenter.audios.single.name, 'Rain');
    expect(presenter.audios.single.description, 'Gentle rain');
    expect(presenter.audios.single.hasSource, isFalse);
    expect(presenter.playbackState.status, AudioPlaybackStatus.idle);
    expect(playback.loadedAudio, isNull);
  });

  test('An entry without a source is rejected before loading', () async {
    final playback = FakeAudioPlaybackModel();
    final presenter = AudioPresenter(playback: playback);
    addTearDown(presenter.dispose);

    await expectLater(
      presenter.prepareAudio(Audio(name: 'Rain')),
      throwsArgumentError,
    );

    expect(playback.loadedAudio, isNull);
    expect(presenter.selectedAudio, isNull);
    expect(presenter.playbackState.status, AudioPlaybackStatus.idle);
  });

  test('Preparing a source forwards playback state to the presenter', () async {
    final playback = FakeAudioPlaybackModel();
    final presenter = AudioPresenter(playback: playback);
    addTearDown(presenter.dispose);
    final audio = Audio(
      name: 'Rain',
      source: 'assets/audio/rain.mp3',
      sourceType: AudioSourceType.asset,
    );

    await presenter.prepareAudio(audio);
    playback.controller.add(
      const AudioPlaybackState(
        status: AudioPlaybackStatus.playing,
        position: Duration(seconds: 8),
        duration: Duration(minutes: 2),
        volume: 0.5,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(playback.loadedAudio, same(audio));
    expect(presenter.selectedAudio, same(audio));
    expect(presenter.playbackState.status, AudioPlaybackStatus.playing);
    expect(presenter.playbackState.position, const Duration(seconds: 8));
    expect(presenter.playbackState.volume, 0.5);
  });

  test('A failed load does not select an unplayable entry', () async {
    final playback = FakeAudioPlaybackModel()..failLoad = true;
    final presenter = AudioPresenter(playback: playback);
    addTearDown(presenter.dispose);

    await expectLater(
      presenter.prepareAudio(
        Audio(
          name: 'Rain',
          source: 'https://example.com/rain.mp3',
          sourceType: AudioSourceType.stream,
        ),
      ),
      throwsStateError,
    );

    expect(presenter.selectedAudio, isNull);
    expect(presenter.playbackState.status, AudioPlaybackStatus.error);
  });

  test('Presenter disposal releases its playback model', () async {
    final playback = FakeAudioPlaybackModel();
    final presenter = AudioPresenter(playback: playback);

    presenter.dispose();
    await Future<void>.delayed(Duration.zero);

    expect(playback.disposed, isTrue);
    await expectLater(
      presenter.prepareAudio(Audio(name: 'Rain')),
      throwsStateError,
    );
  });

  test('Native adapter validates input without starting a player', () async {
    final playback = JustAudioPlaybackModel();

    await expectLater(playback.load(Audio(name: 'Rain')), throwsArgumentError);
    for (final volume in [-0.1, 1.1, double.nan, double.infinity]) {
      await expectLater(playback.setVolume(volume), throwsArgumentError);
    }

    await playback.dispose();
    await playback.dispose();
  });

  test(
    'Catalog playback pauses, resumes without reloading, and stops',
    () async {
      final playback = FakeAudioPlaybackModel();
      final presenter = AudioPresenter(playback: playback);
      addTearDown(presenter.dispose);
      final sound = presenter.audios.first;

      await presenter.toggleAudio(sound);
      expect(presenter.selectedAudio, same(sound));
      expect(presenter.isPlaying, isTrue);
      expect(playback.playCalls, 1);
      expect(playback.loadCalls, 1);

      await presenter.toggleAudio(sound);
      expect(presenter.playbackState.status, AudioPlaybackStatus.paused);
      expect(playback.pauseCalls, 1);

      await presenter.toggleAudio(sound);
      expect(presenter.isPlaying, isTrue);
      expect(playback.playCalls, 2);
      expect(playback.loadCalls, 1);

      await presenter.stopAudio();
      expect(presenter.selectedAudio, isNull);
      expect(presenter.playbackState.status, AudioPlaybackStatus.idle);
      expect(playback.stopCalls, 1);
    },
  );

  test(
    'Volume can be set before playback and remains when changing sounds',
    () async {
      final playback = FakeAudioPlaybackModel();
      final presenter = AudioPresenter(playback: playback);
      addTearDown(presenter.dispose);

      await presenter.setVolume(0.25);
      expect(playback.volume, isNull);
      await presenter.toggleAudio(presenter.audios.first);
      expect(playback.volume, 0.25);
      await presenter.setVolume(0);
      expect(playback.volume, 0);
      await presenter.toggleAudio(presenter.audios.last);
      expect(playback.loadedAudio, same(presenter.audios.last));
      expect(playback.volume, 0);
      expect(presenter.volume, 0);
      expect(playback.loadCalls, 2);

      await expectLater(presenter.setVolume(1.1), throwsArgumentError);
      await expectLater(presenter.setVolume(double.nan), throwsArgumentError);
    },
  );

  test('Loading errors are displayed and another sound can be tried', () async {
    final playback = FakeAudioPlaybackModel()..failLoad = true;
    final presenter = AudioPresenter(playback: playback);
    addTearDown(presenter.dispose);

    await presenter.toggleAudio(presenter.audios.first);
    expect(presenter.errorMessage, isNotNull);
    expect(presenter.isLoading, isFalse);
    expect(presenter.selectedAudio, isNull);
    expect(playback.playCalls, 0);

    playback.failLoad = false;
    await presenter.toggleAudio(presenter.audios.last);
    expect(presenter.errorMessage, isNull);
    expect(presenter.isPlaying, isTrue);
  });

  test(
    'Repeated selections during loading do not start multiple sounds',
    () async {
      final playback = FakeAudioPlaybackModel()..loadGate = Completer<void>();
      final presenter = AudioPresenter(playback: playback);
      addTearDown(presenter.dispose);

      final first = presenter.toggleAudio(presenter.audios.first);
      expect(presenter.isLoading, isTrue);
      await presenter.toggleAudio(presenter.audios.last);
      expect(playback.loadCalls, 1);
      playback.loadGate!.complete();
      await first;
      expect(playback.playCalls, 1);
      expect(presenter.selectedAudio, same(presenter.audios.first));
    },
  );

  test(
    'A delayed play failure is reported instead of escaping to the UI',
    () async {
      final playback = FakeAudioPlaybackModel()..failPlay = true;
      final presenter = AudioPresenter(playback: playback);
      addTearDown(presenter.dispose);

      await presenter.toggleAudio(presenter.audios.first);
      await Future<void>.delayed(Duration.zero);
      expect(presenter.playbackState.status, AudioPlaybackStatus.error);
      expect(presenter.errorMessage, isNotNull);
    },
  );
}

class FakeAudioPlaybackModel implements AudioPlaybackModel {
  final controller = StreamController<AudioPlaybackState>.broadcast();
  Audio? loadedAudio;
  bool failLoad = false;
  bool disposed = false;
  bool failPlay = false;
  int loadCalls = 0;
  int playCalls = 0;
  int pauseCalls = 0;
  int stopCalls = 0;
  double? volume;
  Completer<void>? loadGate;

  @override
  Stream<AudioPlaybackState> get states => controller.stream;

  @override
  Future<void> load(Audio audio) async {
    loadCalls++;
    await loadGate?.future;
    if (failLoad) throw StateError('Audio could not be loaded.');
    loadedAudio = audio;
  }

  @override
  Future<void> play() async {
    playCalls++;
    if (failPlay) throw StateError('Playback failed.');
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
  }

  @override
  Future<void> stop() async {
    stopCalls++;
  }

  @override
  Future<void> setVolume(double volume) async {
    this.volume = volume;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    await controller.close();
  }
}
