import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../data/curriculum_data.dart';
import '../progress_store.dart';
import 'lesson_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = PageController();
  int _worldIndex = 0;

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
      lessons: ['نزول القرآن', 'السور والآيات', 'الحديث النبوي', 'مراجعة شاملة'],
    ),
    _World(
      asset: 'assets/worlds/crescent_observatory.png',
      eyebrow: 'الوحدة الخامسة',
      title: 'المناسبات والتاريخ',
      subtitle: 'التقويم الهجري · محطات تاريخية',
      accent: Color(0xFFFFD16F),
      lessons: ['التقويم الهجري', 'الأشهر الحرم', 'المناسبات الكبرى', 'مراجعة الختام'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    GameProgress.instance.addListener(_progressChanged);
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: AppColors.darkSurface,
          content: const Row(
            children: [
              Icon(Icons.lock_rounded, color: AppColors.gold, size: 22),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'أكمل المرحلة السابقة أولاً لفتح هذا الدرس المبارك.',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
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
            const Icon(Icons.favorite_rounded, color: AppColors.error, size: 64),
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
                    const SnackBar(content: Text('تمت استعادة القلوب بالكامل! ❤️')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('نقاط الخبرة غير كافية (تحتاج 50 XP)')),
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
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
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
        const SnackBar(content: Text('لقد حصلت على مكافأة هذا الصندوق بالفعل! 🎁')),
      );
      return;
    }
    if (!progress.canClaimChest(worldIndex)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أكمل جميع دروس هذه الوحدة أولاً لفتح الصندوق 🏆')),
      );
      return;
    }

    if (progress.hapticEnabled) HapticFeedback.mediumImpact();
    final claimed = progress.claimWorldChest(worldIndex);
    if (claimed) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                child: const Icon(Icons.lock_open_rounded, color: AppColors.gold, size: 50),
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
                  _RewardBadge(icon: Icons.bolt_rounded, label: '+75 XP', color: AppColors.gold),
                  SizedBox(width: 14),
                  _RewardBadge(icon: Icons.favorite_rounded, label: '+2 قلوب', color: AppColors.error),
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
  const _RewardBadge({required this.icon, required this.label, required this.color});
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
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900)),
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
    required this.onLessonTap,
    required this.onChestTap,
  });

  final _World world;
  final int worldNumber;
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_rounded, color: Colors.white70, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'أكمل الوحدة السابقة لفتح هذا العالم',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                _WindingPathLayout(
                  worldNumber: worldNumber,
                  lessons: world.lessons,
                  accent: world.accent,
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
  const _StatusChip({required this.icon, required this.color, required this.text});
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
            backgroundColor: unlocked
                ? world.accent.withValues(alpha: .22)
                : Colors.white12,
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
    required this.worldNumber,
    required this.lessons,
    required this.accent,
    required this.onLessonTap,
    required this.onChestTap,
  });

  final int worldNumber;
  final List<String> lessons;
  final Color accent;
  final ValueChanged<int> onLessonTap;
  final VoidCallback onChestTap;

  @override
  Widget build(BuildContext context) {
    final progress = GameProgress.instance;
    final totalHeight = (lessons.length * 105.0) + 110.0;

    return SizedBox(
      height: totalHeight,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final centerX = width / 2;
          final amplitude = math.min(width * 0.28, 95.0);

          final nodePositions = <Offset>[];
          for (int i = 0; i < lessons.length; i++) {
            final xOffset = math.sin(i * (math.pi / 1.5)) * amplitude;
            final yOffset = 45.0 + (i * 105.0);
            nodePositions.add(Offset(centerX + xOffset, yOffset));
          }
          final chestPos = Offset(centerX, 45.0 + (lessons.length * 105.0));

          return Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(width, totalHeight),
                painter: _SmoothSnakePainter(
                  points: [...nodePositions, chestPos],
                  accent: accent,
                ),
              ),
              ...List.generate(lessons.length, (index) {
                final unlocked = progress.isLessonUnlocked(worldNumber, index);
                final completed = progress.isLessonCompleted(worldNumber, index);
                final current = unlocked && !completed;
                final stars = progress.getLessonStars(worldNumber, index);
                final pos = nodePositions[index];

                return Positioned(
                  left: pos.dx - 36,
                  top: pos.dy - 36,
                  child: _SnakeLessonNode(
                    title: lessons[index],
                    completed: completed,
                    current: current,
                    unlocked: unlocked,
                    stars: stars,
                    accent: accent,
                    onTap: () => onLessonTap(index),
                  ),
                );
              }),
              Positioned(
                left: chestPos.dx - 45,
                top: chestPos.dy - 40,
                child: _MilestoneChest(
                  worldIndex: worldNumber,
                  onTap: onChestTap,
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
  _SmoothSnakePainter({required this.points, required this.accent});
  final List<Offset> points;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midY = (p0.dy + p1.dy) / 2;
      path.cubicTo(p0.dx, midY, p1.dx, midY, p1.dx, p1.dy);
    }

    final glowPaint = Paint()
      ..color = accent.withValues(alpha: .28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: .35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, trackPaint);
  }

  @override
  bool shouldRepaint(covariant _SmoothSnakePainter oldDelegate) => false;
}

class _SnakeLessonNode extends StatefulWidget {
  const _SnakeLessonNode({
    required this.title,
    required this.completed,
    required this.current,
    required this.unlocked,
    required this.stars,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final bool completed;
  final bool current;
  final bool unlocked;
  final int stars;
  final Color accent;
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

    return GestureDetector(
      onTap: widget.onTap,
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
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.current
                        ? AppColors.gold.withValues(alpha: .6)
                        : color.withValues(alpha: .4),
                    blurRadius: widget.current ? 20 : 10,
                    offset: const Offset(0, 5),
                  ),
                ],
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
                size: 34,
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
                  i < widget.stars ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: AppColors.gold,
                  size: 14,
                ),
              ),
            ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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
