import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../main.dart';
import '../controllers/app_controller.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/assignments_tab.dart';
import 'tabs/courses_tab.dart';
import 'tabs/calendar_tab.dart';
import 'package:uni_manager/screens/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppController>();

    final tabs = [
      const DashboardTab(),
      const AssignmentsTab(),
      const CoursesTab(),
      const CalendarTab(),
      const ProfileScreen(),
    ];

    return Obx(() => Scaffold(
          backgroundColor: AppColors.background,
          body: IndexedStack(
            index: controller.currentTabIndex.value,
            children: tabs,
          ),
          bottomNavigationBar: _BottomNav(controller: controller),
        ));
  }
}

class _BottomNav extends StatelessWidget {
  final AppController controller;
  const _BottomNav({required this.controller});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Iconsax.home_2, Iconsax.home_25, 'Home'),
      (Iconsax.task_square, Iconsax.task_square5, 'Tasks'),
      (Iconsax.book_1, Iconsax.book5, 'Courses'),
      (Iconsax.calendar_2, Iconsax.calendar_25, 'Calendar'),
      (Iconsax.user, Iconsax.user5, 'Profile'),
    ];

    return Obx(() => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (i) {
                  final isSelected = controller.currentTabIndex.value == i;
                  final item = items[i];
                  return GestureDetector(
                    onTap: () => controller.currentTabIndex.value = i,
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accentSoft
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? item.$2 : item.$1,
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.textSecondary,
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.$3,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ));
  }
}