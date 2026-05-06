import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uni_manager/main.dart';
import 'package:uni_manager/controllers/app_controller.dart';
import 'package:uni_manager/models/course.dart';

class CoursesTab extends StatelessWidget {
  const CoursesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AppController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('My Courses',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3)),
                  ),
                  GestureDetector(
                    onTap: () => _showAddCourseSheet(context, ctrl),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF5A52E0)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                final active = ctrl.activeCourses;
                final past = ctrl.pastCourses;

                if (active.isEmpty && past.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.book_1, color: AppColors.textMuted, size: 56),
                        const SizedBox(height: 16),
                        Text('No courses added yet',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Text('Tap + to add your first course',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    if (active.isNotEmpty) ...[
                      _sectionLabel('Current (${active.length})'),
                      const SizedBox(height: 10),
                      ...active.map((c) => _CourseCard(course: c)),
                    ],
                    if (past.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _sectionLabel('Past Courses (${past.length})'),
                      const SizedBox(height: 10),
                      ...past.map((c) => _CourseCard(course: c, isPast: true)),
                    ],
                    const SizedBox(height: 32),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3),
      );

  void _showAddCourseSheet(BuildContext context, AppController ctrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddCourseSheet(ctrl: ctrl),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;
  final bool isPast;
  const _CourseCard({required this.course, this.isPast = false});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AppController>();
    final color = AppColors.courseColors[
        course.colorIndex % AppColors.courseColors.length];

    return Dismissible(
      key: Key('course_${course.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => ctrl.deleteCourse(course.id, context).then((_) => false),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Iconsax.trash, color: AppColors.error, size: 22),
      ),
      child: Opacity(
        opacity: isPast ? 0.6 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(isPast ? 0.08 : 0.15),
                  border: Border.all(color: color.withOpacity(isPast ? 0.15 : 0.3)),
                ),
                child: Center(
                  child: Text(
                    course.code.length >= 2 ? course.code.substring(0, 2) : course.code,
                    style: TextStyle(
                        color: color.withOpacity(isPast ? 0.5 : 1.0),
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(course.professor,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(course.semester,
                              style: TextStyle(
                                  color: color.withOpacity(isPast ? 0.5 : 1.0),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 8),
                        Icon(Iconsax.clock, color: AppColors.textMuted, size: 12),
                        const SizedBox(width: 4),
                        Text(course.displayTime,
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: course.dayList
                        .map((d) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(d,
                                  style: TextStyle(
                                      color: color, fontSize: 10, fontWeight: FontWeight.w600)),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Add Course Sheet ──────────────────────────────────────────────────────────

class _AddCourseSheet extends StatefulWidget {
  final AppController ctrl;
  const _AddCourseSheet({required this.ctrl});

  @override
  State<_AddCourseSheet> createState() => _AddCourseSheetState();
}

class _AddCourseSheetState extends State<_AddCourseSheet> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _profController = TextEditingController();
  final _roomController = TextEditingController();

  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 30);
  int _colorIndex = 0;

  final _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  final _selectedDays = <String>{};

  // Semester
  String _semesterTerm = 'Fall';
  int _semesterYear = DateTime.now().year;
  DateTime _semesterEndDate = DateTime(DateTime.now().year, 12, 31);

  final _terms = ['Winter', 'Summer', 'Fall'];

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _profController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(primary: AppColors.accent)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => isStart ? _startTime = picked : _endTime = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _semesterEndDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 3),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(primary: AppColors.accent)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _semesterEndDate = picked);
  }

  void _save() {
    if (_nameController.text.trim().isEmpty || _codeController.text.trim().isEmpty) return;

    final course = Course()
      ..name = _nameController.text.trim()
      ..code = _codeController.text.trim().toUpperCase()
      ..professor = _profController.text.trim().isEmpty ? 'TBD' : _profController.text.trim()
      ..room = _roomController.text.trim().isEmpty ? 'TBD' : _roomController.text.trim()
      ..colorIndex = _colorIndex
      ..days = _selectedDays.join(',')
      ..startTime = _formatTime(_startTime)
      ..endTime = _formatTime(_endTime)
      ..semester = '$_semesterTerm $_semesterYear'
      ..semesterEndDate = _semesterEndDate;

    widget.ctrl.addCourse(course);
    Navigator.of(context).pop();
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final years = List.generate(4, (i) => DateTime.now().year + i - 1);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.textMuted, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Add Course',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(flex: 3, child: _SheetField(controller: _nameController, label: 'Course Name', hint: 'e.g. Data Structures')),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _SheetField(controller: _codeController, label: 'Code', hint: 'CS101')),
              ],
            ),
            const SizedBox(height: 16),
            _SheetField(controller: _profController, label: 'Professor', hint: 'Dr. Smith'),
            const SizedBox(height: 16),
            _SheetField(controller: _roomController, label: 'Room', hint: 'Room 204B'),
            const SizedBox(height: 16),

            // Semester
            const Text('Semester', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _semesterTerm,
                        dropdownColor: AppColors.card,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        items: _terms.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (v) => setState(() => _semesterTerm = v!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _semesterYear,
                        dropdownColor: AppColors.card,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        items: years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
                        onChanged: (v) => setState(() => _semesterYear = v!),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Semester end date
            const Text('Semester End Date', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickEndDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 16),
                    const SizedBox(width: 10),
                    Text(
                      '${_monthName(_semesterEndDate.month)} ${_semesterEndDate.day}, ${_semesterEndDate.year}',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Days
            const Text('Days', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: _days.map((d) {
                final selected = _selectedDays.contains(d);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selected ? _selectedDays.remove(d) : _selectedDays.add(d)),
                    child: Container(
                      margin: EdgeInsets.only(right: d != 'Fri' ? 6 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.accentSoft : AppColors.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: selected ? AppColors.accent : AppColors.border),
                      ),
                      child: Center(
                        child: Text(d,
                            style: TextStyle(
                                color: selected ? AppColors.accent : AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Time
            const Text('Time', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: GestureDetector(onTap: () => _pickTime(true), child: _TimeChip(label: 'Start', time: _startTime))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('→', style: TextStyle(color: AppColors.textSecondary)),
                ),
                Expanded(child: GestureDetector(onTap: () => _pickTime(false), child: _TimeChip(label: 'End', time: _endTime))),
              ],
            ),
            const SizedBox(height: 16),

            // Color
            const Text('Color', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Row(
              children: List.generate(
                AppColors.courseColors.length,
                (i) => GestureDetector(
                  onTap: () => setState(() => _colorIndex = i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.courseColors[i],
                      border: _colorIndex == i ? Border.all(color: Colors.white, width: 2.5) : null,
                      boxShadow: _colorIndex == i
                          ? [BoxShadow(color: AppColors.courseColors[i].withOpacity(0.5), blurRadius: 8)]
                          : null,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            GestureDetector(
              onTap: _save,
              child: Container(
                width: double.infinity, height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF5A52E0)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('Add Course',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[month - 1];
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  const _SheetField({required this.controller, required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.textMuted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  const _TimeChip({required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    final hour = time.hour.toString().padLeft(2, '0');
    final min = time.minute.toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.clock, color: AppColors.textSecondary, size: 16),
          const SizedBox(width: 8),
          Text('$hour:$min', style: const TextStyle(color: Colors.white, fontSize: 15)),
        ],
      ),
    );
  }
}