import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:get/get.dart';
import 'package:uni_manager/models/assignment.dart';
import 'package:uni_manager/controllers/notification_controller.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // Notification channel IDs
  static const _assignmentChannelId = 'assignment_reminders';
  static const _dailyChannelId = 'daily_summary';

  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    // Request permissions (Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  // ── Schedule all reminders for an assignment ─────────────────────────────

  static Future<void> scheduleAssignmentReminders(
      Assignment assignment) async {
    await init();

    final ctrl = Get.find<NotificationController>();
    if (!ctrl.remindersEnabled.value) return;

    final due = assignment.dueDate;
    final title = assignment.title;
    final course = assignment.courseName;

    // 1 day before
    final oneDayBefore = due.subtract(const Duration(days: 1));
    if (oneDayBefore.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: _idFor(assignment.id, 0),
        title: '📚 Due Tomorrow',
        body: '$title — $course',
        scheduledDate: oneDayBefore,
        channelId: _assignmentChannelId,
        channelName: 'Assignment Reminders',
      );
    }

    // 3 hours before
    final threeHoursBefore = due.subtract(const Duration(hours: 3));
    if (threeHoursBefore.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: _idFor(assignment.id, 1),
        title: '⏰ Due in 3 Hours',
        body: '$title — $course',
        scheduledDate: threeHoursBefore,
        channelId: _assignmentChannelId,
        channelName: 'Assignment Reminders',
      );
    }

    // 1 hour before
    final oneHourBefore = due.subtract(const Duration(hours: 1));
    if (oneHourBefore.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: _idFor(assignment.id, 2),
        title: '🔴 Due in 1 Hour',
        body: '$title — $course',
        scheduledDate: oneHourBefore,
        channelId: _assignmentChannelId,
        channelName: 'Assignment Reminders',
      );
    }
  }

  // ── Cancel all reminders for an assignment ───────────────────────────────

  static Future<void> cancelAssignmentReminders(int assignmentId) async {
    await _plugin.cancel(_idFor(assignmentId, 0));
    await _plugin.cancel(_idFor(assignmentId, 1));
    await _plugin.cancel(_idFor(assignmentId, 2));
  }

  // ── Schedule daily morning summary ───────────────────────────────────────

  static Future<void> scheduleDailySummary() async {
    await init();

    final ctrl = Get.find<NotificationController>();
    if (!ctrl.dailySummaryEnabled.value) return;

    await _plugin.cancel(999); // cancel existing

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 8, 0, 0);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      999,
      '🌅 Good Morning!',
      'Check your assignments due today.',
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _dailyChannelId,
          'Daily Summary',
          channelDescription: 'Daily morning summary of due assignments',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // repeats daily
    );
  }

  static Future<void> cancelDailySummary() async {
    await _plugin.cancel(999);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String channelId,
    required String channelName,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: 'Reminders for upcoming assignments',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Generates unique notification IDs per assignment per reminder type
  /// type: 0 = 1 day, 1 = 3 hours, 2 = 1 hour
  static int _idFor(int assignmentId, int type) {
    return (assignmentId * 10 + type) % 2147483647;
  }
}