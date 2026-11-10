import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:the_b_teams_project/models/audio_model.dart';
import 'package:the_b_teams_project/models/audio_playback_state.dart';
import 'package:the_b_teams_project/presenters/audio_presenter.dart';
import 'package:the_b_teams_project/services/audio_playback_service.dart';
import 'package:the_b_teams_project/services/just_audio_playback_service.dart';

void main() {
  test('Metadata entries remain valid without a playable source', () {
    final playback = FakeAudioPlaybackService();
    final presenter = AudioPresenter(playback: playback);
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
    final playback = FakeAudioPlaybackService();
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
    final playback = FakeAudioPlaybackService();
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
    final playback = FakeAudioPlaybackService()..failLoad = true;
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

  test('Presenter disposal releases its playback service', () async {
    final playback = FakeAudioPlaybackService();
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
    final playback = JustAudioPlaybackService();

    await expectLater(playback.load(Audio(name: 'Rain')), throwsArgumentError);
    for (final volume in [-0.1, 1.1, double.nan, double.infinity]) {
      await expectLater(playback.setVolume(volume), throwsArgumentError);
    }

    await playback.dispose();
    await playback.dispose();
  });
}

class FakeAudioPlaybackService implements AudioPlaybackService {
  final controller = StreamController<AudioPlaybackState>.broadcast();
  Audio? loadedAudio;
  bool failLoad = false;
  bool disposed = false;

  @override
  Stream<AudioPlaybackState> get states => controller.stream;

  @override
  Future<void> load(Audio audio) async {
    if (failLoad) throw StateError('Audio could not be loaded.');
    loadedAudio = audio;
  }

  @override
  Future<void> play() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> dispose() async {
    disposed = true;
    await controller.close();
  }
}
