import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../widgets/app_widgets.dart';
import 'auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _items = [
    _OnboardingItem(
      icon: Icons.route_rounded,
      color: AppColors.primary,
      softColor: AppColors.primarySoft,
      title: 'رحلة معرفة خطوة بخطوة',
      body: 'دروس قصيرة ومتدرجة في العقيدة والعبادات والسيرة والأخلاق.',
    ),
    _OnboardingItem(
      icon: Icons.emoji_events_rounded,
      color: AppColors.gold,
      softColor: AppColors.goldSoft,
      title: 'تعلّم باللعب والتحدّي',
      body: 'اجمع النقاط، حافظ على سلسلة أيامك، وافتح مستويات جديدة.',
    ),
    _OnboardingItem(
      icon: Icons.fact_check_rounded,
      color: AppColors.purple,
      softColor: Color(0xFFEDE9FF),
      title: 'معلومة موثقة ومصدر واضح',
      body: 'يظهر مصدر كل إجابة، مع مراجعة المحتوى من متخصصين قبل النشر.',
    ),
  ];

  void _openLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const BrandMark(size: 44, showName: true),
                  TextButton(onPressed: _openLogin, child: const Text('تخطي')),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _items.length,
                onPageChanged: (value) => setState(() => _page = value),
                itemBuilder: (context, index) =>
                    _OnboardingPage(item: _items[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _items.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: index == _page ? 28 : 9,
                        height: 9,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: index == _page
                              ? AppColors.primary
                              : AppColors.line,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: FilledButton.icon(
                      onPressed: () {
                        if (_page == _items.length - 1) {
                          _openLogin();
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                          );
                        }
                      },
                      icon: Icon(
                        _page == _items.length - 1
                            ? Icons.rocket_launch_rounded
                            : Icons.arrow_back_rounded,
                      ),
                      label: Text(
                        _page == _items.length - 1 ? 'ابدأ الرحلة' : 'التالي',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingItem {
  const _OnboardingItem({
    required this.icon,
    required this.color,
    required this.softColor,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final Color softColor;
  final String title;
  final String body;
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.item});

  final _OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 500;
        final illustration = Container(
          width: compact ? 150 : 230,
          height: compact ? 150 : 230,
          decoration: BoxDecoration(
            color: item.softColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: compact ? 95 : 132,
              height: compact ? 95 : 132,
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.circular(38),
                boxShadow: [
                  BoxShadow(
                    color: item.color.withValues(alpha: .25),
                    blurRadius: 26,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child:
                  Icon(item.icon, size: compact ? 52 : 72, color: Colors.white),
            ),
          ),
        );

        final copy = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 14),
            Text(
              item.body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
          ],
        );

        if (compact && constraints.maxWidth > 620) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
            child: Row(
              children: [
                Expanded(child: illustration),
                const SizedBox(width: 42),
                Expanded(child: copy),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              illustration,
              SizedBox(height: compact ? 22 : 44),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: copy,
              ),
            ],
          ),
        );
      },
    );
  }
}
