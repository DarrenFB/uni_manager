import 'dart:io';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  final name = 'Student'.obs;
  final university = ''.obs;
  final program = ''.obs;
  final semester = ''.obs;
  final year = ''.obs;
  final gpa = 0.0.obs;
  final profileImagePath = ''.obs;

  static const _nameKey = 'profile_name';
  static const _universityKey = 'profile_university';
  static const _programKey = 'profile_program';
  static const _semesterKey = 'profile_semester';
  static const _yearKey = 'profile_year';
  static const _gpaKey = 'profile_gpa';
  static const _imageKey = 'profile_image_path';

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    name.value = prefs.getString(_nameKey) ?? 'Student';
    university.value = prefs.getString(_universityKey) ?? '';
    program.value = prefs.getString(_programKey) ?? '';
    semester.value = prefs.getString(_semesterKey) ?? '';
    year.value = prefs.getString(_yearKey) ?? '';
    gpa.value = prefs.getDouble(_gpaKey) ?? 0.0;
    profileImagePath.value = prefs.getString(_imageKey) ?? '';
  }

  Future<void> saveProfile({
    required String newName,
    required String newUniversity,
    required String newProgram,
    required String newSemester,
    required String newYear,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, newName);
    await prefs.setString(_universityKey, newUniversity);
    await prefs.setString(_programKey, newProgram);
    await prefs.setString(_semesterKey, newSemester);
    await prefs.setString(_yearKey, newYear);

    name.value = newName;
    university.value = newUniversity;
    program.value = newProgram;
    semester.value = newSemester;
    year.value = newYear;
  }

  Future<void> saveProfileImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_imageKey, path);
    profileImagePath.value = path;
  }

  Future<void> updateGpa(double newGpa) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_gpaKey, newGpa);
    gpa.value = newGpa;
  }

  String get firstInitial =>
      name.value.isNotEmpty ? name.value[0].toUpperCase() : 'S';

  String get displaySemester {
    if (semester.value.isEmpty && year.value.isEmpty) return '';
    if (semester.value.isEmpty) return year.value;
    if (year.value.isEmpty) return semester.value;
    return '${semester.value} ${year.value}';
  }
}