import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../progress_store.dart';
import '../widgets/app_widgets.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

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
          appBar: AppBar(title: const Text('التحديات والمهام')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
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
                    Icon(Icons.flag_circle_rounded,
                        color: AppColors.gold, size: 54),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('اصنع عادة تعلّم يومية',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900)),
                          SizedBox(height: 4),
                          Text('أنجز المهام واحصل على نقاط خبرة وقلوب إضافية',
                              style: TextStyle(color: Colors.white70)),
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
                title: 'أكمل درسًا واحدًا اليوم',
                progress: (progress.todayCompletedLessons / 1).clamp(0.0, 1.0),
                progressText: '${progress.todayCompletedLessons}/1',
                rewardText: '+20 XP',
                isCompleted: daily1Done,
                isClaimed: daily1Claimed,
                onClaim: () {
                  progress.claimChallenge('daily_lesson', xpReward: 20);
                  EmptyActionSnack.show(context, 'مبارك! حصلت على 20 XP.');
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
                  EmptyActionSnack.show(context, 'مبارك! حصلت على 15 XP.');
                },
              ),
              const SizedBox(height: 10),
              _InteractiveChallengeTile(
                icon: Icons.local_fire_department_rounded,
                color: const Color(0xFFF28C28),
                title: 'حافظ على سلسلة أيامك',
                progress: daily3Done ? 1.0 : 0.0,
                progressText: daily3Done ? 'مكتمل' : '0/1',
                rewardText: '+1 قلب',
                isCompleted: daily3Done,
                isClaimed: daily3Claimed,
                onClaim: () {
                  progress.claimChallenge('daily_streak', heartReward: 1);
                  EmptyActionSnack.show(context, 'تمت استعادة قلب إضافي!');
                },
              ),
              const SizedBox(height: 25),
              const SectionHeading(title: 'تحدي الأسبوع'),
              const SizedBox(height: 11),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SoftIcon(
                              icon: Icons.workspace_premium_rounded,
                              color: AppColors.purple,
                              backgroundColor: Color(0xFFEDE9FF)),
                          const SizedBox(width: 13),
                          const Expanded(
                              child: Text('رحلة طالب العلم',
                                  style: TextStyle(
                                      color: AppColors.ink,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900))),
                          if (weeklyClaimed)
                            const Chip(
                              backgroundColor: AppColors.primarySoft,
                              label: Text('تم الاستلام',
                                  style: TextStyle(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.w800)),
                            )
                          else if (weeklyDone)
                            FilledButton(
                              onPressed: () {
                                progress.claimChallenge('weekly_lessons',
                                    xpReward: 120, freezeReward: 1);
                                EmptyActionSnack.show(context,
                                    'مبارك! حصلت على 120 XP وتجميد سلسلة مجاني.');
                              },
                              child: const Text('استلام 120 XP'),
                            )
                          else
                            const Text('120 XP',
                                style: TextStyle(
                                    color: AppColors.purple,
                                    fontWeight: FontWeight.w900)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const Text('أكمل 7 دروس خلال هذا الأسبوع لكسب مكافأة كبرى',
                          style: TextStyle(color: AppColors.muted)),
                      const SizedBox(height: 11),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                            value: weeklyLessons / 7,
                            minHeight: 10,
                            color: AppColors.purple,
                            backgroundColor: const Color(0xFFEDE9FF)),
                      ),
                      const SizedBox(height: 7),
                      Text('$weeklyLessons من 7 دروس',
                          style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
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
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            SoftIcon(
                icon: icon,
                color: color,
                backgroundColor: color.withValues(alpha: .11)),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      borderRadius: BorderRadius.circular(9),
                      color: color,
                      backgroundColor: color.withValues(alpha: .12)),
                  const SizedBox(height: 5),
                  Text(progressText,
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (isClaimed)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 28),
              )
            else if (isCompleted)
              FilledButton(
                onPressed: onClaim,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 38),
                ),
                child: const Text('استلام', style: TextStyle(fontSize: 12)),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                    color: AppColors.goldSoft,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(rewardText,
                    style: const TextStyle(
                        color: Color(0xFF8D5F0C),
                        fontSize: 11,
                        fontWeight: FontWeight.w900)),
              ),
          ],
        ),
      ),
    );
  }
}
