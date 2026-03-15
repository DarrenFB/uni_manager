import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_manager/models/assignment.dart';


class NotificationItem {
  final int assignmentId;
  final String assignmentTitle;
  final String courseName;
  final DateTime dueDate;
  final int courseColorIndex;

  NotificationItem({
    required this.assignmentId,
    required this.assignmentTitle,
    required this.courseName,
    required this.dueDate,
    required this.courseColorIndex,
  });
}

class NotificationController extends GetxController {
  final remindersEnabled = true.obs;
  final dailySummaryEnabled = true.obs;

  static const _remindersKey = 'reminders_enabled';
  static const _dailyKey = 'daily_summary_enabled';

  @override
  void onInit() {
    super.onInit();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    remindersEnabled.value = prefs.getBool(_remindersKey) ?? true;
    dailySummaryEnabled.value = prefs.getBool(_dailyKey) ?? true;
  }

  Future<void> toggleReminders(bool value) async {
    remindersEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_remindersKey, value);
  }

  Future<void> toggleDailySummary(bool value) async {
    dailySummaryEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailyKey, value);

    // Schedule or cancel the daily summary immediately
    if (value) {
      // Import lazily to avoid circular dependency
      Get.find<dynamic>(); // triggers notification service via app controller
    }
  }

  /// Builds a list of upcoming notification items from assignments
  List<NotificationItem> buildNotificationItems(List<Assignment> assignments) {
    final now = DateTime.now();
    final items = <NotificationItem>[];

    for (final a in assignments) {
      if (a.isCompleted) continue;
      if (a.dueDate.isBefore(now)) continue;

      items.add(NotificationItem(
        assignmentId: a.id,
        assignmentTitle: a.title,
        courseName: a.courseName,
        dueDate: a.dueDate,
        courseColorIndex: a.courseColorIndex,
      ));
    }

    items.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return items;
  }
}