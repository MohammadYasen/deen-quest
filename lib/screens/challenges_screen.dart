import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../progress_store.dart';
import '../widgets/app_widgets.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  void _buyStreakFreeze(BuildContext context) {
    final progress = GameProgress.instance;
    if (progress.hapticEnabled) HapticFeedback.mediumImpact();

    if (progress.buyStreakFreeze(cost: 100)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('مبروك! تم شراء درع تجميد السلسلة ❄️ (+1)'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('نقاط الخبرة غير كافية (تحتاج إلى 100 XP)'),
        ),
      );
    }
  }

  void _buyHeartRefill(BuildContext context) {
    final progress = GameProgress.instance;
    if (progress.hapticEnabled) HapticFeedback.mediumImpact();

    if (progress.hearts >= GameProgress.maxHearts) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('قلوبك ممتلئة بالكامل بالفعل! ❤️')),
      );
      return;
    }

    if (progress.buyHeartRefill(cost: 50)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت استعادة القلوب بالكامل! ❤️ (5/5)')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('نقاط الخبرة غير كافية (تحتاج إلى 50 XP)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: GameProgress.instance,
      builder: (context, _) {
        final progress = GameProgress.instance;

        final daily1Done = progress.todayCompletedLessons >= 1;
        final daily1Claimed = progress.isChallengeClaimed('daily_lesson');

        final daily2Done = progress.todayCorrectAnswers >= 5;
        final daily2Claimed = progress.isChallengeClaimed('daily_correct');

        final daily3Done = progress.streak >= 1;
        final daily3Claimed = progress.isChallengeClaimed('daily_streak');

        final weeklyLessons = (progress.todayCompletedLessons + 3).clamp(0, 7);
        final weeklyDone = weeklyLessons >= 7;
        final weeklyClaimed = progress.isChallengeClaimed('weekly_lessons');

        return Scaffold(
          appBar: AppBar(
            title: const Text('التحديات والمتجر'),
            actions: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 16),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: AppColors.gold, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${progress.xp} XP',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 36),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF273D68), AppColors.purple],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.flag_circle_rounded, color: AppColors.gold, size: 52),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'اصنع عادة تعلّم يومية',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'أنجز المهام واحصل على نقاط خبرة وقلوب إضافية لحماية سلسلتك.',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeading(title: 'مهام اليوم'),
              const SizedBox(height: 11),
              _InteractiveChallengeTile(
                icon: Icons.menu_book_rounded,
                color: AppColors.primary,
                title: 'أكمل درساً واحداً اليوم',
                progress: (progress.todayCompletedLessons / 1).clamp(0.0, 1.0),
                progressText: '${progress.todayCompletedLessons}/1',
                rewardText: '+20 XP',
                isCompleted: daily1Done,
                isClaimed: daily1Claimed,
                onClaim: () {
                  progress.claimChallenge('daily_lesson', xpReward: 20);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('مبارك! حصلت على 20 XP.')),
                  );
                },
              ),
              const SizedBox(height: 10),
              _InteractiveChallengeTile(
                icon: Icons.track_changes_rounded,
                color: AppColors.gold,
                title: 'أجب عن 5 أسئلة صحيحة',
                progress: (progress.todayCorrectAnswers / 5).clamp(0.0, 1.0),
                progressText: '${progress.todayCorrectAnswers}/5',
                rewardText: '+15 XP',
                isCompleted: daily2Done,
                isClaimed: daily2Claimed,
                onClaim: () {
                  progress.claimChallenge('daily_correct', xpReward: 15);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('مبارك! حصلت على 15 XP.')),
                  );
                },
              ),
              const SizedBox(height: 10),
              _InteractiveChallengeTile(
                icon: Icons.local_fire_department_rounded,
                color: const Color(0xFFF28C28),
                title: 'حافظ على شعلة الأيام مشتعلة',
                progress: daily3Done ? 1.0 : 0.0,
                progressText: daily3Done ? '1/1' : '0/1',
                rewardText: '+10 XP',
                isCompleted: daily3Done,
                isClaimed: daily3Claimed,
                onClaim: () {
                  progress.claimChallenge('daily_streak', xpReward: 10);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('مبارك! حصلت على 10 XP.')),
                  );
                },
              ),
              const SizedBox(height: 24),
              const SectionHeading(title: 'التحدي الأسبوعي'),
              const SizedBox(height: 11),
              _InteractiveChallengeTile(
                icon: Icons.calendar_month_rounded,
                color: AppColors.purple,
                title: 'أكمل 7 دروس خلال هذا الأسبوع',
                progress: (weeklyLessons / 7).clamp(0.0, 1.0),
                progressText: '$weeklyLessons/7',
                rewardText: '+50 XP · ❄️ تجميد',
                isCompleted: weeklyDone,
                isClaimed: weeklyClaimed,
                onClaim: () {
                  progress.claimChallenge('weekly_lessons', xpReward: 50, freezeReward: 1);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('إنجاز عظيم! حصلت على 50 XP وتجميد سلسلة.')),
                  );
                },
              ),
              const SizedBox(height: 28),
              const SectionHeading(title: 'متجر نقاط الخبرة (XP Store)'),
              const SizedBox(height: 12),
              _StoreItemCard(
                icon: Icons.ac_unit_rounded,
                color: Colors.lightBlueAccent,
                title: 'تجميد السلسلة (Streak Freeze)',
                subtitle: 'يحمي سلسلتك ليوم كامل عند الانشغال أو السفر. لديك: ${progress.streakFreezes}',
                price: 100,
                userXp: progress.xp,
                onBuy: () => _buyStreakFreeze(context),
              ),
              const SizedBox(height: 10),
              _StoreItemCard(
                icon: Icons.favorite_rounded,
                color: AppColors.error,
                title: 'شحن القلوب بالكامل (Heart Refill)',
                subtitle: 'استعد القلوب الخمسة فوراً لتواصل التعلّم دون انتظار.',
                price: 50,
                userXp: progress.xp,
                onBuy: () => _buyHeartRefill(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StoreItemCard extends StatelessWidget {
  const _StoreItemCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.userXp,
    required this.onBuy,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final int price;
  final int userXp;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final canAfford = userXp >= price;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.muted, fontSize: 12, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: onBuy,
              style: FilledButton.styleFrom(
                backgroundColor: canAfford ? AppColors.primary : Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: const Size(80, 42),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt_rounded, color: AppColors.gold, size: 16),
                  Text('$price', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractiveChallengeTile extends StatelessWidget {
  const _InteractiveChallengeTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.progress,
    required this.progressText,
    required this.rewardText,
    required this.isCompleted,
    required this.isClaimed,
    required this.onClaim,
  });

  final IconData icon;
  final Color color;
  final String title;
  final double progress;
  final String progressText;
  final String rewardText;
  final bool isCompleted;
  final bool isClaimed;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        rewardText,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                            backgroundColor: AppColors.primarySoft,
                            color: isCompleted ? AppColors.primary : color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        progressText,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (isClaimed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'مُكتمل',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              )
            else if (isCompleted)
              FilledButton(
                onPressed: onClaim,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(64, 38),
                ),
                child: const Text('استلم 🎁', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'قيد التقدم',
                  style: TextStyle(color: AppColors.muted, fontSize: 11.5, fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
