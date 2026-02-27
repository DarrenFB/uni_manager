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

  // Days as comma-separated string e.g. "Mon,Wed,Fri"
  late String days;
  late String startTime; // e.g. "09:00"
  late String endTime;   // e.g. "10:30"

  String get displayTime => '$startTime - $endTime';

  List<String> get dayList => days.split(',').where((d) => d.isNotEmpty).toList();
}
