import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/curriculum_data.dart';
import '../progress_store.dart';
import '../widgets/app_widgets.dart';
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
      lessons: ['قبل البعثة', 'نزول الوحي', 'الهجرة', 'بناء المجتمع'],
    ),
    _World(
      asset: 'assets/worlds/andalusian_garden.png',
      eyebrow: 'الوحدة الثالثة',
      title: 'الأخلاق والآداب',
      subtitle: 'الصدق · الأمانة · الإحسان',
      accent: Color(0xFFFFC65B),
      lessons: ['الصدق', 'بر الوالدين', 'آداب الحديث', 'الإحسان'],
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
        'مراجعة الوحدة'
      ],
    ),
    _World(
      asset: 'assets/worlds/crescent_observatory.png',
      eyebrow: 'الوحدة الخامسة',
      title: 'المناسبات والتاريخ',
      subtitle: 'التقويم الهجري · محطات تاريخية',
      accent: Color(0xFFFFD16F),
      lessons: ['التقويم الهجري', 'الأشهر الحرم', 'المناسبات', 'مراجعة الوحدة'],
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
    if (!GameProgress.instance.isLessonUnlocked(worldIndex, lessonIndex)) {
      EmptyActionSnack.show(
          context, 'أكمل المرحلة السابقة أولًا لفتح هذا الدرس.');
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: _worlds.length,
          onPageChanged: (value) => setState(() => _worldIndex = value),
          itemBuilder: (context, index) {
            final world = _worlds[index];
            return _WorldPage(
              world: world,
              worldNumber: index,
              onLessonTap: (lesson) => _openLesson(index, world, lesson),
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
                  width: index == _worldIndex ? 25 : 8,
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
  });

  final _World world;
  final int worldNumber;
  final ValueChanged<int> onLessonTap;

  @override
  Widget build(BuildContext context) {
    final progress = GameProgress.instance;
    final worldUnlocked = progress.isWorldUnlocked(worldNumber);
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(world.asset, fit: BoxFit.cover),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x99051621), Color(0x18051621), Color(0x99051621)],
              stops: [0, .48, 1],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 38),
            child: Column(
              children: [
                _HeaderStatus(accent: world.accent),
                const SizedBox(height: 18),
                _WorldInfoCard(world: world, unlocked: worldUnlocked),
                const Spacer(),
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
                        Text('أكمل الوحدة السابقة لفتح هذا العالم',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                const Spacer(),
                _PathLayout(
                  worldNumber: worldNumber,
                  lessons: world.lessons,
                  onLessonTap: onLessonTap,
                ),
                const SizedBox(height: 18),
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
  const _StatusChip(
      {required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
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
        color: Colors.black.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(world.eyebrow,
                    style: TextStyle(
                        color: world.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(world.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(world.subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
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

class _PathLayout extends StatelessWidget {
  const _PathLayout({
    required this.worldNumber,
    required this.lessons,
    required this.onLessonTap,
  });

  final int worldNumber;
  final List<String> lessons;
  final ValueChanged<int> onLessonTap;

  @override
  Widget build(BuildContext context) {
    final progress = GameProgress.instance;
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(double.infinity, 280),
            painter: _WindingPathPainter(),
          ),
          ...List.generate(lessons.length, (index) {
            final unlocked = progress.isLessonUnlocked(worldNumber, index);
            final completed = progress.isLessonCompleted(worldNumber, index);
            final current = unlocked && !completed;
            final stars = progress.getLessonStars(worldNumber, index);

            final dx = switch (index) {
              0 => 80.0,
              1 => -60.0,
              2 => 50.0,
              _ => -40.0,
            };
            final dy = (index * 68.0) - 100;

            return Transform.translate(
              offset: Offset(dx, dy),
              child: _LessonNode(
                title: lessons[index],
                completed: completed,
                current: current,
                unlocked: unlocked,
                stars: stars,
                onTap: () => onLessonTap(index),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LessonNode extends StatelessWidget {
  const _LessonNode({
    required this.title,
    required this.completed,
    required this.current,
    required this.unlocked,
    required this.stars,
    required this.onTap,
  });

  final String title;
  final bool completed;
  final bool current;
  final bool unlocked;
  final int stars;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = completed
        ? AppColors.primary
        : current
            ? AppColors.gold
            : Colors.grey.shade700;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: .45),
                  blurRadius: current ? 16 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.white,
                width: current ? 3 : 2,
              ),
            ),
            child: Icon(
              completed
                  ? Icons.check_rounded
                  : current
                      ? Icons.play_arrow_rounded
                      : Icons.lock_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              title,
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

class _WindingPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(w * 0.5 + 80, h * 0.15);
    path.cubicTo(
      w * 0.5 + 10, h * 0.25,
      w * 0.5 - 40, h * 0.35,
      w * 0.5 - 60, h * 0.42,
    );
    path.cubicTo(
      w * 0.5 - 70, h * 0.50,
      w * 0.5 + 40, h * 0.60,
      w * 0.5 + 50, h * 0.68,
    );
    path.cubicTo(
      w * 0.5 + 60, h * 0.75,
      w * 0.5 - 20, h * 0.85,
      w * 0.5 - 40, h * 0.92,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
