import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'lesson_screen.dart';

class LessonResultScreen extends StatelessWidget {
  const LessonResultScreen({
    super.key,
    required this.title,
    required this.correct,
    required this.total,
    required this.xp,
    required this.hearts,
  });

  final String title;
  final int correct;
  final int total;
  final int xp;
  final int hearts;

  @override
  Widget build(BuildContext context) {
    final accuracy = total == 0 ? 0 : ((correct / total) * 100).round();
    final stars = accuracy >= 90
        ? 3
        : accuracy >= 65
            ? 2
            : 1;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  Container(
                    width: 132,
                    height: 132,
                    decoration: BoxDecoration(
                      color: AppColors.goldSoft,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 4),
                    ),
                    child: const Icon(Icons.emoji_events_rounded,
                        color: AppColors.gold, size: 75),
                  ),
                  const SizedBox(height: 24),
                  Text('أتممت الدرس!',
                      style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 7),
                  Text(title,
                      style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 17,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 17),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Icon(
                            index < stars
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: AppColors.gold,
                            size: 39),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Expanded(
                          child: _ResultStat(
                              icon: Icons.bolt_rounded,
                              value: '+$xp',
                              label: 'نقطة خبرة',
                              color: AppColors.gold)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _ResultStat(
                              icon: Icons.track_changes_rounded,
                              value: '$accuracy%',
                              label: 'الدقة',
                              color: AppColors.primary)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _ResultStat(
                              icon: Icons.favorite_rounded,
                              value: '$hearts',
                              label: 'قلوب متبقية',
                              color: AppColors.error)),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(18)),
                    child: const Row(
                      children: [
                        Icon(Icons.lock_open_rounded,
                            color: AppColors.primary, size: 30),
                        SizedBox(width: 12),
                        Expanded(
                            child: Text(
                                'تقدّمت خطوة في مسار الوحدة. واصل التعلّم لفتح المرحلة التالية.',
                                style: TextStyle(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w700,
                                    height: 1.5))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.route_rounded),
                    label: const Text('العودة إلى مسار التعلّم'),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => LessonScreen(title: title),
                      ),
                    ),
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('إعادة الدرس'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 19,
                    fontWeight: FontWeight.w900)),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, fontSize: 10.5)),
          ],
        ),
      ),
    );
  }
}
