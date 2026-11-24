enum SleepNotificationKind {
  bedtimeReminder,
  wakeAlarm,
  weeklyRecap,
  weeklyGoalReview,
}

class SleepNotificationPlan {
  final int id;
  final SleepNotificationKind kind;
  final DateTime scheduledFor;

  const SleepNotificationPlan({
    required this.id,
    required this.kind,
    required this.scheduledFor,
  });
}
