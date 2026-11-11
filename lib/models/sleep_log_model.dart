class SleepLog {
  final String id;
  final DateTime bedtime;
  final DateTime wakeUpTime;

  // Nullable so older Firebase records without ratings still load.
  final int? sleepQuality;
  final int? restedRating;

  const SleepLog({
    required this.id,
    required this.bedtime,
    required this.wakeUpTime,
    this.sleepQuality,
    this.restedRating,
  });

  Duration get duration => wakeUpTime.difference(bedtime);

  String get formattedDuration {
    final totalMinutes = duration.inMinutes;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '$hours hr $minutes min';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bedtime': bedtime.toIso8601String(),
      'wakeUpTime': wakeUpTime.toIso8601String(),
      'sleepQuality': sleepQuality,
      'restedRating': restedRating,
    };
  }

  factory SleepLog.fromJson(Map<String, dynamic> json) {
    return SleepLog(
      id: json['id'] as String,
      bedtime: DateTime.parse(json['bedtime'] as String),
      wakeUpTime: DateTime.parse(json['wakeUpTime'] as String),
      sleepQuality: (json['sleepQuality'] as num?)?.toInt(),
      restedRating: (json['restedRating'] as num?)?.toInt(),
    );
  }
}