import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_b_teams_project/presenters/audio_presenter.dart';
import 'package:the_b_teams_project/views/audio_screen.dart';

import 'audio_presenter_test.dart' show FakeAudioPlaybackModel;

void main() {
  testWidgets(
    'Sound controls and volume slider operate through the presenter',
    (tester) async {
      final playback = FakeAudioPlaybackModel();
      final presenter = AudioPresenter(playback: playback);
      addTearDown(presenter.dispose);
      await tester.pumpWidget(
        MaterialApp(home: AudioListScreen(presenter: presenter)),
      );

      expect(find.text('Brown noise'), findsOneWidget);
      expect(find.text('Soft rain'), findsOneWidget);
      expect(find.text('Ocean waves'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);

      await tester.tap(find.byTooltip('Play Brown noise'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Pause Brown noise'), findsOneWidget);
      expect(playback.playCalls, 1);

      final slider = find.byType(Slider);
      await tester.drag(slider, const Offset(-80, 0));
      await tester.pumpAndSettle();
      expect(presenter.volume, lessThan(0.5));
      expect(playback.volume, presenter.volume);

      await tester.tap(find.byTooltip('Pause audio'));
      await tester.pumpAndSettle();
      expect(playback.pauseCalls, 1);
      await tester.tap(find.byTooltip('Resume audio'));
      await tester.pumpAndSettle();
      expect(playback.playCalls, 2);

      await tester.tap(find.byTooltip('Play Ocean waves'));
      await tester.pumpAndSettle();
      expect(playback.loadedAudio!.name, 'Ocean waves');
      await tester.tap(find.byTooltip('Stop audio'));
      await tester.pumpAndSettle();
      expect(find.text('Choose a sound to begin'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('A failed sound shows an error and leaves the controls usable', (
    tester,
  ) async {
    final playback = FakeAudioPlaybackModel()..failLoad = true;
    final presenter = AudioPresenter(playback: playback);
    addTearDown(presenter.dispose);
    await tester.pumpWidget(
      MaterialApp(home: AudioListScreen(presenter: presenter)),
    );

    await tester.tap(find.byTooltip('Play Soft rain'));
    await tester.pumpAndSettle();
    expect(
      find.text('Could not play this sound. Tap a sound to try again.'),
      findsOneWidget,
    );
    playback.failLoad = false;
    await tester.tap(find.byTooltip('Play Soft rain'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Pause Soft rain'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
