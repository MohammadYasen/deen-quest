import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import 'lesson_screen.dart';

class LessonResultScreen extends StatefulWidget {
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
  State<LessonResultScreen> createState() => _LessonResultScreenState();
}

class _LessonResultScreenState extends State<LessonResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _showShareCard(BuildContext context, int accuracy, int stars) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        content: _ShareableCard(
          title: widget.title,
          xp: widget.xp,
          accuracy: accuracy,
          stars: stars,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accuracy = widget.total == 0 ? 0 : ((widget.correct / widget.total) * 100).round();
    final stars = accuracy >= 90
        ? 3
        : accuracy >= 65
            ? 2
            : 1;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _confettiController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ConfettiPainter(progress: _confettiController.value),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.goldSoft,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: .35),
                              blurRadius: 25,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(color: AppColors.gold, width: 4),
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          color: AppColors.gold,
                          size: 70,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'أتممت الدرس بنجاح!',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              index < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: AppColors.gold,
                              size: 42,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _ResultStat(
                              icon: Icons.bolt_rounded,
                              value: '+${widget.xp}',
                              label: 'نقاط الخبرة',
                              color: AppColors.gold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ResultStat(
                              icon: Icons.track_changes_rounded,
                              value: '$accuracy%',
                              label: 'الدقة',
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ResultStat(
                              icon: Icons.favorite_rounded,
                              value: '${widget.hearts}',
                              label: 'القلوب المتبقية',
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.primary.withValues(alpha: .2)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 28),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'تقدّمت خطوة مباركة في مسار النور. واصل التعلّم لفتح المحطات القادمة!',
                                style: TextStyle(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w700,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.route_rounded),
                        label: const Text('العودة إلى مسار التعلّم'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => _showShareCard(context, accuracy, stars),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.gold, width: 1.5),
                        ),
                        icon: const Icon(Icons.share_rounded, color: AppColors.gold),
                        label: const Text('مشاركة بطاقة الإنجاز 🌟'),
                      ),
                      const SizedBox(height: 6),
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => LessonScreen(title: widget.title),
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
        ],
      ),
    );
  }
}

class _ShareableCard extends StatelessWidget {
  const _ShareableCard({
    required this.title,
    required this.xp,
    required this.accuracy,
    required this.stars,
  });

  final String title;
  final int xp;
  final int accuracy;
  final int stars;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF162544), Color(0xFF1E3A5F), Color(0xFF0F1A2E)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.gold.withValues(alpha: .5), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .5),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_stories_rounded, color: AppColors.gold, size: 24),
              const SizedBox(width: 8),
              Text(
                'رحلة النور · بطاقة إنجاز',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'أتممت بنجاح درس:',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (i) => Icon(
                i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                color: AppColors.gold,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MiniStat(label: 'النقاط', value: '+$xp XP', color: AppColors.gold),
                Container(width: 1, height: 28, color: Colors.white24),
                _MiniStat(label: 'الدقة', value: '$accuracy%', color: const Color(0xFF3CCBC0)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '«مَنْ سَلَكَ طَرِيقًا يَلْتَمِسُ فِيهِ عِلْمًا سَهَّلَ اللَّهُ لَهُ بِهِ طَرِيقًا إِلَى الْجَنَّةِ»',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {
              Clipboard.setData(
                ClipboardData(
                  text: 'أتممت درس "$title" في تطبيق رحلة النور بدقة $accuracy% وحصلت على +$xp XP! 🌟\nحمّل التطبيق واشترك في رحلة التعلّم المباركة.',
                ),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم نسخ نص الإنجاز لمشاركته مع أحبابك! 📋')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('نسخ نص المشاركة'),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

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
            Text(
              value,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 10.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress});
  final double progress;

  static final _particles = List.generate(45, (index) {
    final rand = math.Random(index * 17);
    return _Particle(
      startX: rand.nextDouble(),
      speed: 0.5 + rand.nextDouble() * 0.8,
      size: 6.0 + rand.nextDouble() * 8.0,
      color: switch (index % 5) {
        0 => AppColors.gold,
        1 => const Color(0xFF3CCBC0),
        2 => const Color(0xFFF28C28),
        3 => const Color(0xFF7C4DFF),
        _ => Colors.white,
      },
      wobbleSpeed: 2.0 + rand.nextDouble() * 4.0,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final y = (p.speed * progress * size.height * 1.2) % size.height;
      final x = (p.startX * size.width) + math.sin(progress * p.wobbleSpeed * math.pi) * 20.0;
      final paint = Paint()
        ..color = p.color.withValues(alpha: (1.0 - (progress * 0.3)).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * math.pi * 3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _Particle {
  _Particle({
    required this.startX,
    required this.speed,
    required this.size,
    required this.color,
    required this.wobbleSpeed,
  });
  final double startX;
  final double speed;
  final double size;
  final Color color;
  final double wobbleSpeed;
}
