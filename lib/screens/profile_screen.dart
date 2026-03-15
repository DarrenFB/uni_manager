import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uni_manager/main.dart';
import 'package:uni_manager/controllers/profile_controller.dart';
import 'package:uni_manager/controllers/app_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProfileController>();
    final appCtrl = Get.find<AppController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() => CustomScrollView(
              slivers: [
                // ── Header ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showEditSheet(context, ctrl),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.accentSoft,
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: AppColors.accent.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Iconsax.edit_2,
                                    color: AppColors.accentLight, size: 15),
                                const SizedBox(width: 6),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    color: AppColors.accentLight,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Avatar + Name ───────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    child: Column(
                      children: [
                        // Avatar
                        GestureDetector(
                          onTap: () => _pickImage(ctrl),
                          child: Stack(
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF6C63FF),
                                      Color(0xFF4ECDC4)
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accent.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ctrl.profileImagePath.value.isNotEmpty
                                    ? ClipOval(
                                        child: Image.file(
                                          File(ctrl.profileImagePath.value),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          ctrl.firstInitial,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 38,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                              ),
                              // Camera badge
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.background, width: 2),
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded,
                                      color: Colors.white, size: 15),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Name
                        Text(
                          ctrl.name.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),

                        if (ctrl.program.value.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            ctrl.program.value,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],

                        if (ctrl.university.value.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.building,
                                  color: AppColors.textMuted, size: 13),
                              const SizedBox(width: 5),
                              Text(
                                ctrl.university.value,
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],

                        if (ctrl.displaySemester.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.calendar_1,
                                  color: AppColors.textMuted, size: 13),
                              const SizedBox(width: 5),
                              Text(
                                ctrl.displaySemester,
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // ── Stats Cards ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Obx(() => Row(
                          children: [
                            _StatCard(
                              label: 'Courses',
                              value: appCtrl.courses.length.toString(),
                              icon: Iconsax.book_1,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 12),
                            _StatCard(
                              label: 'Assignments',
                              value: appCtrl.assignments
                                  .where((a) => !a.isCompleted)
                                  .length
                                  .toString(),
                              icon: Iconsax.task_square,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 12),
                            _StatCard(
                              label: 'Completed',
                              value: appCtrl.assignments
                                  .where((a) => a.isCompleted)
                                  .length
                                  .toString(),
                              icon: Iconsax.tick_circle,
                              color: AppColors.success,
                            ),
                          ],
                        )),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // ── GPA Card ────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _GpaCard(ctrl: ctrl),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // ── Info Section ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _InfoCard(ctrl: ctrl),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            )),
      ),
    );
  }

  Future<void> _pickImage(ProfileController ctrl) async {
    final picker = ImagePicker();
    final source = await Get.bottomSheet<ImageSource>(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Change Photo',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            _PhotoOption(
              icon: Iconsax.camera,
              label: 'Take Photo',
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            const SizedBox(height: 12),
            _PhotoOption(
              icon: Iconsax.gallery,
              label: 'Choose from Gallery',
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (picked != null) {
      await ctrl.saveProfileImage(picked.path);
    }
  }

  void _showEditSheet(BuildContext context, ProfileController ctrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(ctrl: ctrl),
    );
  }
}

// ── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(label,
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ── GPA Card ─────────────────────────────────────────────────────────────────

class _GpaCard extends StatelessWidget {
  final ProfileController ctrl;
  const _GpaCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent.withOpacity(0.2),
            AppColors.accent.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accent.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Iconsax.chart_2, color: AppColors.accent, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current GPA',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                      ctrl.gpa.value == 0.0
                          ? '—'
                          : ctrl.gpa.value.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    )),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showGpaDialog(context, ctrl),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Update',
                style: TextStyle(
                  color: AppColors.accentLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGpaDialog(BuildContext context, ProfileController ctrl) {
    final controller =
        TextEditingController(text: ctrl.gpa.value == 0.0 ? '' : ctrl.gpa.value.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Update GPA',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'e.g. 3.75',
            hintStyle: TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val >= 0 && val <= 4.0) {
                ctrl.updateGpa(val);
              }
              Get.back();
            },
            child: Text('Save',
                style: TextStyle(
                    color: AppColors.accentLight,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Info Card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final ProfileController ctrl;
  const _InfoCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Iconsax.building,
            label: 'University',
            value: ctrl.university.value.isEmpty
                ? 'Not set'
                : ctrl.university.value,
          ),
          Divider(color: AppColors.border, height: 1, indent: 52),
          _InfoRow(
            icon: Iconsax.book,
            label: 'Program',
            value:
                ctrl.program.value.isEmpty ? 'Not set' : ctrl.program.value,
          ),
          Divider(color: AppColors.border, height: 1, indent: 52),
          _InfoRow(
            icon: Iconsax.calendar_1,
            label: 'Semester',
            value: ctrl.displaySemester.isEmpty
                ? 'Not set'
                : ctrl.displaySemester,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.cardElevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.textSecondary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: value == 'Not set'
                        ? AppColors.textMuted
                        : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Photo Option ──────────────────────────────────────────────────────────────

class _PhotoOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 14),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

// ── Edit Profile Bottom Sheet ─────────────────────────────────────────────────

class _EditProfileSheet extends StatefulWidget {
  final ProfileController ctrl;
  const _EditProfileSheet({required this.ctrl});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _uniCtrl;
  late final TextEditingController _programCtrl;
  String _selectedSemester = '';
  String _selectedYear = '';

  final _semesters = ['Winter', 'Spring', 'Summer', 'Fall'];
  final _years = ['2023', '2024', '2025', '2026', '2027'];

  @override
  void initState() {
    super.initState();
    _nameCtrl =
        TextEditingController(text: widget.ctrl.name.value);
    _uniCtrl =
        TextEditingController(text: widget.ctrl.university.value);
    _programCtrl =
        TextEditingController(text: widget.ctrl.program.value);
    _selectedSemester = widget.ctrl.semester.value;
    _selectedYear = widget.ctrl.year.value;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _uniCtrl.dispose();
    _programCtrl.dispose();
    super.dispose();
  }

  void _save() {
    widget.ctrl.saveProfile(
      newName: _nameCtrl.text.trim().isEmpty ? 'Student' : _nameCtrl.text.trim(),
      newUniversity: _uniCtrl.text.trim(),
      newProgram: _programCtrl.text.trim(),
      newSemester: _selectedSemester,
      newYear: _selectedYear,
    );
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
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
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Edit Profile',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),

            _Field(controller: _nameCtrl, label: 'Full Name', hint: 'Your name'),
            const SizedBox(height: 16),
            _Field(controller: _uniCtrl, label: 'University', hint: 'e.g. University of Ottawa'),
            const SizedBox(height: 16),
            _Field(controller: _programCtrl, label: 'Program / Major', hint: 'e.g. Computer Science'),
            const SizedBox(height: 16),

            // Semester
            const Text('Semester',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: _semesters.map((s) {
                final selected = _selectedSemester == s;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedSemester = s),
                    child: Container(
                      margin: EdgeInsets.only(
                          right: s != _semesters.last ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.accentSoft
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? AppColors.accent
                              : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text(s,
                            style: TextStyle(
                              color: selected
                                  ? AppColors.accent
                                  : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Year
            const Text('Year',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: _years.map((y) {
                final selected = _selectedYear == y;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedYear = y),
                    child: Container(
                      margin: EdgeInsets.only(
                          right: y != _years.last ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.accentSoft
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? AppColors.accent
                              : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text(y,
                            style: TextStyle(
                              color: selected
                                  ? AppColors.accent
                                  : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Save
            GestureDetector(
              onTap: _save,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF5A52E0)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('Save Profile',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
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