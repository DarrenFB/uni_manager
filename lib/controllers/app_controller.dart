import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:uni_manager/models/assignment.dart';
import 'package:uni_manager/models/course.dart';

class AppController extends GetxController {
  final Isar isar;
  AppController(this.isar);

  final courses = <Course>[].obs;
  final assignments = <Assignment>[].obs;
  final currentTabIndex = 0.obs;
  final userName = 'Darren'.obs;

  @override
  void onInit() {
    super.onInit();
    loadCourses();
    loadAssignments();
  }

  // ── Courses ───────────────────────────────────────────────────────────────

  Future<void> loadCourses() async {
    final all = await isar.courses.where().findAll();
    courses.assignAll(all);
  }

  Future<void> addCourse(Course course) async {
    await isar.writeTxn(() async => await isar.courses.put(course));
    await loadCourses();
  }

  Future<void> deleteCourse(int id, BuildContext context) async {
    final confirmed = await _confirmDelete(context, 'Remove this course?',
        'This will permanently delete the course and cannot be undone.');
    if (!confirmed) return;
    await isar.writeTxn(() async => await isar.courses.delete(id));
    await loadCourses();
  }

  Future<void> updateCourse(Course course) async {
    await isar.writeTxn(() async => await isar.courses.put(course));
    await loadCourses();
  }

  List<Course> get activeCourses =>
      courses.where((c) => c.isActive).toList();

  List<Course> get pastCourses =>
      courses.where((c) => !c.isActive).toList();

  // ── Assignments ───────────────────────────────────────────────────────────

  Future<void> loadAssignments() async {
    final all = await isar.assignments.where().findAll();
    assignments.assignAll(all);
  }

  Future<void> addAssignment(Assignment assignment) async {
    await isar.writeTxn(() async => await isar.assignments.put(assignment));
    await loadAssignments();
  }

  Future<void> deleteAssignment(int id, BuildContext context) async {
    final confirmed = await _confirmDelete(context, 'Delete this assignment?',
        'This will permanently delete the assignment and cannot be undone.');
    if (!confirmed) return;
    await isar.writeTxn(() async => await isar.assignments.delete(id));
    await loadAssignments();
  }

  Future<void> toggleAssignmentComplete(Assignment assignment) async {
    assignment.isCompleted = !assignment.isCompleted;
    await isar.writeTxn(() async => await isar.assignments.put(assignment));
    await loadAssignments();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<bool> _confirmDelete(
      BuildContext context, String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF131929),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        content: Text(message,
            style: const TextStyle(color: Color(0xFF8A94A6), fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8A94A6))),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  List<Assignment> get upcomingAssignments {
    final incomplete = assignments.where((a) => !a.isCompleted).toList();
    incomplete.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return incomplete.take(5).toList();
  }

  List<Assignment> get overdueAssignments =>
      assignments.where((a) => a.isOverdue).toList();

  List<Assignment> get completedAssignments =>
      assignments.where((a) => a.isCompleted).toList();

  List<Course> get todayCourses {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayStr = weekdays[DateTime.now().weekday - 1];
    return activeCourses.where((c) => c.dayList.contains(todayStr)).toList();
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}