import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uni_manager/main.dart';
import 'package:uni_manager/controllers/app_controller.dart';
import 'package:uni_manager/controllers/notification_controller.dart';

class NotificationTab extends StatelessWidget {
  const NotificationTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appCtrl = Get.find<AppController>();
    final notifCtrl = Get.find<NotificationController>();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.textMuted, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              const Expanded(
                child: Text('Notifications',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              ),
              // Close button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(Icons.close, color: AppColors.textSecondary, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Overdue
          Obx(() {
            final overdue = appCtrl.overdueAssignments;
            final upcoming = notifCtrl.buildNotificationItems(appCtrl.assignments);

            if (overdue.isEmpty && upcoming.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Iconsax.notification, color: AppColors.textMuted, size: 48),
                      const SizedBox(height: 16),
                      Text("You're all caught up",
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      Text('No upcoming deadlines',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                    ],
                  ),
                ),
              );
            }

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (overdue.isNotEmpty) ...[
                      _sectionLabel('Overdue (${overdue.length})', AppColors.error),
                      const SizedBox(height: 10),
                      ...overdue.map((a) {
                        final color = AppColors.courseColors[
                            a.courseColorIndex % AppColors.courseColors.length];
                        return _NotifTile(
                          title: a.title,
                          subtitle: a.courseName,
                          trailing: 'Overdue',
                          trailingColor: AppColors.error,
                          color: color,
                          icon: Iconsax.warning_2,
                        );
                      }),
                      const SizedBox(height: 20),
                    ],

                    if (upcoming.isNotEmpty) ...[
                      _sectionLabel('Upcoming', AppColors.textSecondary),
                      const SizedBox(height: 10),
                      ...upcoming.map((item) {
                        final color = AppColors.courseColors[
                            item.courseColorIndex % AppColors.courseColors.length];
                        final daysLeft = item.dueDate.difference(DateTime.now()).inDays;
                        final label = daysLeft == 0
                            ? 'Due today'
                            : daysLeft == 1
                                ? 'Due tomorrow'
                                : 'Due in $daysLeft days';
                        final labelColor = daysLeft <= 2 ? AppColors.warning : AppColors.textSecondary;

                        return _NotifTile(
                          title: item.assignmentTitle,
                          subtitle: item.courseName,
                          trailing: label,
                          trailingColor: labelColor,
                          color: color,
                          icon: Iconsax.clock,
                        );
                      }),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, Color color) => Text(
        text,
        style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3),
      );
}

class _NotifTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;
  final Color trailingColor;
  final Color color;
  final IconData icon;

  const _NotifTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.trailingColor,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Text(trailing,
              style: TextStyle(
                  color: trailingColor, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}