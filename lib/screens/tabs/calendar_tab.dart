import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uni_manager/main.dart';
import 'package:uni_manager/controllers/app_controller.dart';
import 'package:uni_manager/models/assignment.dart';

class CalendarTab extends StatefulWidget {
  const CalendarTab({super.key});

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  void _prevMonth() => setState(() {
        _focusedMonth =
            DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
      });

  void _nextMonth() => setState(() {
        _focusedMonth =
            DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
      });

  List<Assignment> _assignmentsForDay(List<Assignment> all, DateTime day) {
    return all.where((a) {
      final d = a.dueDate;
      return d.year == day.year && d.month == day.month && d.day == day.day;
    }).toList();
  }

  Map<int, List<Assignment>> _assignmentsInMonth(List<Assignment> all) {
    final map = <int, List<Assignment>>{};
    for (final a in all) {
      if (a.dueDate.year == _focusedMonth.year &&
          a.dueDate.month == _focusedMonth.month) {
        map.putIfAbsent(a.dueDate.day, () => []).add(a);
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AppController>();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          final all = ctrl.assignments;
          final monthMap = _assignmentsInMonth(all);
          final selectedAssignments = _selectedDay != null
              ? _assignmentsForDay(all, _selectedDay!)
              : <Assignment>[];

          // Build calendar grid
          final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
          final daysInMonth =
              DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
          // weekday: Mon=1...Sun=7, we want Mon first
          final startOffset = (firstDay.weekday - 1) % 7;
          final totalCells = startOffset + daysInMonth;
          final rows = (totalCells / 7).ceil();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Calendar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Month navigator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      _NavButton(icon: Icons.chevron_left, onTap: _prevMonth),
                      Expanded(
                        child: Center(
                          child: Text(
                            '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      _NavButton(icon: Icons.chevron_right, onTap: _nextMonth),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Weekday headers
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: weekdays
                      .map((d) => Expanded(
                            child: Center(
                              child: Text(
                                d,
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),

              const SizedBox(height: 8),

              // Calendar grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: List.generate(rows, (row) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: List.generate(7, (col) {
                          final cellIndex = row * 7 + col;
                          final dayNum = cellIndex - startOffset + 1;
                          if (dayNum < 1 || dayNum > daysInMonth) {
                            return const Expanded(child: SizedBox(height: 44));
                          }

                          final thisDay = DateTime(
                              _focusedMonth.year, _focusedMonth.month, dayNum);
                          final isToday = _isSameDay(thisDay, DateTime.now());
                          final isSelected = _selectedDay != null &&
                              _isSameDay(thisDay, _selectedDay!);
                          final dayAssignments = monthMap[dayNum] ?? [];

                          return Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedDay = thisDay),
                              child: Container(
                                height: 44,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.accent
                                      : isToday
                                          ? AppColors.accentSoft
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$dayNum',
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : isToday
                                                ? AppColors.accentLight
                                                : Colors.white,
                                        fontSize: 14,
                                        fontWeight: isSelected || isToday
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                    if (dayAssignments.isNotEmpty)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: dayAssignments
                                            .take(3)
                                            .map((a) {
                                              final color =
                                                  AppColors.courseColors[
                                                      a.courseColorIndex %
                                                          AppColors.courseColors
                                                              .length];
                                              return Container(
                                                width: 4,
                                                height: 4,
                                                margin: const EdgeInsets.only(
                                                    right: 2),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: isSelected
                                                      ? Colors.white
                                                              .withOpacity(0.8)
                                                      : color,
                                                ),
                                              );
                                            })
                                            .toList(),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 16),

              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(color: AppColors.border, height: 1),
              ),

              const SizedBox(height: 16),

              // Selected day assignments
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _selectedDay != null
                      ? _formatSelectedDay(_selectedDay!)
                      : 'Select a day',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: selectedAssignments.isEmpty
                    ? Center(
                        child: Text(
                          'Nothing due on this day',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: selectedAssignments.length,
                        itemBuilder: (_, i) {
                          final a = selectedAssignments[i];
                          final color = AppColors.courseColors[
                              a.courseColorIndex %
                                  AppColors.courseColors.length];
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
                                  width: 3,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        a.courseName,
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (a.isCompleted)
                                  Icon(Iconsax.tick_circle5,
                                      color: AppColors.success, size: 18)
                                else if (a.isOverdue)
                                  Icon(Iconsax.danger5,
                                      color: AppColors.error, size: 18),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatSelectedDay(DateTime d) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.cardElevated,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
  }
}