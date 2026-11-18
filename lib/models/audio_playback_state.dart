enum AudioPlaybackStatus {
  idle,
  loading,
  ready,
  playing,
  paused,
  completed,
  error,
}

class AudioPlaybackState {
  final AudioPlaybackStatus status;
  final Duration position;
  final Duration? duration;
  final double volume;
  final String? error;

  const AudioPlaybackState({
    this.status = AudioPlaybackStatus.idle,
    this.position = Duration.zero,
    this.duration,
    this.volume = 1,
    this.error,
  });
}
