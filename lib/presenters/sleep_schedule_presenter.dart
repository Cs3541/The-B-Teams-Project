import 'package:flutter/foundation.dart';

import '../models/sleep_log_model.dart';
import '../models/sleep_notification_plan.dart';
import '../models/sleep_schedule_model.dart';
import '../models/weekly_sleep_summary.dart';

class SleepSchedulePresenter extends ChangeNotifier {
  final SleepScheduleModel _model;
  SleepSchedulePreferences _settings = SleepSchedulePreferences();
  bool _busy = false;
  bool _loaded = false;
  bool _disposed = false;
  String? _error;

  SleepSchedulePresenter({SleepScheduleModel? model})
    : _model = model ?? SleepScheduleModel();

  SleepSchedulePreferences get settings => _settings;
  bool get isBusy => _busy;
  bool get isLoaded => _loaded;
  String? get error => _error;

  Future<void> load() async {
    if (_busy || _disposed) return;
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      final settings = await _model.load();
      if (!_disposed) {
        _settings = settings;
        _loaded = true;
      }
    } catch (_) {
      _error = 'Could not load the saved sleep schedule.';
    } finally {
      _busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<bool> save(SleepSchedulePreferences settings) async {
    if (_busy || !_loaded || _disposed) return false;
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await _model.save(settings);
      if (!_disposed) _settings = settings;
      return true;
    } catch (_) {
      _error = 'Could not save the sleep schedule.';
      return false;
    } finally {
      _busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  List<SleepNotificationPlan> nextNotificationPlans({DateTime? from}) {
    if (!_loaded) return const [];
    final now = from ?? DateTime.now();
    final plans = <SleepNotificationPlan>[];
    DateTime upcoming(int weekday, SleepClockTime time, {int dayOffset = 0}) {
      final delta = (weekday - now.weekday + 7) % 7 - 7 + dayOffset;
      var date = DateTime(
        now.year,
        now.month,
        now.day + delta,
        time.hour,
        time.minute,
      );
      while (!date.isAfter(now)) {
        date = DateTime(
          date.year,
          date.month,
          date.day + 7,
          time.hour,
          time.minute,
        );
      }
      return date;
    }

    for (final day in _settings.days) {
      if (_settings.bedtimeReminders) {
        plans.add(
          SleepNotificationPlan(
            id: 4200 + day.weekday * 10,
            kind: SleepNotificationKind.bedtimeReminder,
            scheduledFor: upcoming(day.weekday, day.bedtime),
          ),
        );
      }
      if (_settings.wakeAlarms) {
        plans.add(
          SleepNotificationPlan(
            id: 4201 + day.weekday * 10,
            kind: SleepNotificationKind.wakeAlarm,
            scheduledFor: upcoming(
              day.weekday,
              day.wakeTime,
              dayOffset: day.wakesNextDay ? 1 : 0,
            ),
          ),
        );
      }
    }
    final recapDate = upcoming(_settings.recapWeekday, _settings.recapTime);
    if (_settings.weeklyRecaps) {
      plans.add(
        SleepNotificationPlan(
          id: 4300,
          kind: SleepNotificationKind.weeklyRecap,
          scheduledFor: recapDate,
        ),
      );
    }
    if (_settings.weeklyGoalReviews && _settings.weeklyGoalMinutes != null) {
      plans.add(
        SleepNotificationPlan(
          id: 4301,
          kind: SleepNotificationKind.weeklyGoalReview,
          scheduledFor: recapDate,
        ),
      );
    }
    plans.sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));
    return List.unmodifiable(plans);
  }

  WeeklySleepSummary weeklySummary({
    required Iterable<SleepLog> logs,
    required DateTime weekStart,
    DateTime? now,
  }) => WeeklySleepSummary.calculate(
    logs: logs,
    weekStart: weekStart,
    now: now ?? DateTime.now(),
    goalMinutes: _settings.weeklyGoalMinutes,
  );

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
