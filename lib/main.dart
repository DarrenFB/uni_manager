import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'models/course.dart';
import 'models/assignment.dart';
import 'controllers/app_controller.dart';
import 'controllers/view_controller.dart';
import 'controllers/notification_controller.dart';
import 'controllers/profile_controller.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Isar database
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [CourseSchema, AssignmentSchema],
    directory: dir.path,
  );

  // Register controllers (NotificationController first — AppController depends on it)
  Get.put(NotificationController());
  Get.put(AppController(isar));
  Get.put(ViewController());
  Get.put(ProfileController());

  // Initialize notification service and schedule daily summary if enabled
  await NotificationService.init();
  final notifCtrl = Get.find<NotificationController>();
  if (notifCtrl.dailySummaryEnabled.value) {
    await NotificationService.scheduleDailySummary();
  }

  runApp(const UniManagerApp());
}

class UniManagerApp extends StatelessWidget {
  const UniManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'UniManager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.dark(
          primary: AppColors.accent,
          surface: AppColors.surface,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

/// Central color palette
class AppColors {
  static const background = Color(0xFF0A0E1A);
  static const surface = Color(0xFF131929);
  static const card = Color(0xFF1A2235);
  static const cardElevated = Color(0xFF1E2A3D);
  static const accent = Color(0xFF6C63FF);
  static const accentLight = Color(0xFF8B85FF);
  static const accentSoft = Color(0x266C63FF);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF8A94A6);
  static const textMuted = Color(0xFF4A5568);
  static const success = Color(0xFF4ECDC4);
  static const warning = Color(0xFFFFD93D);
  static const error = Color(0xFFFF6B6B);
  static const border = Color(0xFF1E2A3D);

  static const List<Color> courseColors = [
    Color(0xFF6C63FF),
    Color(0xFF4ECDC4),
    Color(0xFFFF6B6B),
    Color(0xFFFFD93D),
    Color(0xFF45B7D1),
    Color(0xFFFF8C42),
    Color(0xFFA8E6CF),
    Color(0xFFFF69B4),
  ];
}