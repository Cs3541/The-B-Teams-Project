import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SleepClockTime {
  final int hour;
  final int minute;

  SleepClockTime(this.hour, this.minute) {
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw ArgumentError('Invalid clock time.');
    }
  }

  int get minutes => hour * 60 + minute;

  Map<String, int> toJson() => {'hour': hour, 'minute': minute};

  factory SleepClockTime.fromJson(Map<String, dynamic> json) =>
      SleepClockTime(json['hour'] as int, json['minute'] as int);
}

class DailySleepSchedule {
  final int weekday;
  final SleepClockTime bedtime;
  final SleepClockTime wakeTime;

  DailySleepSchedule({
    required this.weekday,
    required this.bedtime,
    required this.wakeTime,
  }) {
    if (weekday < DateTime.monday || weekday > DateTime.sunday) {
      throw ArgumentError.value(weekday, 'weekday');
    }
    if (bedtime.minutes == wakeTime.minutes) {
      throw ArgumentError('Bedtime and wake time must be different.');
    }
  }

  bool get wakesNextDay => wakeTime.minutes < bedtime.minutes;

  Map<String, dynamic> toJson() => {
    'weekday': weekday,
    'bedtime': bedtime.toJson(),
    'wakeTime': wakeTime.toJson(),
  };

  factory DailySleepSchedule.fromJson(Map<String, dynamic> json) =>
      DailySleepSchedule(
        weekday: json['weekday'] as int,
        bedtime: SleepClockTime.fromJson(
          Map<String, dynamic>.from(json['bedtime'] as Map),
        ),
        wakeTime: SleepClockTime.fromJson(
          Map<String, dynamic>.from(json['wakeTime'] as Map),
        ),
      );
}

class SleepSchedulePreferences {
  final List<DailySleepSchedule> days;
  final int? weeklyGoalMinutes;
  final bool bedtimeReminders;
  final bool wakeAlarms;
  final bool weeklyRecaps;
  final bool weeklyGoalReviews;
  final int recapWeekday;
  final SleepClockTime recapTime;

  SleepSchedulePreferences({
    Iterable<DailySleepSchedule> days = const [],
    this.weeklyGoalMinutes,
    this.bedtimeReminders = false,
    this.wakeAlarms = false,
    this.weeklyRecaps = false,
    this.weeklyGoalReviews = false,
    this.recapWeekday = DateTime.monday,
    SleepClockTime? recapTime,
  }) : days = List.unmodifiable(days),
       recapTime = recapTime ?? SleepClockTime(9, 0) {
    if (this.days.map((day) => day.weekday).toSet().length !=
        this.days.length) {
      throw ArgumentError('Each weekday can have only one sleep schedule.');
    }
    if (recapWeekday < DateTime.monday || recapWeekday > DateTime.sunday) {
      throw ArgumentError.value(recapWeekday, 'recapWeekday');
    }
    if (weeklyGoalMinutes != null &&
        (weeklyGoalMinutes! <= 0 || weeklyGoalMinutes! > 7 * 24 * 60)) {
      throw ArgumentError.value(weeklyGoalMinutes, 'weeklyGoalMinutes');
    }
  }

  Map<String, dynamic> toJson() => {
    'days': days.map((day) => day.toJson()).toList(),
    'weeklyGoalMinutes': weeklyGoalMinutes,
    'bedtimeReminders': bedtimeReminders,
    'wakeAlarms': wakeAlarms,
    'weeklyRecaps': weeklyRecaps,
    'weeklyGoalReviews': weeklyGoalReviews,
    'recapWeekday': recapWeekday,
    'recapTime': recapTime.toJson(),
  };

  factory SleepSchedulePreferences.fromJson(Map<String, dynamic> json) =>
      SleepSchedulePreferences(
        days: (json['days'] as List).map(
          (day) => DailySleepSchedule.fromJson(
            Map<String, dynamic>.from(day as Map),
          ),
        ),
        weeklyGoalMinutes: json['weeklyGoalMinutes'] as int?,
        bedtimeReminders: json['bedtimeReminders'] as bool,
        wakeAlarms: json['wakeAlarms'] as bool,
        weeklyRecaps: json['weeklyRecaps'] as bool,
        weeklyGoalReviews: json['weeklyGoalReviews'] as bool,
        recapWeekday: json['recapWeekday'] as int,
        recapTime: SleepClockTime.fromJson(
          Map<String, dynamic>.from(json['recapTime'] as Map),
        ),
      );
}

class SleepScheduleModel {
  static const _storageKey = 'sleep_schedule_preferences_v1';

  Future<SleepSchedulePreferences> load() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_storageKey);
    if (saved == null) return SleepSchedulePreferences();
    return SleepSchedulePreferences.fromJson(
      Map<String, dynamic>.from(jsonDecode(saved) as Map),
    );
  }

  Future<void> save(SleepSchedulePreferences settings) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(settings.toJson()),
    );
    if (!saved) throw StateError('Could not save the sleep schedule.');
  }
}
