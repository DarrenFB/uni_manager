import 'package:isar/isar.dart';

part 'istar.g.dart';

@collection
class User {
  late Id id; // or: Id? id;

  String? name;

  int? age;
}