import 'package:isar_community/isar.dart';

part 'assignment.g.dart';

@collection
class Assignment {
  Id id = Isar.autoIncrement;

  late String title;
  late String courseId;   // stores the course name for display
  late String courseName;
  late int courseColorIndex;
  late DateTime dueDate;
  late int priority;       // 0=low, 1=medium, 2=high
  late bool isCompleted;
  String? notes;

  String get priorityLabel {
    switch (priority) {
      case 2: return 'High';
      case 1: return 'Medium';
      default: return 'Low';
    }
  }

  bool get isOverdue => !isCompleted && dueDate.isBefore(DateTime.now());

  int get daysUntilDue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }
}