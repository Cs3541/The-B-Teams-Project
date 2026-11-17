import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audio_model.dart';
import 'audio_listening_record.dart';

class AudioLibraryData {
  final List<Audio> imports;
  final Set<String> favorites;
  final List<AudioListeningRecord> listening;
  final double volume;

  AudioLibraryData({
    Iterable<Audio> imports = const [],
    Iterable<String> favorites = const [],
    Iterable<AudioListeningRecord> listening = const [],
    this.volume = 0.5,
  }) : imports = List.unmodifiable(imports),
       favorites = Set.unmodifiable(favorites),
       listening = List.unmodifiable(listening);
}

class AudioLibraryModel {
  static const _key = 'sleep_audio_library_v1';
  final Future<SharedPreferences> Function() _preferences;
  final Future<Directory> Function() _directory;

  AudioLibraryModel({
    Future<SharedPreferences> Function()? preferences,
    Future<Directory> Function()? directory,
  }) : _preferences = preferences ?? SharedPreferences.getInstance,
       _directory = directory ?? getApplicationDocumentsDirectory;

  Future<AudioLibraryData> load() async {
    final preferences = await _preferences();
    final saved = preferences.getString(_key);
    if (saved == null) return AudioLibraryData();
    final json = jsonDecode(saved) as Map<String, dynamic>;
    final imports = (json['imports'] as List)
        .map((value) => Audio.fromJson(Map<String, dynamic>.from(value as Map)))
        .toList();
    final volume = (json['volume'] as num).toDouble();
    if (!volume.isFinite ||
        volume < 0 ||
        volume > 1 ||
        imports.any(
          (audio) =>
              audio.sourceType != AudioSourceType.file || !audio.hasSource,
        )) {
      throw const FormatException('Invalid audio library.');
    }
    return AudioLibraryData(
      imports: imports,
      favorites: (json['favorites'] as List).cast<String>(),
      listening: (json['listening'] as List).map(
        (value) => AudioListeningRecord.fromJson(
          Map<String, dynamic>.from(value as Map),
        ),
      ),
      volume: volume,
    );
  }

  Future<void> save(AudioLibraryData data) async {
    final preferences = await _preferences();
    final saved = await preferences.setString(
      _key,
      jsonEncode({
        'imports': data.imports.map((audio) => audio.toJson()).toList(),
        'favorites': data.favorites.toList(),
        'listening': data.listening.map((record) => record.toJson()).toList(),
        'volume': data.volume,
      }),
    );
    if (!saved) throw StateError('Could not save the audio library.');
  }

  Future<Audio?> pickAudio() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Import MP3 files using the mobile or desktop app.',
      );
    }
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );
    if (file == null) return null;
    return importAudio(file.name, file.readAsByteStream());
  }

  Future<Directory> _audioDirectory() async {
    final root = await _directory();
    return Directory('${root.path}${Platform.pathSeparator}sleep_audio')
        .create(recursive: true);
  }

  Future<Audio> importAudio(String name, Stream<List<int>> bytes) async {
    if (!name.toLowerCase().endsWith('.mp3')) {
      throw const FormatException('Please select an MP3 file.');
    }
    final directory = await _audioDirectory();
    var suffix = 0;
    final stamp = DateTime.now().microsecondsSinceEpoch;
    File destination;
    do {
      destination = File(
        '${directory.path}${Platform.pathSeparator}${stamp}_${suffix++}.mp3',
      );
    } while (await destination.exists());
    try {
      final output = destination.openWrite();
      try {
        await output.addStream(bytes);
      } finally {
        await output.close();
      }
      final input = await destination.open();
      List<int> header;
      try {
        header = await input.read(3);
      } finally {
        await input.close();
      }
      final hasId3 =
          header.length == 3 &&
          header[0] == 73 &&
          header[1] == 68 &&
          header[2] == 51;
      final hasFrame =
          header.length >= 2 && header[0] == 255 && (header[1] & 224) == 224;
      if (!hasId3 && !hasFrame) {
        throw const FormatException('The selected file is not a valid MP3.');
      }
      final title = name.substring(0, name.length - 4).trim();
      return Audio(
        name: title.isEmpty ? 'Imported audio' : title,
        description: 'Imported MP3',
        source: destination.path,
        sourceType: AudioSourceType.file,
      );
    } catch (_) {
      if (await destination.exists()) await destination.delete();
      rethrow;
    }
  }

  Future<void> removeImportedFile(Audio audio) async {
    if (audio.sourceType != AudioSourceType.file ||
        audio.source == null ||
        kIsWeb) {
      return;
    }
    final directory = await _audioDirectory();
    final file = File(audio.source!).absolute;
    if (file.parent.path != directory.absolute.path) {
      throw StateError('The file is not an app-owned audio copy.');
    }
    if (await file.exists()) await file.delete();
  }
}
