import 'dart:async';

import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../widgets/app_widgets.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1350), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          pageBuilder: (_, __, ___) => const OnboardingScreen(),
          transitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandMark(size: 104),
            const SizedBox(height: 26),
            Text('رحلة النور',
                style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            const Text(
              'تعلّم · اختبر معلوماتك · ارتقِ كل يوم',
              style: TextStyle(
                  color: AppColors.muted, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 34),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
}
