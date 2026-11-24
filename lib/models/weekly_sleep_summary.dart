import 'sleep_log_model.dart';

enum WeeklySleepGoalStatus { notSet, inProgress, met, missed }

class WeeklySleepSummary {
  final DateTime weekStart;
  final DateTime weekEnd;
  final Duration totalSleep;
  final int logCount;
  final int? goalMinutes;
  final WeeklySleepGoalStatus goalStatus;

  const WeeklySleepSummary._({
    required this.weekStart,
    required this.weekEnd,
    required this.totalSleep,
    required this.logCount,
    required this.goalMinutes,
    required this.goalStatus,
  });

  double get averageMinutesPerDay => totalSleep.inMilliseconds / 60000 / 7;

  double? get goalProgress => goalMinutes == null
      ? null
      : (totalSleep.inMilliseconds / (goalMinutes! * 60000)).clamp(0.0, 1.0);

  Duration? get remainingToGoal {
    if (goalMinutes == null) return null;
    final remaining = Duration(minutes: goalMinutes!) - totalSleep;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  factory WeeklySleepSummary.calculate({
    required Iterable<SleepLog> logs,
    required DateTime weekStart,
    required DateTime now,
    int? goalMinutes,
  }) {
    if (goalMinutes != null &&
        (goalMinutes <= 0 || goalMinutes > 7 * 24 * 60)) {
      throw ArgumentError.value(goalMinutes, 'goalMinutes');
    }
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final end = DateTime(start.year, start.month, start.day + 7);
    final intervals = <({DateTime start, DateTime end})>[];
    for (final log in logs) {
      if (!log.wakeUpTime.isAfter(log.bedtime) ||
          !log.wakeUpTime.isAfter(start) ||
          !log.bedtime.isBefore(end) ||
          !log.bedtime.isBefore(now)) {
        continue;
      }
      final intervalStart = log.bedtime.isBefore(start) ? start : log.bedtime;
      var intervalEnd = log.wakeUpTime.isAfter(end) ? end : log.wakeUpTime;
      if (intervalEnd.isAfter(now)) intervalEnd = now;
      if (intervalEnd.isAfter(intervalStart)) {
        intervals.add((start: intervalStart, end: intervalEnd));
      }
    }
    intervals.sort((a, b) => a.start.compareTo(b.start));
    var total = Duration.zero;
    DateTime? previousEnd;
    for (final interval in intervals) {
      final countedStart =
          previousEnd != null && previousEnd.isAfter(interval.start)
          ? previousEnd
          : interval.start;
      if (interval.end.isAfter(countedStart)) {
        total += interval.end.difference(countedStart);
      }
      if (previousEnd == null || interval.end.isAfter(previousEnd)) {
        previousEnd = interval.end;
      }
    }
    final status = goalMinutes == null
        ? WeeklySleepGoalStatus.notSet
        : total >= Duration(minutes: goalMinutes)
        ? WeeklySleepGoalStatus.met
        : now.isBefore(end)
        ? WeeklySleepGoalStatus.inProgress
        : WeeklySleepGoalStatus.missed;
    return WeeklySleepSummary._(
      weekStart: start,
      weekEnd: end,
      totalSleep: total,
      logCount: intervals.length,
      goalMinutes: goalMinutes,
      goalStatus: status,
    );
  }
}
