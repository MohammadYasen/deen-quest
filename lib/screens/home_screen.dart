import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../data/curriculum_data.dart';
import '../progress_store.dart';
import '../services/auth_service.dart';
import '../widgets/certificate_dialog.dart';
import 'lesson_screen.dart';
import 'shop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _controller;
  late int _worldIndex;

  static const _worlds = [
    _World(
      asset: 'assets/worlds/desert_night.png',
      eyebrow: 'الوحدة الأولى',
      title: 'أساسيات الإسلام',
      subtitle: 'الأركان · الصلاة · الوضوء',
      accent: Color(0xFFF4B740),
      lessons: ['أركان الإسلام', 'الصلوات الخمس', 'الوضوء', 'مراجعة الوحدة'],
    ),
    _World(
      asset: 'assets/worlds/mosque_dawn.png',
      eyebrow: 'الوحدة الثانية',
      title: 'السيرة النبوية',
      subtitle: 'مكة · الهجرة · المدينة',
      accent: Color(0xFF3CCBC0),
      lessons: ['قبل البعثة', 'نزول الوحي', 'الهجرة النبوية', 'بناء المجتمع'],
    ),
    _World(
      asset: 'assets/worlds/andalusian_garden.png',
      eyebrow: 'الوحدة الثالثة',
      title: 'الأخلاق والآداب',
      subtitle: 'الصدق · بر الوالدين · الإحسان',
      accent: Color(0xFFFFC65B),
      lessons: ['خلق الصدق', 'بر الوالدين', 'آداب الحديث', 'الإحسان إلى الناس'],
    ),
    _World(
      asset: 'assets/worlds/heritage_library.png',
      eyebrow: 'الوحدة الرابعة',
      title: 'القرآن والحديث',
      subtitle: 'علوم أساسية · أحاديث مختارة',
      accent: Color(0xFF49C8C0),
      lessons: [
        'نزول القرآن',
        'السور والآيات',
        'الحديث النبوي',
        'مراجعة شاملة'
      ],
    ),
    _World(
      asset: 'assets/worlds/crescent_observatory.png',
      eyebrow: 'الوحدة الخامسة',
      title: 'المناسبات والتاريخ',
      subtitle: 'التقويم الهجري · محطات تاريخية',
      accent: Color(0xFFFFD16F),
      lessons: [
        'التقويم الهجري',
        'الأشهر الحرم',
        'المناسبات الكبرى',
        'مراجعة الختام'
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    final initialWorld = _activeWorldIndex;
    _worldIndex = initialWorld;
    _controller = PageController(initialPage: initialWorld);
    GameProgress.instance.addListener(_progressChanged);
  }

  int get _activeWorldIndex {
    final current =
        GameProgress.instance.completedSteps ~/ GameProgress.lessonsPerWorld;
    return current.clamp(0, _worlds.length - 1);
  }

  void _progressChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    GameProgress.instance.removeListener(_progressChanged);
    _controller.dispose();
    super.dispose();
  }

  void _openLesson(int worldIndex, _World world, int lessonIndex) {
    final progress = GameProgress.instance;
    if (!progress.isLessonUnlocked(worldIndex, lessonIndex)) {
      if (progress.hapticEnabled) HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: AppColors.darkSurface,
          content: const Row(
            children: [
              Icon(Icons.lock_rounded, color: AppColors.gold, size: 22),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'أكمل المرحلة السابقة أولاً لفتح هذا الدرس المبارك.',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    if (progress.hearts <= 0) {
      if (progress.hapticEnabled) HapticFeedback.vibrate();
      _showHeartRefillDialog();
      return;
    }

    if (progress.hapticEnabled) HapticFeedback.lightImpact();
    final questions = CurriculumData.getQuestionsForLesson(
      worldIndex: worldIndex,
      lessonIndex: lessonIndex,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          title: world.lessons[lessonIndex],
          worldIndex: worldIndex,
          lessonIndex: lessonIndex,
          customQuestions: questions,
        ),
      ),
    );
  }

  void _showHeartRefillDialog() {
    final progress = GameProgress.instance;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .3),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: .3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.favorite_rounded,
                color: AppColors.error, size: 64),
            const SizedBox(height: 12),
            const Text(
              'نفدت القلوب لديك!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'تسترجع قلباً كل 30 دقيقة، أو يمكنك إعادة الشحن الآن عبر نقاط الخبرة XP أو تدريب مجاني.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, height: 1.4),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                if (progress.buyHeartRefill(cost: 50)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('تمت استعادة القلوب بالكامل! ❤️')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('نقاط الخبرة غير كافية (تحتاج 50 XP)')),
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(50),
              ),
              icon: const Icon(Icons.bolt_rounded, color: AppColors.gold),
              label: const Text('شحن القلوب بالكامل (50 XP)'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
              child: const Text('سأنتظر لاحقاً'),
            ),
          ],
        ),
      ),
    );
  }

  void _claimChest(int worldIndex) {
    final progress = GameProgress.instance;
    if (progress.isChestClaimed(worldIndex)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('لقد حصلت على مكافأة هذا الصندوق بالفعل! 🎁')),
      );
      return;
    }
    if (!progress.canClaimChest(worldIndex)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('أكمل جميع دروس هذه الوحدة أولاً لفتح الصندوق 🏆')),
      );
      return;
    }

    if (progress.hapticEnabled) HapticFeedback.mediumImpact();
    final claimed = progress.claimWorldChest(worldIndex);
    if (claimed) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.goldSoft,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 3),
                ),
                child: const Icon(Icons.lock_open_rounded,
                    color: AppColors.gold, size: 50),
              ),
              const SizedBox(height: 16),
              const Text(
                'مبارك! فُتح الصندوق',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'حصلت على مكافأة إتمام الوحدة بنجاح:',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RewardBadge(
                      icon: Icons.bolt_rounded,
                      label: '+75 XP',
                      color: AppColors.gold),
                  SizedBox(width: 14),
                  _RewardBadge(
                      icon: Icons.favorite_rounded,
                      label: '+2 قلوب',
                      color: AppColors.error),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('رائع، الحمد لله'),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: _worlds.length,
          onPageChanged: (index) => setState(() => _worldIndex = index),
          itemBuilder: (context, index) {
            final world = _worlds[index];
            return _WorldPage(
              world: world,
              worldNumber: index,
              showTraveler: index == _activeWorldIndex,
              onLessonTap: (lesson) => _openLesson(index, world, lesson),
              onChestTap: () => _claimChest(index),
            );
          },
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 15,
          child: IgnorePointer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _worlds.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: index == _worldIndex ? 26 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: index == _worldIndex
                        ? _worlds[index].accent
                        : Colors.white54,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black12),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RewardBadge extends StatelessWidget {
  const _RewardBadge(
      {required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _World {
  const _World({
    required this.asset,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.lessons,
  });

  final String asset;
  final String eyebrow;
  final String title;
  final String subtitle;
  final Color accent;
  final List<String> lessons;
}

class _WorldPage extends StatelessWidget {
  const _WorldPage({
    required this.world,
    required this.worldNumber,
    required this.showTraveler,
    required this.onLessonTap,
    required this.onChestTap,
  });

  final _World world;
  final int worldNumber;
  final bool showTraveler;
  final ValueChanged<int> onLessonTap;
  final VoidCallback onChestTap;

  @override
  Widget build(BuildContext context) {
    final progress = GameProgress.instance;
    final worldUnlocked = progress.isWorldUnlocked(worldNumber);

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          world.asset,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF132238),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: .72),
                Colors.black.withValues(alpha: .35),
                Colors.black.withValues(alpha: .82),
              ],
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 50),
            child: Column(
              children: [
                _HeaderStatus(accent: world.accent),
                const SizedBox(height: 14),
                _WorldInfoCard(world: world, unlocked: worldUnlocked),
                const SizedBox(height: 12),
                if (!worldUnlocked)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_rounded,
                            color: Colors.white70, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'أكمل الوحدة السابقة لفتح هذا العالم',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                _WindingPathLayout(
                  world: world,
                  worldNumber: worldNumber,
                  lessons: world.lessons,
                  accent: world.accent,
                  showTraveler: showTraveler,
                  onLessonTap: onLessonTap,
                  onChestTap: onChestTap,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderStatus extends StatelessWidget {
  const _HeaderStatus({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final progress = GameProgress.instance;
    return Row(
      children: [
        Flexible(
          child: _StatusChip(
            icon: Icons.local_fire_department_rounded,
            color: const Color(0xFFF28C28),
            text: '${progress.streak}',
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: _StatusChip(
            icon: Icons.bolt_rounded,
            color: AppColors.gold,
            text: '${progress.xp}',
          ),
        ),
        if (progress.streakFreezes > 0) ...[
          const SizedBox(width: 8),
          Flexible(
            child: _StatusChip(
              icon: Icons.ac_unit_rounded,
              color: Colors.lightBlueAccent,
              text: '${progress.streakFreezes}',
            ),
          ),
        ],
        const Spacer(),
        IconButton(
          tooltip: 'متجر النور',
          style: IconButton.styleFrom(
            backgroundColor: Colors.black45,
            padding: const EdgeInsets.all(8),
          ),
          icon: const Icon(Icons.storefront_rounded, color: AppColors.gold, size: 22),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ShopScreen()),
            );
          },
        ),
        const SizedBox(width: 8),
        Flexible(
          child: _StatusChip(
            icon: Icons.favorite_rounded,
            color: AppColors.error,
            text: '${progress.hearts}',
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(
      {required this.icon, required this.color, required this.text});
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 5),
          Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorldInfoCard extends StatelessWidget {
  const _WorldInfoCard({required this.world, required this.unlocked});
  final _World world;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .52),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  world.eyebrow,
                  style: TextStyle(
                    color: world.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  world.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  world.subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor:
                unlocked ? world.accent.withValues(alpha: .22) : Colors.white12,
            child: Icon(
              unlocked ? Icons.explore_rounded : Icons.lock_rounded,
              color: unlocked ? world.accent : Colors.white60,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _WindingPathLayout extends StatelessWidget {
  const _WindingPathLayout({
    required this.world,
    required this.worldNumber,
    required this.lessons,
    required this.accent,
    required this.showTraveler,
    required this.onLessonTap,
    required this.onChestTap,
  });

  final _World world;
  final int worldNumber;
  final List<String> lessons;
  final Color accent;
  final bool showTraveler;
  final ValueChanged<int> onLessonTap;
  final VoidCallback onChestTap;

  @override
  Widget build(BuildContext context) {
    final progress = GameProgress.instance;
    final totalHeight = (lessons.length * 118.0) + 258.0;

    return SizedBox(
      height: totalHeight,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final centerX = width / 2;
          final maxAmplitude = math.min(width * 0.30, 108.0);

          final nodePositions = <Offset>[];
          for (int i = 0; i < lessons.length; i++) {
            final depth = lessons.length == 1 ? 1.0 : i / lessons.length;
            final perspectiveAmplitude = maxAmplitude * (0.48 + (depth * 0.52));
            final xOffset = math.sin(i * 1.62) * perspectiveAmplitude;
            final yOffset = 58.0 + (i * 118.0);
            nodePositions.add(Offset(centerX + xOffset, yOffset));
          }
          final chestPos = Offset(
            centerX + (math.sin(lessons.length * 1.62) * maxAmplitude),
            58.0 + (lessons.length * 118.0),
          );
          final masteryPos = Offset(
            centerX,
            58.0 + ((lessons.length + 1) * 118.0),
          );

          var completedSegments = 0;
          var activeLesson = -1;
          for (int i = 0; i < lessons.length; i++) {
            if (progress.isLessonCompleted(worldNumber, i)) {
              completedSegments = i + 1;
            } else if (activeLesson == -1 &&
                progress.isLessonUnlocked(worldNumber, i)) {
              activeLesson = i;
            }
          }

          final travelerPoint =
              activeLesson >= 0 ? nodePositions[activeLesson] : chestPos;
          final travelerDepth =
              activeLesson >= 0 ? activeLesson / lessons.length : 1.0;
          final travelerScale = 0.76 + (travelerDepth * 0.24);
          final travelerOnLeft = travelerPoint.dx < centerX;
          final travelerLeft =
              (travelerPoint.dx + (travelerOnLeft ? 62.0 : -132.0))
                  .clamp(2.0, math.max(2.0, width - 78.0))
                  .toDouble();

          return Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(width, totalHeight),
                painter: _SmoothSnakePainter(
                  points: [...nodePositions, chestPos, masteryPos],
                  accent: accent,
                  completedSegments: completedSegments,
                ),
              ),
              ...List.generate(lessons.length, (index) {
                final unlocked = progress.isLessonUnlocked(worldNumber, index);
                final completed =
                    progress.isLessonCompleted(worldNumber, index);
                final current = unlocked && !completed;
                final stars = progress.getLessonStars(worldNumber, index);
                final pos = nodePositions[index];
                final depth =
                    lessons.length == 1 ? 1.0 : index / lessons.length;

                return Positioned(
                  left: pos.dx - 58,
                  top: pos.dy - 39,
                  child: _SnakeLessonNode(
                    title: lessons[index],
                    completed: completed,
                    current: current,
                    unlocked: unlocked,
                    stars: stars,
                    accent: accent,
                    depthScale: 0.84 + (depth * 0.16),
                    onTap: () => onLessonTap(index),
                  ),
                );
              }),
              if (showTraveler)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 950),
                  curve: Curves.easeInOutCubic,
                  left: travelerLeft,
                  top: travelerPoint.dy - (112.0 * travelerScale),
                  child: _JourneyTraveler(scale: travelerScale),
                ),
              Positioned(
                left: chestPos.dx - 45,
                top: chestPos.dy - 40,
                child: _MilestoneChest(
                  worldIndex: worldNumber,
                  onTap: onChestTap,
                ),
              ),
              Positioned(
                left: masteryPos.dx - 45,
                top: masteryPos.dy - 40,
                child: _MasteryBossNode(
                  world: world,
                  worldIndex: worldNumber,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SmoothSnakePainter extends CustomPainter {
  _SmoothSnakePainter({
    required this.points,
    required this.accent,
    required this.completedSegments,
  });
  final List<Offset> points;
  final Color accent;
  final int completedSegments;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midY = (p0.dy + p1.dy) / 2;
      final segment = Path()
        ..moveTo(p0.dx, p0.dy)
        ..cubicTo(p0.dx, midY, p1.dx, midY, p1.dx, p1.dy);
      final depth = (i + 1) / (points.length - 1);
      final roadWidth = 10.0 + (depth * 12.0);

      canvas.drawPath(
        segment,
        Paint()
          ..color = Colors.black.withValues(alpha: .34)
          ..style = PaintingStyle.stroke
          ..strokeWidth = roadWidth + 8
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawPath(
        segment,
        Paint()
          ..color = const Color(0xFF7B6649).withValues(alpha: .72)
          ..style = PaintingStyle.stroke
          ..strokeWidth = roadWidth
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawPath(
        segment,
        Paint()
          ..color = Colors.white.withValues(alpha: .34)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2 + (depth * 1.8)
          ..strokeCap = StrokeCap.round,
      );

      if (i < completedSegments) {
        canvas.drawPath(
          segment,
          Paint()
            ..color = accent.withValues(alpha: .86)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4.0 + (depth * 3.0)
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SmoothSnakePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.accent != accent ||
        oldDelegate.completedSegments != completedSegments;
  }
}

class _JourneyTraveler extends StatefulWidget {
  const _JourneyTraveler({required this.scale});

  final double scale;

  @override
  State<_JourneyTraveler> createState() => _JourneyTravelerState();
}

class _JourneyTravelerState extends State<_JourneyTraveler>
    with SingleTickerProviderStateMixin {
  late final AnimationController _walkController;
  late final Animation<double> _walkCycle;

  @override
  void initState() {
    super.initState();
    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    )..repeat(reverse: true);
    _walkCycle = CurvedAnimation(
      parent: _walkController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _walkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'موقعك الحالي على مسار التعلّم',
      child: AnimatedBuilder(
        animation: _walkCycle,
        builder: (context, child) {
          final phase = _walkCycle.value;
          return Transform.translate(
            offset: Offset(0, -2 - (phase * 4)),
            child: Transform.rotate(
              angle: (phase - .5) * .025,
              child: child,
            ),
          );
        },
        child: Transform.scale(
          scale: widget.scale,
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 78,
            height: 118,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  bottom: 3,
                  child: Container(
                    width: 52,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .38),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: .28),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Image.asset(
                    'assets/characters/nour_traveler.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.directions_walk_rounded,
                      color: AppColors.gold,
                      size: 58,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 6),
                      ],
                    ),
                    child: const Text(
                      'أنت هنا',
                      style: TextStyle(
                        color: Color(0xFF14243E),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SnakeLessonNode extends StatefulWidget {
  const _SnakeLessonNode({
    required this.title,
    required this.completed,
    required this.current,
    required this.unlocked,
    required this.stars,
    required this.accent,
    required this.depthScale,
    required this.onTap,
  });

  final String title;
  final bool completed;
  final bool current;
  final bool unlocked;
  final int stars;
  final Color accent;
  final double depthScale;
  final VoidCallback onTap;

  @override
  State<_SnakeLessonNode> createState() => _SnakeLessonNodeState();
}

class _SnakeLessonNodeState extends State<_SnakeLessonNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.current) {
      _pulseController.repeat(reverse: true);
    }

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.completed
        ? AppColors.primary
        : widget.current
            ? AppColors.gold
            : Colors.grey.shade700;

    return Transform.scale(
      scale: widget.depthScale,
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: 116,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: widget.current ? _scaleAnimation.value : 1.0,
                    child: child,
                  );
                },
                child: SizedBox(
                  width: 82,
                  height: 70,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                        top: 17,
                        child: Container(
                          width: 82,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color.lerp(color, Colors.black, .34),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: widget.current
                                    ? AppColors.gold.withValues(alpha: .62)
                                    : color.withValues(alpha: .38),
                                blurRadius: widget.current ? 22 : 12,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 82,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color.lerp(color, Colors.white, .26)!,
                              color,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(29),
                          border: Border.all(
                            color: Colors.white,
                            width: widget.current ? 3.5 : 2.5,
                          ),
                        ),
                        child: Icon(
                          widget.completed
                              ? Icons.check_rounded
                              : widget.current
                                  ? Icons.play_arrow_rounded
                                  : Icons.lock_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              if (widget.completed)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    3,
                    (i) => Icon(
                      i < widget.stars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: AppColors.gold,
                      size: 14,
                    ),
                  ),
                ),
              const SizedBox(height: 2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MilestoneChest extends StatelessWidget {
  const _MilestoneChest({required this.worldIndex, required this.onTap});
  final int worldIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = GameProgress.instance;
    final isClaimed = progress.isChestClaimed(worldIndex);
    final canClaim = progress.canClaimChest(worldIndex);

    final color = isClaimed
        ? Colors.white54
        : canClaim
            ? AppColors.gold
            : Colors.grey.shade600;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: canClaim ? AppColors.goldSoft : Colors.black45,
              shape: BoxShape.circle,
              boxShadow: canClaim
                  ? [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: .55),
                        blurRadius: 22,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
              border: Border.all(color: color, width: canClaim ? 3 : 2),
            ),
            child: Icon(
              isClaimed
                  ? Icons.check_circle_outline_rounded
                  : canClaim
                      ? Icons.card_giftcard_rounded
                      : Icons.lock_outline_rounded,
              color: color,
              size: 42,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: canClaim ? AppColors.gold : Colors.white12,
              ),
            ),
            child: Text(
              isClaimed
                  ? 'تم فتح الصندوق'
                  : canClaim
                      ? 'افتح الكنز! 🎁'
                      : 'صندوق الوحدة 🔒',
              style: TextStyle(
                color: canClaim ? AppColors.gold : Colors.white70,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MasteryBossNode extends StatelessWidget {
  const _MasteryBossNode({
    required this.world,
    required this.worldIndex,
  });

  final _World world;
  final int worldIndex;

  @override
  Widget build(BuildContext context) {
    final progress = GameProgress.instance;
    final isMastered = progress.isWorldMastered(worldIndex);
    final canAttempt = progress.canAttemptWorldMastery(worldIndex);

    final color = isMastered
        ? AppColors.gold
        : canAttempt
            ? AppColors.primary
            : Colors.grey.shade600;

    return GestureDetector(
      onTap: () {
        if (!canAttempt) {
          if (progress.hapticEnabled) HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.darkSurface,
              content: Text('أكمل جميع دروس هذه الوحدة أولاً لفتح تحدي الختم ونيل وسام الإتقان والشهادة! 🌟'),
            ),
          );
          return;
        }

        if (isMastered) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: const Row(
                children: [
                  Icon(Icons.workspace_premium_rounded, color: AppColors.gold),
                  SizedBox(width: 8),
                  Text('وسام ختم العالم'),
                ],
              ),
              content: Text(
                'ما شاء الله! لقد اجتزت تحدي ختم «${world.title}» بنجاح وتستحق وسام الإتقان.',
                style: const TextStyle(height: 1.5),
              ),
              actions: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    final user = AuthService.instance.currentUser;
                    final now = DateTime.now();
                    final dateStr = '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
                    CertificateDialog.show(
                      context,
                      userName: user?.displayName ?? 'طالب النور المبارك',
                      worldTitle: world.title,
                      worldSubtitle: world.subtitle,
                      dateStr: dateStr,
                    );
                  },
                  icon: const Icon(Icons.description_rounded, color: AppColors.gold),
                  label: const Text('عرض الشهادة 📜'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LessonScreen(
                          title: 'تحدي ختم: ${world.title}',
                          worldIndex: worldIndex,
                          isMasteryTrial: true,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('إعادة التحدي'),
                ),
              ],
            ),
          );
          return;
        }

        // Open the mastery trial!
        if (progress.hapticEnabled) HapticFeedback.mediumImpact();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LessonScreen(
              title: 'تحدي ختم: ${world.title}',
              worldIndex: worldIndex,
              isMasteryTrial: true,
            ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: isMastered
                  ? AppColors.gold.withValues(alpha: 0.22)
                  : canAttempt
                      ? AppColors.primaryDark
                      : Colors.black45,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: isMastered ? 3.5 : 2.5),
              boxShadow: (isMastered || canAttempt)
                  ? [
                      BoxShadow(
                        color: (isMastered ? AppColors.gold : AppColors.primary)
                            .withValues(alpha: 0.45),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isMastered
                  ? Icons.workspace_premium_rounded
                  : canAttempt
                      ? Icons.military_tech_rounded
                      : Icons.lock_outline_rounded,
              color: color,
              size: 42,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isMastered ? AppColors.gold : Colors.white12,
              ),
            ),
            child: Text(
              isMastered ? 'مُتقَن 👑' : 'تحدي الختم ⚔️',
              style: TextStyle(
                color: isMastered ? AppColors.gold : Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
