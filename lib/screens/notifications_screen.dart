import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uni_manager/main.dart';
import 'package:uni_manager/controllers/app_controller.dart';
import 'package:uni_manager/controllers/notification_controller.dart';
import 'package:uni_manager/services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appCtrl = Get.find<AppController>();
    final notifCtrl = Get.find<NotificationController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: Obx(() {
                final items = notifCtrl
                    .buildNotificationItems(appCtrl.assignments);

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // ── Settings Section ──────────────────────────────────
                    _SectionLabel(label: 'Settings'),
                    const SizedBox(height: 10),

                    _SettingsCard(
                      children: [
                        Obx(() => _ToggleRow(
                              icon: Iconsax.notification,
                              iconColor: AppColors.accent,
                              title: 'Assignment Reminders',
                              subtitle:
                                  '1 day, 3 hours, and 1 hour before due',
                              value: notifCtrl.remindersEnabled.value,
                              onChanged: (v) async {
                                await notifCtrl.toggleReminders(v);
                                if (!v) {
                                  // Cancel all assignment notifications
                                  for (final a in appCtrl.assignments) {
                                    await NotificationService
                                        .cancelAssignmentReminders(a.id);
                                  }
                                } else {
                                  // Re-schedule all
                                  for (final a in appCtrl.assignments) {
                                    if (!a.isCompleted) {
                                      await NotificationService
                                          .scheduleAssignmentReminders(a);
                                    }
                                  }
                                }
                              },
                            )),

                        Divider(
                            color: AppColors.border,
                            height: 1,
                            indent: 52),

                        Obx(() => _ToggleRow(
                              icon: Iconsax.sun_1,
                              iconColor: AppColors.warning,
                              title: 'Daily Morning Summary',
                              subtitle: 'Shows what\'s due today at 8:00 AM',
                              value: notifCtrl.dailySummaryEnabled.value,
                              onChanged: (v) async {
                                await notifCtrl.toggleDailySummary(v);
                                if (v) {
                                  await NotificationService
                                      .scheduleDailySummary();
                                } else {
                                  await NotificationService
                                      .cancelDailySummary();
                                }
                              },
                            )),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Upcoming Reminders ────────────────────────────────
                    _SectionLabel(label: 'Upcoming Reminders'),
                    const SizedBox(height: 10),

                    if (items.isEmpty)
                      _EmptyReminders()
                    else
                      ...items.map((item) => _ReminderGroup(item: item)),

                    const SizedBox(height: 32),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Settings Card ────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
            inactiveTrackColor: AppColors.cardElevated,
            inactiveThumbColor: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

// ── Reminder Group ───────────────────────────────────────────────────────────

class _ReminderGroup extends StatelessWidget {
  final dynamic item;
  const _ReminderGroup({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = AppColors
        .courseColors[item.courseColorIndex % AppColors.courseColors.length];

    final daysLeft = item.dueDate
        .difference(DateTime.now())
        .inDays;

    final reminders = _getReminders(item.dueDate);

    if (reminders.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Assignment header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.assignmentTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        item.courseName,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _dueLabelColor(daysLeft).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _dueLabelText(daysLeft),
                    style: TextStyle(
                      color: _dueLabelColor(daysLeft),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(color: AppColors.border, height: 1, indent: 16),

          // Reminder times
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Column(
              children: reminders
                  .map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.clock,
                              color: AppColors.textMuted,
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              r,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getReminders(DateTime due) {
    final now = DateTime.now();
    final reminders = <String>[];

    final oneDayBefore = due.subtract(const Duration(days: 1));
    final threeHoursBefore = due.subtract(const Duration(hours: 3));
    final oneHourBefore = due.subtract(const Duration(hours: 1));

    if (oneDayBefore.isAfter(now)) {
      reminders.add('1 day before — ${_formatDateTime(oneDayBefore)}');
    }
    if (threeHoursBefore.isAfter(now)) {
      reminders.add('3 hours before — ${_formatDateTime(threeHoursBefore)}');
    }
    if (oneHourBefore.isAfter(now)) {
      reminders.add('1 hour before — ${_formatDateTime(oneHourBefore)}');
    }

    return reminders;
  }

  String _formatDateTime(DateTime dt) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day} at $hour:$min $ampm';
  }

  String _dueLabelText(int days) {
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    return 'In $days days';
  }

  Color _dueLabelColor(int days) {
    if (days <= 1) return AppColors.error;
    if (days <= 3) return AppColors.warning;
    return AppColors.success;
  }
}

// ── Supporting widgets ───────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _EmptyReminders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Iconsax.tick_circle, color: AppColors.success, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'No upcoming reminders — you\'re all caught up!',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}