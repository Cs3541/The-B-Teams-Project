import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/audio_model.dart';
import '../models/audio_catalog.dart';
import '../models/audio_playback_state.dart';
import '../models/audio_playback_model.dart';
import '../models/just_audio_playback_model.dart';
import '../models/audio_library_model.dart';
import '../models/audio_listening_record.dart';

class AudioPresenter extends ChangeNotifier {
  final AudioPlaybackModel _playback;
  final AudioLibraryModel _library;
  final Stopwatch _listeningClock;
  final DateTime Function() _now;
  final List<Audio> _catalog;
  final Set<String> _favorites = {};
  final List<AudioListeningRecord> _listening = [];
  Future<void> _saveQueue = Future.value();
  Timer? _checkpoint;
  Audio? _trackingAudio;
  DateTime? _trackingStart;
  int _checkpointTicks = 0;
  int _revision = 0;
  int _savedRevision = 0;
  bool _initialized = false;
  bool _libraryLoading = false;
  bool _libraryBusy = false;
  String? _libraryMessage;
  String _query = '';
  AudioLibrarySection _section = AudioLibrarySection.catalog;
  StreamSubscription<AudioPlaybackState>? _subscription;
  AudioPlaybackState _playbackState = const AudioPlaybackState();
  Audio? _selectedAudio;
  Audio? _loadingAudio;
  double _volume = 0.5;
  String? _errorMessage;
  bool _loading = false;
  bool _disposed = false;
  final List<Audio> _audios;

  AudioPresenter({
    AudioPlaybackModel? playback,
    Iterable<Audio>? catalog,
    AudioLibraryModel? library,
    Stopwatch? listeningClock,
    DateTime Function()? now,
  }) : _playback = playback ?? JustAudioPlaybackModel(),
       _library = library ?? AudioLibraryModel(),
       _listeningClock = listeningClock ?? Stopwatch(),
       _now = now ?? DateTime.now,
       _catalog = List.of(catalog ?? sleepAudioCatalog),
       _audios = List.of(catalog ?? sleepAudioCatalog);

  List<Audio> get audios => List.unmodifiable(_audios);
  AudioPlaybackState get playbackState => _playbackState;
  Audio? get selectedAudio => _selectedAudio;
  Audio? get loadingAudio => _loadingAudio;
  double get volume => _volume;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _loading;
  bool get isPlaying => _playbackState.status == AudioPlaybackStatus.playing;
  bool get isLibraryLoading => _libraryLoading;
  bool get isLibraryBusy => _libraryBusy;
  bool get libraryReady => _initialized;
  String? get libraryMessage => _libraryMessage;
  AudioLibrarySection get section => _section;

  bool isFavorite(Audio audio) => _favorites.contains(audio.id);

  List<Audio> get visibleAudios => _audios.where((audio) {
    if (_section == AudioLibrarySection.favorites && !isFavorite(audio)) {
      return false;
    }
    if (_section == AudioLibrarySection.imports &&
        audio.sourceType != AudioSourceType.file) {
      return false;
    }
    return '${audio.name} ${audio.description ?? ''}'.toLowerCase().contains(
      _query,
    );
  }).toList();

  List<AudioListeningRecord> get listeningHistory {
    final records = _listening
        .where((record) => record.audioName.toLowerCase().contains(_query))
        .toList();
    records.sort((a, b) => b.day.compareTo(a.day));
    return records;
  }

  Duration get totalListening => Duration(
    milliseconds: _listening.fold(
      0,
      (total, record) => total + record.milliseconds,
    ),
  );

  Duration get todayListening {
    final now = _now();
    return Duration(
      milliseconds: _listening
          .where(
            (record) =>
                record.day.year == now.year &&
                record.day.month == now.month &&
                record.day.day == now.day,
          )
          .fold(0, (total, record) => total + record.milliseconds),
    );
  }

  Duration listeningFor(Audio audio) => Duration(
    milliseconds: _listening
        .where((record) => record.audioId == audio.id)
        .fold(0, (total, record) => total + record.milliseconds),
  );

  static String formatListening(Duration duration) {
    final seconds = duration.inSeconds % 60;
    final minutes = duration.inMinutes % 60;
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${minutes}m ${seconds}s';
    }
    if (duration.inMinutes > 0) return '${duration.inMinutes}m ${seconds}s';
    return '${seconds}s';
  }

  void setQuery(String query) {
    _query = query.trim().toLowerCase();
    notifyListeners();
  }

  void setSection(AudioLibrarySection section) {
    _section = section;
    notifyListeners();
  }

  Future<void> initialize() async {
    if (_disposed || _initialized || _libraryLoading) return;
    _libraryLoading = true;
    notifyListeners();
    try {
      final data = await _library.load();
      if (_disposed) return;
      _audios
        ..clear()
        ..addAll(_catalog)
        ..addAll(data.imports);
      _favorites
        ..clear()
        ..addAll(data.favorites);
      _listening
        ..clear()
        ..addAll(data.listening);
      _volume = data.volume;
      _initialized = true;
      _libraryMessage = null;
      _checkpoint = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_listeningClock.isRunning) {
          _collectListening();
          notifyListeners();
        }
        if (++_checkpointTicks % 5 == 0) unawaited(flush());
      });
    } catch (_) {
      _libraryMessage = 'Could not load your saved audio library. Retry to keep your saved data.';
    } finally {
      _libraryLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> _saveLibrary() {
    if (!_initialized) return Future.value();
    final revision = _revision;
    final snapshot = AudioLibraryData(
      imports: _audios.where(
        (audio) => audio.sourceType == AudioSourceType.file,
      ),
      favorites: _favorites,
      listening: _listening,
      volume: _volume,
    );
    final save = _saveQueue.catchError((Object _) {}).then((_) async {
      await _library.save(snapshot);
      _savedRevision = revision;
    });
    _saveQueue = save;
    return save;
  }

  Future<void> flush() async {
    _collectListening();
    if (_libraryBusy || !_initialized || _revision == _savedRevision) return;
    try {
      await _saveLibrary();
    } catch (_) {
      _libraryMessage =
          'Could not save audio changes. Tap Retry to save them again.';
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> retryLibrary() async {
    if (!_initialized) {
      await initialize();
    } else {
      try {
        await _saveLibrary();
        _libraryMessage = null;
      } catch (_) {
        _libraryMessage = 'Could not save audio changes. Please try again.';
      }
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> toggleFavorite(Audio audio) async {
    if (!_initialized || _libraryBusy || _disposed) return;
    if (!_favorites.remove(audio.id)) _favorites.add(audio.id);
    _revision++;
    notifyListeners();
    await flush();
  }

  Future<bool> importAudio() async {
    if (!_initialized || _libraryBusy || _disposed) return false;
    _libraryBusy = true;
    _libraryMessage = null;
    notifyListeners();
    Audio? imported;
    try {
      imported = await _library.pickAudio();
      if (imported == null) return false;
      if (_disposed) {
        await _library.removeImportedFile(imported);
        return false;
      }
      _audios.add(imported);
      _revision++;
      try {
        await _saveLibrary();
      } catch (_) {
        _audios.remove(imported);
        await _library.removeImportedFile(imported);
        rethrow;
      }
      return true;
    } catch (error) {
      _libraryMessage = error is FormatException || error is UnsupportedError
          ? error.toString().replaceFirst(
              RegExp(r'^(FormatException|Unsupported operation): '),
              '',
            )
          : 'Could not import this MP3. Check that the file is available and try again.';
      return false;
    } finally {
      _libraryBusy = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> removeImportedAudio(Audio audio) async {
    if (!_initialized ||
        _libraryBusy ||
        _loading ||
        _disposed ||
        audio.sourceType != AudioSourceType.file) {
      return;
    }
    _libraryBusy = true;
    notifyListeners();
    try {
      if (_selectedAudio == audio) await stopAudio();
      if (_selectedAudio == audio) {
        throw StateError('Could not stop the selected audio.');
      }
      final index = _audios.indexOf(audio);
      if (index < 0) return;
      final favorite = _favorites.remove(audio.id);
      _audios.removeAt(index);
      _revision++;
      try {
        await _saveLibrary();
      } catch (_) {
        _audios.insert(index, audio);
        if (favorite) _favorites.add(audio.id);
        rethrow;
      }
      await _library.removeImportedFile(audio);
    } catch (_) {
      _libraryMessage =
          'Could not completely remove this audio. Please try again.';
    } finally {
      _libraryBusy = false;
      if (!_disposed) notifyListeners();
    }
  }

  void _syncListening(bool playing) {
    if (!playing || _trackingAudio != _selectedAudio) {
      _collectListening();
      _listeningClock
        ..stop()
        ..reset();
      _trackingAudio = null;
      _trackingStart = null;
    }
    if (playing && _selectedAudio != null && _trackingAudio == null) {
      _trackingAudio = _selectedAudio;
      final now = _now();
      _trackingStart = DateTime.fromMillisecondsSinceEpoch(
        now.millisecondsSinceEpoch,
        isUtc: now.isUtc,
      );
      _listeningClock.start();
    }
  }

  void _collectListening() {
    final audio = _trackingAudio;
    final start = _trackingStart;
    if (audio == null || start == null) return;
    DateTime cursor = start;
    var remaining = _listeningClock.elapsedMilliseconds;
    if (remaining == 0) return;
    _revision++;
    while (remaining > 0) {
      final day = DateTime(cursor.year, cursor.month, cursor.day);
      final nextDay = DateTime(cursor.year, cursor.month, cursor.day + 1);
      final chunk = remaining < nextDay.difference(cursor).inMilliseconds
          ? remaining
          : nextDay.difference(cursor).inMilliseconds;
      final index = _listening.indexWhere(
        (record) => record.audioId == audio.id && record.day == day,
      );
      final previous = index < 0 ? 0 : _listening[index].milliseconds;
      final record = AudioListeningRecord(
        audioId: audio.id,
        audioName: audio.name,
        day: day,
        milliseconds: previous + chunk,
      );
      if (index < 0) {
        _listening.add(record);
      } else {
        _listening[index] = record;
      }
      cursor = cursor.add(Duration(milliseconds: chunk));
      remaining -= chunk;
    }
    _trackingStart = cursor;
    _listeningClock.reset();
  }

  Future<void> prepareAudio(Audio audio) async {
    if (_disposed) throw StateError('Audio presenter has been disposed.');
    if (!audio.hasSource) throw ArgumentError('Audio has no playable source.');
    if (_loading) return;
    _subscription ??= _playback.states.listen((state) {
      if (_disposed) return;
      _syncListening(state.status == AudioPlaybackStatus.playing);
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
    _syncListening(false);
    unawaited(flush());
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
      _syncListening(false);
      unawaited(flush());
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
      _syncListening(false);
      unawaited(flush());
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
    _revision++;
    _playbackState = _playbackState.copyWith(volume: volume);
    notifyListeners();
    if (_selectedAudio == null) {
      unawaited(flush());
      return;
    }
    try {
      await _playback.setVolume(volume);
      unawaited(flush());
    } catch (error) {
      if (_volume == volume) _volume = previousVolume;
      _reportError(error);
    }
  }

  void _reportError(Object error) {
    if (_disposed) return;
    _syncListening(false);
    unawaited(flush());
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
    _syncListening(false);
    _checkpoint?.cancel();
    unawaited(flush());
    _disposed = true;
    unawaited(_subscription?.cancel());
    unawaited(_playback.dispose());
    super.dispose();
  }
}
