import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uni_manager/main.dart';
import 'package:uni_manager/controllers/app_controller.dart';
import 'package:uni_manager/models/assignment.dart';

class AssignmentsTab extends StatelessWidget {
  const AssignmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AppController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Assignments',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showAddAssignmentSheet(context, ctrl),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF5A52E0)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // List
            Expanded(
              child: Obx(() {
                if (ctrl.assignments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.task_square, color: AppColors.textMuted, size: 56),
                        const SizedBox(height: 16),
                        Text(
                          'No assignments yet',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add your first assignment',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final incomplete =
                    ctrl.assignments.where((a) => !a.isCompleted).toList()
                      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
                final complete =
                    ctrl.assignments.where((a) => a.isCompleted).toList();

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    if (incomplete.isNotEmpty) ...[
                      _sectionLabel('Pending (${incomplete.length})'),
                      const SizedBox(height: 10),
                      ...incomplete.map((a) => _AssignmentTile(assignment: a)),
                    ],
                    if (complete.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _sectionLabel('Completed (${complete.length})'),
                      const SizedBox(height: 10),
                      ...complete.map((a) => _AssignmentTile(assignment: a)),
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

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }

  void _showAddAssignmentSheet(BuildContext context, AppController ctrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddAssignmentSheet(ctrl: ctrl),
    );
  }
}

class _AssignmentTile extends StatelessWidget {
  final Assignment assignment;
  const _AssignmentTile({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AppController>();
    final color = AppColors.courseColors[
        assignment.courseColorIndex % AppColors.courseColors.length];
    // ignore: unused_local_variable
    final daysLeft = assignment.daysUntilDue;

    return Dismissible(
      key: Key('assignment_${assignment.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Iconsax.trash, color: AppColors.error, size: 22),
      ),
      onDismissed: (_) => ctrl.deleteAssignment(assignment.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: assignment.isCompleted
                ? AppColors.border
                : assignment.isOverdue
                    ? AppColors.error.withOpacity(0.3)
                    : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: () => ctrl.toggleAssignmentComplete(assignment),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: assignment.isCompleted ? color : Colors.transparent,
                  border: Border.all(
                    color: assignment.isCompleted ? color : AppColors.textMuted,
                    width: 2,
                  ),
                ),
                child: assignment.isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
            ),
            const SizedBox(width: 14),

            // Left color bar
            Container(
              width: 3,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.title,
                    style: TextStyle(
                      color: assignment.isCompleted
                          ? AppColors.textMuted
                          : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      decoration: assignment.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    assignment.courseName,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Due date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDate(assignment.dueDate),
                  style: TextStyle(
                    color: assignment.isOverdue
                        ? AppColors.error
                        : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                _PriorityDot(priority: assignment.priority),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

class _PriorityDot extends StatelessWidget {
  final int priority;
  const _PriorityDot({required this.priority});

  @override
  Widget build(BuildContext context) {
    final colors = [AppColors.success, AppColors.warning, AppColors.error];
    final labels = ['Low', 'Med', 'High'];
    final color = colors[priority.clamp(0, 2)];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        labels[priority.clamp(0, 2)],
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Add Assignment Bottom Sheet ──────────────────────────────────────────────

class _AddAssignmentSheet extends StatefulWidget {
  final AppController ctrl;
  const _AddAssignmentSheet({required this.ctrl});

  @override
  State<_AddAssignmentSheet> createState() => _AddAssignmentSheetState();
}

class _AddAssignmentSheetState extends State<_AddAssignmentSheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  int _priority = 1;
  int _selectedCourseIndex = -1;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.accent),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) return;

    final courses = widget.ctrl.courses;
    final course = _selectedCourseIndex >= 0 && courses.isNotEmpty
        ? courses[_selectedCourseIndex]
        : null;

    final assignment = Assignment()
      ..title = _titleController.text.trim()
      ..courseName = course?.name ?? 'No Course'
      ..courseId = course?.id.toString() ?? ''
      ..courseColorIndex = course?.colorIndex ?? 0
      ..dueDate = _dueDate
      ..priority = _priority
      ..isCompleted = false
      ..notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();

    widget.ctrl.addAssignment(assignment);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final courses = widget.ctrl.courses;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'New Assignment',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            _SheetField(
              controller: _titleController,
              label: 'Title',
              hint: 'e.g. Essay on Climate Change',
            ),
            const SizedBox(height: 16),

            // Course picker
            if (courses.isNotEmpty) ...[
              const Text(
                'Course',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: courses.length,
                  itemBuilder: (_, i) {
                    final c = courses[i];
                    final color = AppColors.courseColors[c.colorIndex % AppColors.courseColors.length];
                    final selected = _selectedCourseIndex == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCourseIndex = i),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? color.withOpacity(0.2) : AppColors.card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected ? color : AppColors.border,
                          ),
                        ),
                        child: Text(
                          c.code,
                          style: TextStyle(
                            color: selected ? color : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Due date
            const Text(
              'Due Date',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.calendar_2, color: AppColors.textSecondary, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      '${_monthName(_dueDate.month)} ${_dueDate.day}, ${_dueDate.year}',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Priority
            const Text(
              'Priority',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _PriorityButton(label: 'Low', value: 0, selected: _priority == 0, color: AppColors.success, onTap: () => setState(() => _priority = 0)),
                const SizedBox(width: 10),
                _PriorityButton(label: 'Medium', value: 1, selected: _priority == 1, color: AppColors.warning, onTap: () => setState(() => _priority = 1)),
                const SizedBox(width: 10),
                _PriorityButton(label: 'High', value: 2, selected: _priority == 2, color: AppColors.error, onTap: () => setState(() => _priority = 2)),
              ],
            ),
            const SizedBox(height: 16),

            // Notes
            _SheetField(
              controller: _notesController,
              label: 'Notes (optional)',
              hint: 'Any additional details...',
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Save button
            GestureDetector(
              onTap: _save,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF5A52E0)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'Save Assignment',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
  final int maxLines;

  const _SheetField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });

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
            maxLines: maxLines,
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

class _PriorityButton extends StatelessWidget {
  final String label;
  final int value;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _PriorityButton({
    required this.label,
    required this.value,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.15) : AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? color : AppColors.border),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? color : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}