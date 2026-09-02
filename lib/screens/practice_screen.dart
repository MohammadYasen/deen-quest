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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ممتاز! ليس لديك أخطاء بحاجة للمراجعة حالياً. ثبّت الله علمك 🎯'),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          title: 'تصحيح الأخطاء والتكرار',
          customQuestions: mistakes,
          isMistakeReview: true,
        ),
      ),
    );
  }

  void _openHeartRecovery(BuildContext context) {
    final questions = CurriculumData.allQuestions.take(3).toList();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          title: 'تدريب استرجاع القلوب ❤️',
          customQuestions: questions,
          isHeartRecovery: true,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('سيتم تفعيل دروس $title قريباً إن شاء الله.')),
      );
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
        final needsHearts = progress.hearts < GameProgress.maxHearts;

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
            children: [
              Text(
                'مركز التدريب والمراجعة',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              const Text(
                'ثبّت معلوماتك بالمران والتكرار المتباعد لتصل إلى الإتقان الكامل.',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 20),

              // Heart Recovery Banner if hearts < 5
              if (needsHearts) ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B1E3F), Color(0xFFC0392B)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withValues(alpha: .3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'قلوبك تحتاج شحناً (${progress.hearts}/5)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'تدرّب على 3 أسئلة خفيفة لتستعيد قلوبك كاملة مجاناً!',
                              style: TextStyle(color: Colors.white70, fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        onPressed: () => _openHeartRecovery(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF8B1E3F),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: const Size(60, 40),
                        ),
                        child: const Text('ابدأ ❤️', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // Spaced Repetition / Leitner Box Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: mistakesCount > 0 ? AppColors.error.withValues(alpha: .15) : AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          mistakesCount > 0 ? Icons.replay_rounded : Icons.verified_rounded,
                          color: mistakesCount > 0 ? AppColors.error : AppColors.primary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'صندوق التكرار المتباعد (SRS)',
                              style: TextStyle(
                                color: AppColors.ink,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mistakesCount > 0
                                  ? 'لديك $mistakesCount سؤالاً بحاجة لمراجعة وتثبيت.'
                                  : 'رائع! لا توجد أخطاء حالية، جميع المفاهيم مثبتة.',
                              style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => _openMistakesReview(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: mistakesCount > 0 ? AppColors.error : AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          minimumSize: const Size(70, 40),
                        ),
                        child: Text(
                          mistakesCount > 0 ? 'راجع الآن' : 'مكتمل',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Quick Review
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: AppColors.goldSoft,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: AppColors.gold,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تحدي المراجعة السريعة',
                              style: TextStyle(
                                color: AppColors.ink,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '5 أسئلة عشوائية من مختلف العلوم لاختبار سرعة بديهتك.',
                              style: TextStyle(color: AppColors.muted, fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => _openQuickPractice(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          minimumSize: const Size(70, 40),
                        ),
                        child: const Text('ابدأ ⚡', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 26),
              const SectionHeading(title: 'تدرّب حسب الباب الشرعي'),
              const SizedBox(height: 12),

              _TopicPracticeTile(
                title: 'العقيدة والإيمان',
                subtitle: 'أركان الإيمان، التوحيد، وأسماء الله الحسنى',
                icon: Icons.brightness_high_rounded,
                color: const Color(0xFFF4B740),
                onTap: () => _openTopic(context, 'aqeedah', 'العقيدة والإيمان'),
              ),
              const SizedBox(height: 10),
              _TopicPracticeTile(
                title: 'فقه الصلاة والعبادات',
                subtitle: 'أركان الصلاة، شروطها، وسننها',
                icon: Icons.mosque_rounded,
                color: const Color(0xFF3CCBC0),
                onTap: () => _openTopic(context, 'salah', 'فقه الصلاة والعبادات'),
              ),
              const SizedBox(height: 10),
              _TopicPracticeTile(
                title: 'السيرة النبوية الشريفة',
                subtitle: 'أحداث العهدين المكي والمدني وغزوات النبي ﷺ',
                icon: Icons.history_edu_rounded,
                color: const Color(0xFF7C4DFF),
                onTap: () => _openTopic(context, 'seerah', 'السيرة النبوية الشريفة'),
              ),
              const SizedBox(height: 10),
              _TopicPracticeTile(
                title: 'الأخلاق والآداب الإسلامية',
                subtitle: 'بر الوالدين، الصدق، الأمانة، وآداب الحديث',
                icon: Icons.favorite_border_rounded,
                color: const Color(0xFFE91E63),
                onTap: () => _openTopic(context, 'morals', 'الأخلاق والآداب'),
              ),
              const SizedBox(height: 10),
              _TopicPracticeTile(
                title: 'علوم القرآن الكريم',
                subtitle: 'أسباب النزول، السور المكية والمدنية',
                icon: Icons.auto_stories_rounded,
                color: const Color(0xFF009688),
                onTap: () => _openTopic(context, 'quran', 'علوم القرآن الكريم'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TopicPracticeTile extends StatelessWidget {
  const _TopicPracticeTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
