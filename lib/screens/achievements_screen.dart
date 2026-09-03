import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../progress_store.dart';
import '../widgets/app_widgets.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  static const _achievements = [
    (
      'first_step',
      Icons.flag_rounded,
      'الخطوة الأولى',
      'أكمل درسك الأول في رحلة النور',
      AppColors.primary,
    ),
    (
      'start_strong',
      Icons.whatshot_rounded,
      'بداية قوية',
      'حافظ على 7 أيام متتالية من التعلّم',
      Color(0xFFF28C28),
    ),
    (
      'diligent_student',
      Icons.menu_book_rounded,
      'طالب مجتهد',
      'أكمل 5 دروس مختلفة',
      AppColors.primary,
    ),
    (
      'point_collector',
      Icons.bolt_rounded,
      'جامع المعرفة',
      'اجمع 500 نقطة خبرة XP',
      AppColors.gold,
    ),
    (
      'high_accuracy',
      Icons.track_changes_rounded,
      'دقة عالية',
      'أكمل درساً بنسبة نجاح 100%',
      AppColors.purple,
    ),
    (
      'steadfast',
      Icons.favorite_rounded,
      'الصابر المثابر',
      'أكمل درساً وأنت تمتلك قلباً واحداً',
      AppColors.error,
    ),
    (
      'world_conqueror',
      Icons.workspace_premium_rounded,
      'فاتح العوالم',
      'اجتز تحدي ختم العالم الذهبي',
      AppColors.gold,
    ),
    (
      'speed_scholar',
      Icons.timer_rounded,
      'عالم السرعة',
      'حقق 8 إجابات صحيحة في سباق النور السريع',
      Color(0xFF26A69A),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: GameProgress.instance,
      builder: (context, _) {
        final unlockedKeys = GameProgress.instance.unlockedAchievements;

        return Scaffold(
          appBar: AppBar(title: const Text('الإنجازات والشارات')),
          body: GridView.builder(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 240,
              mainAxisExtent: 215,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _achievements.length,
            itemBuilder: (context, index) {
              final item = _achievements[index];
              final isUnlocked = unlockedKeys.contains(item.$1);

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Opacity(
                            opacity: isUnlocked ? 1.0 : 0.35,
                            child: SoftIcon(
                                icon: item.$2,
                                color: item.$5,
                                backgroundColor: item.$5.withValues(alpha: .12),
                                size: 68),
                          ),
                          if (!isUnlocked)
                            const Positioned(
                                bottom: 0,
                                left: 0,
                                child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: AppColors.muted,
                                    child: Icon(Icons.lock_rounded,
                                        color: Colors.white, size: 14))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(item.$3,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(item.$4,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      Text(isUnlocked ? 'تم الحصول عليه' : 'قيد الإنجاز',
                          style: TextStyle(
                              color: isUnlocked ? AppColors.primary : AppColors.muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
