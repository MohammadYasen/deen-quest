import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/curriculum_data.dart';
import '../progress_store.dart';
import '../widgets/app_widgets.dart';
import 'lesson_screen.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  void _openMistakesReview(BuildContext context) {
    final mistakes = GameProgress.instance.mistakesReview;
    if (mistakes.isEmpty) {
      EmptyActionSnack.show(context, 'ممتاز! ليس لديك أخطاء بحاجة للمراجعة حالياً.');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          title: 'تصحيح الأخطاء',
          customQuestions: mistakes,
          isMistakeReview: true,
        ),
      ),
    );
  }

  void _openQuickPractice(BuildContext context) {
    final questions = CurriculumData.allQuestions.take(5).toList();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          title: 'مراجعة سريعة',
          customQuestions: questions,
        ),
      ),
    );
  }

  void _openTopic(BuildContext context, String topicId, String title) {
    final questions = CurriculumData.getQuestionsForTopic(topicId);
    if (questions.isEmpty) {
      EmptyActionSnack.show(context, 'سيتم تفعيل دروس $title قريباً إن شاء الله.');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          title: 'تدريب: $title',
          customQuestions: questions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: GameProgress.instance,
      builder: (context, _) {
        final progress = GameProgress.instance;
        final mistakesCount = progress.mistakesReview.length;

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
            children: [
              Text('التدريب اليومي',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              const Text('راجع المفاهيم وثبّت معلوماتك بالأسئلة والتكرار',
                  style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 20),
              _StreakCard(streak: progress.streak),
              const SizedBox(height: 22),
              const SectionHeading(title: 'أنماط التدريب'),
              const SizedBox(height: 12),
              _PracticeCard(
                title: 'مراجعة سريعة',
                subtitle: '5 أسئلة عشوائية منوعة',
                icon: Icons.replay_circle_filled_rounded,
                color: AppColors.primary,
                reward: '+20 XP',
                onTap: () => _openQuickPractice(context),
              ),
              const SizedBox(height: 12),
              _PracticeCard(
                title: 'صحّح أخطاءك',
                subtitle: mistakesCount > 0
                    ? '$mistakesCount أسئلة تحتاج إلى مراجعة'
                    : 'لا توجد أخطاء محفوظة حالياً',
                icon: Icons.healing_rounded,
                color: AppColors.error,
                reward: '+10 XP',
                onTap: () => _openMistakesReview(context),
              ),
              const SizedBox(height: 24),
              const SectionHeading(title: 'اختر مجالًا للتعلّم'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _TopicChip(
                    icon: Icons.favorite_rounded,
                    label: 'العقيدة',
                    color: AppColors.purple,
                    onTap: () => _openTopic(context, 'aqeedah', 'العقيدة'),
                  ),
                  _TopicChip(
                    icon: Icons.looks_5_rounded,
                    label: 'أركان الإسلام',
                    color: AppColors.primary,
                    onTap: () => _openTopic(context, 'pillars', 'أركان الإسلام'),
                  ),
                  _TopicChip(
                    icon: Icons.water_drop_rounded,
                    label: 'الصلاة والوضوء',
                    color: const Color(0xFF389B9B),
                    onTap: () => _openTopic(context, 'prayer', 'الصلاة والوضوء'),
                  ),
                  _TopicChip(
                    icon: Icons.auto_stories_rounded,
                    label: 'السيرة النبوية',
                    color: const Color(0xFFB77A34),
                    onTap: () => _openTopic(context, 'seerah', 'السيرة النبوية'),
                  ),
                  _TopicChip(
                    icon: Icons.menu_book_rounded,
                    label: 'القرآن وعلومه',
                    color: const Color(0xFF1B6A58),
                    onTap: () => _openTopic(context, 'quran', 'القرآن وعلومه'),
                  ),
                  _TopicChip(
                    icon: Icons.volunteer_activism_rounded,
                    label: 'الأخلاق والآداب',
                    color: const Color(0xFFE56B86),
                    onTap: () => _openTopic(context, 'ethics', 'الأخلاق والآداب'),
                  ),
                  _TopicChip(
                    icon: Icons.nights_stay_rounded,
                    label: 'المناسبات',
                    color: AppColors.gold,
                    onTap: () => _openTopic(context, 'occasions', 'المناسبات'),
                  ),
                  _TopicChip(
                    icon: Icons.history_edu_rounded,
                    label: 'التاريخ',
                    color: const Color(0xFF5A728E),
                    onTap: () => _openTopic(context, 'history', 'التاريخ الإسلامي'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SoftIcon(
                          icon: Icons.verified_user_rounded,
                          color: AppColors.purple,
                          backgroundColor: Color(0xFFEDE9FF)),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ملاحظة حول المحتوى والمصادر',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            const Text(
                              'المحتوى داخل التطبيق مخصص للتعلم التفاعلي ومدعم بالمصادر الموثوقة من القرآن والسنة، ويخضع للتدقيق المستمر ولا يغني عن سؤال أهل العلم في الفتاوى الخاصة.',
                              style: TextStyle(color: AppColors.muted, height: 1.5),
                            ),
                          ],
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

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    const days = ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.goldSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.gold.withValues(alpha: .4)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SoftIcon(
                  icon: Icons.local_fire_department_rounded,
                  color: Color(0xFFF28C28),
                  backgroundColor: Colors.white),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('سلسلة $streak أيام',
                        style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 19,
                            fontWeight: FontWeight.w900)),
                    const Text('تدرّب يومياً لتحافظ على استمرارية تعلّمك',
                        style: TextStyle(color: AppColors.muted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              days.length,
              (index) => Column(
                children: [
                  Text(days[index],
                      style: const TextStyle(
                          color: AppColors.muted, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 7),
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: index < (streak % 7 == 0 && streak > 0 ? 7 : (streak % 7))
                        ? AppColors.gold
                        : Colors.white,
                    child: Icon(
                        index < (streak % 7 == 0 && streak > 0 ? 7 : (streak % 7))
                            ? Icons.check_rounded
                            : Icons.bolt_rounded,
                        color: index < (streak % 7 == 0 && streak > 0 ? 7 : (streak % 7))
                            ? Colors.white
                            : AppColors.gold,
                        size: 19),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticeCard extends StatelessWidget {
  const _PracticeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.reward,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String reward;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
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
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                    color: AppColors.goldSoft,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(reward,
                    style: const TextStyle(
                        color: Color(0xFF9A6610),
                        fontSize: 12,
                        fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, color: color, size: 19),
      label: Text(label),
      labelStyle: const TextStyle(fontWeight: FontWeight.w800),
      backgroundColor: Colors.white,
      side: const BorderSide(color: AppColors.line),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      onPressed: onTap,
    );
  }
}
