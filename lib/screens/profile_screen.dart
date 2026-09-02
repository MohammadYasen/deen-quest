import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../progress_store.dart';
import '../services/auth_service.dart';
import '../widgets/app_widgets.dart';
import 'achievements_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([GameProgress.instance, AuthService.instance]),
      builder: (context, _) {
        final progress = GameProgress.instance;
        final user = AuthService.instance.currentUser;
        final name = user?.displayName ?? 'طالب علم';
        final isGuest = user?.isAnonymous ?? true;

        final level = (progress.xp ~/ 100) + 1;
        final levelProgress = ((progress.xp % 100) / 100.0).clamp(0.0, 1.0);

        final initial = name.isNotEmpty ? name[0] : 'ط';

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('الملف الشخصي',
                      style: Theme.of(context).textTheme.headlineMedium),
                  IconButton(
                    tooltip: 'الإعدادات',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                    icon: const Icon(Icons.settings_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 74,
                        height: 74,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gold, width: 3),
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                  color: AppColors.ink,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              isGuest ? 'حساب تجريبي كزائر · مستوى $level' : 'مستوى $level · طالب معرفة',
                              style: const TextStyle(color: AppColors.muted),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: levelProgress,
                              minHeight: 7,
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                              backgroundColor: AppColors.primarySoft,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _ProfileStat(
                      value: '${progress.streak}',
                      label: 'سلسلة الأيام',
                      icon: Icons.local_fire_department_rounded,
                      color: const Color(0xFFF28C28),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _ProfileStat(
                      value: '${progress.xp}',
                      label: 'مجموع XP',
                      icon: Icons.bolt_rounded,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _ProfileStat(
                      value: '${progress.completedLessonKeys.length}',
                      label: 'دروس مكتملة',
                      icon: Icons.check_circle_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              SectionHeading(
                title: 'الإنجازات المكتسبة',
                action: 'عرض الكل',
                onAction: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _AchievementCard(
                      icon: Icons.whatshot_rounded,
                      title: 'بداية قوية',
                      subtitle: '7 أيام متتالية',
                      color: const Color(0xFFF28C28),
                      isUnlocked: progress.unlockedAchievements.contains('start_strong'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _AchievementCard(
                      icon: Icons.menu_book_rounded,
                      title: 'طالب مجتهد',
                      subtitle: 'أكمل 5 دروس',
                      color: AppColors.primary,
                      isUnlocked: progress.unlockedAchievements.contains('diligent_student'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const SectionHeading(title: 'الهدف اليومي'),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${progress.todayCompletedLessons} من أصل ${progress.dailyGoalLessons} هدف',
                            style: const TextStyle(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w900),
                          ),
                          Text(
                            progress.dailyGoalLessons == 0
                                ? '0%'
                                : '${((progress.todayCompletedLessons / progress.dailyGoalLessons).clamp(0.0, 1.0) * 100).round()}%',
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress.dailyGoalLessons == 0
                              ? 0
                              : (progress.todayCompletedLessons / progress.dailyGoalLessons).clamp(0.0, 1.0),
                          minHeight: 10,
                          backgroundColor: AppColors.primarySoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
        child: Column(
          children: [
            Icon(icon, color: color, size: 25),
            const SizedBox(height: 5),
            Text(value,
                style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 18,
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

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isUnlocked,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Opacity(
              opacity: isUnlocked ? 1.0 : 0.35,
              child: SoftIcon(
                icon: icon,
                color: color,
                backgroundColor: color.withValues(alpha: .12),
                size: 58,
              ),
            ),
            const SizedBox(height: 9),
            Text(title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
