import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'progress_store.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.instance.init();
  await GameProgress.instance.init();
  await AuthService.instance.init();
  await NotificationService.instance.init();
  runApp(const DeenQuestApp());
}

class DeenQuestApp extends StatefulWidget {
  const DeenQuestApp({super.key});

  @override
  State<DeenQuestApp> createState() => _DeenQuestAppState();
}

class _DeenQuestAppState extends State<DeenQuestApp> {
  @override
  void initState() {
    super.initState();
    GameProgress.instance.addListener(_onProgressChanged);
  }

  void _onProgressChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    GameProgress.instance.removeListener(_onProgressChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'رحلة النور',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: GameProgress.instance.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const SplashScreen(),
    );
  }
}
