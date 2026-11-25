
enum DreamMood {
  good,
  bad,
}

class SleepLog {
  final String id;
  final DateTime bedtime;
  final DateTime wakeUpTime;

  final int? sleepQuality;
  final int? restedRating;

  // Dream journal fields
  final String? dreamDescription;
  final DreamMood? dreamMood;

  const SleepLog({
    required this.id,
    required this.bedtime,
    required this.wakeUpTime,
    this.sleepQuality,
    this.restedRating,
    this.dreamDescription,
    this.dreamMood,
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
      'dreamDescription': dreamDescription,
      'dreamMood': dreamMood?.name,
    };
  }

  factory SleepLog.fromJson(Map<String, dynamic> json) {
    final moodValue = json['dreamMood'] as String?;

    DreamMood? parsedMood;

    for (final mood in DreamMood.values) {
      if (mood.name == moodValue) {
        parsedMood = mood;
        break;
      }
    }

    return SleepLog(
      id: json['id'] as String,
      bedtime: DateTime.parse(json['bedtime'] as String),
      wakeUpTime: DateTime.parse(json['wakeUpTime'] as String),
      sleepQuality: (json['sleepQuality'] as num?)?.toInt(),
      restedRating: (json['restedRating'] as num?)?.toInt(),
      dreamDescription: json['dreamDescription'] as String?,
      dreamMood: parsedMood,
    );
  }
}
