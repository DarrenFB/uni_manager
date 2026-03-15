import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:uni_manager/models/assignment.dart';
import 'package:uni_manager/models/course.dart';
import 'package:uni_manager/services/notification_service.dart';

class AppController extends GetxController {
  final Isar isar;
  AppController(this.isar);

  final courses = <Course>[].obs;
  final assignments = <Assignment>[].obs;
  final currentTabIndex = 0.obs;

  // User info (in a real app, pull from auth/profile)
  final userName = 'Darren'.obs;

  @override
  void onInit() {
    super.onInit();
    loadCourses();
    loadAssignments();
  }

  // ── Courses ──────────────────────────────────────────────────────────────


  Future<void> loadCourses() async {
    final all = await isar.courses.where().findAll();
    courses.assignAll(all);
  }

  Future<void> addCourse(Course course) async {
    await isar.writeTxn(() async => await isar.courses.put(course));
    await loadCourses();
  }

  Future<void> deleteCourse(int id) async {
    await isar.writeTxn(() async => await isar.courses.delete(id));
    await loadCourses();
  }

  Future<void> updateCourse(Course course) async {
    await isar.writeTxn(() async => await isar.courses.put(course));
    await loadCourses();
  }

  // ── Assignments ──────────────────────────────────────────────────────────

  Future<void> loadAssignments() async {
    final all = await isar.assignments.where().findAll();
    assignments.assignAll(all);
  }

  Future<void> addAssignment(Assignment assignment) async {
    await isar.writeTxn(() async => await isar.assignments.put(assignment));
    await loadAssignments();
    await NotificationService.scheduleAssignmentReminders(assignment);
  }

  Future<void> deleteAssignment(int id) async {
    await NotificationService.cancelAssignmentReminders(id);
    await isar.writeTxn(() async => await isar.assignments.delete(id));
    await loadAssignments();
  }

  Future<void> toggleAssignmentComplete(Assignment assignment) async {
    assignment.isCompleted = !assignment.isCompleted;
    await isar.writeTxn(() async => await isar.assignments.put(assignment));
    await loadAssignments();
  }

  // ── Computed helpers ─────────────────────────────────────────────────────

  List<Assignment> get upcomingAssignments {
    final incomplete = assignments.where((a) => !a.isCompleted).toList();
    incomplete.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return incomplete.take(5).toList();
  }

  List<Assignment> get overdueAssignments {
    return assignments.where((a) => a.isOverdue).toList();
  }

  List<Course> get todayCourses {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayStr = weekdays[DateTime.now().weekday - 1];
    return courses.where((c) => c.dayList.contains(todayStr)).toList();
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

