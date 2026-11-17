class AudioListeningRecord {
  final String audioId;
  final String audioName;
  final DateTime day;
  final int milliseconds;

  const AudioListeningRecord({
    required this.audioId,
    required this.audioName,
    required this.day,
    required this.milliseconds,
  });

  Map<String, dynamic> toJson() => {
    'audioId': audioId,
    'audioName': audioName,
    'day':
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}',
    'milliseconds': milliseconds,
  };

  factory AudioListeningRecord.fromJson(Map<String, dynamic> json) {
    final day = DateTime.parse(json['day'] as String);
    final milliseconds = json['milliseconds'] as int;
    if (milliseconds < 0) {
      throw const FormatException('Invalid listening time.');
    }
    return AudioListeningRecord(
      audioId: json['audioId'] as String,
      audioName: json['audioName'] as String,
      day: DateTime(day.year, day.month, day.day),
      milliseconds: milliseconds,
    );
  }
}
