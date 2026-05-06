import 'package:isar_community/isar.dart';

part 'course.g.dart';

@collection
class Course {
  Id id = Isar.autoIncrement;

  late String name;
  late String code;
  late String professor;
  late String room;
  late int colorIndex;

  late String days;
  late String startTime;
  late String endTime;

  // Semester info
  late String semester; // e.g. "Fall 2025"
  late DateTime semesterEndDate;

  String get displayTime => '$startTime - $endTime';
  List<String> get dayList => days.split(',').where((d) => d.isNotEmpty).toList();

  bool get isActive => semesterEndDate.isAfter(DateTime.now());
}