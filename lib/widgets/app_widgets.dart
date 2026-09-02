import 'package:flutter/material.dart';

import '../app_theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 76, this.showName = false});

  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(size * .3),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .25),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.menu_book_rounded, color: Colors.white, size: size * .48),
          Positioned(
            top: size * .15,
            right: size * .14,
            child: Icon(Icons.star_rounded,
                color: AppColors.gold, size: size * .22),
          ),
        ],
      ),
    );

    if (!showName) return mark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 12),
        const Text(
          'رحلة النور',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class SoftIcon extends StatelessWidget {
  const SoftIcon({
    super.key,
    required this.icon,
    this.color = AppColors.primary,
    this.backgroundColor = AppColors.primarySoft,
    this.size = 52,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size * .32),
      ),
      child: Icon(icon, color: color, size: size * .52),
    );
  }
}

class AuthPageFrame extends StatelessWidget {
  const AuthPageFrame({
    super.key,
    required this.child,
    this.showBack = true,
  });

  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned(
            top: -90,
            right: -65,
            child: _Glow(size: 220, color: AppColors.primarySoft),
          ),
          const Positioned(
            bottom: -100,
            left: -70,
            child: _Glow(size: 230, color: AppColors.goldSoft),
          ),
          SafeArea(
            child: Column(
              children: [
                if (showBack)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: IconButton.filledTonal(
                        tooltip: 'رجوع',
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_forward_rounded),
                      ),
                    ),
                  ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(
      {super.key, required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}

abstract final class EmptyActionSnack {
  static void show(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(text),
        ),
      );
  }
}
