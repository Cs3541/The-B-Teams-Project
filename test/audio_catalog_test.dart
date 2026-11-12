import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_b_teams_project/models/audio_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Every catalog sound is bundled as a valid 20-second PCM audio asset',
    () async {
      for (final audio in sleepAudioCatalog) {
        expect(audio.hasSource, isTrue);
        final data = await rootBundle.load(audio.source!);
        final bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );

        expect(ascii.decode(bytes.sublist(0, 4)), 'RIFF');
        expect(ascii.decode(bytes.sublist(8, 12)), 'WAVE');
        expect(data.getUint16(20, Endian.little), 1);
        expect(data.getUint16(22, Endian.little), 1);
        expect(data.getUint32(24, Endian.little), 22050);
        expect(data.getUint16(34, Endian.little), 16);
        expect(data.getUint32(40, Endian.little), 20 * 22050 * 2);
      }
    },
  );
}
