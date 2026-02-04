/// Central place for notification IDs so we can cancel by event.
///
/// Each event uses a base ID; reminders use baseId, baseId+1, etc.
class NotificationIds {
  NotificationIds._();

  /// Max ID per event for reminders (e.g. 1 day, 1 hour).
  static const int reminderSlotsPerEvent = 4;

  /// Base ID for event reminders. Event id hash is combined with this.
  static const int eventReminderBase = 10000;

  /// ID for one-off FCM/status notifications (foreground display).
  static const int fcmForegroundId = 99999;

  /// Compute a stable notification id for an event reminder slot.
  /// [eventId] – event id string; [slot] – 0 = 1 day, 1 = 1 hour, etc.
  static int eventReminderId(String eventId, int slot) {
    final hash = eventId.hashCode.abs() % 100000;
    return eventReminderBase + hash + slot;
  }
}
