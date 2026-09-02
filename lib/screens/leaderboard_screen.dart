import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../progress_store.dart';
import '../services/auth_service.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([GameProgress.instance, AuthService.instance]),
      builder: (context, _) {
        final myXp = GameProgress.instance.xp;
        final myName = AuthService.instance.currentUser?.displayName ?? 'أنت';

        final learners = [
          ('مريم بنت عمران', 1850, 'م', false),
          ('عبدالله بن مسعود', 1710, 'ع', false),
          ('أحمد الفاروق', 1565, 'أ', false),
          (myName, myXp, myName.isNotEmpty ? myName[0] : 'أ', true),
          ('يوسف الصديق', 920, 'ي', false),
          ('نور الهدى', 745, 'ن', false),
          ('خالد بن الوليد', 670, 'خ', false),
        ];

        learners.sort((a, b) => b.$2.compareTo(a.$2));
        final myRank = learners.indexWhere((l) => l.$4) + 1;

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 36),
            children: [
              Text('ترتيب المتعلمين',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 5),
              Text('دوري طلاب العلم الأسبوعي · ترتيبك الحالي: #$myRank',
                  style: const TextStyle(color: AppColors.muted)),
              const SizedBox(height: 20),
              const _LeagueBanner(),
              const SizedBox(height: 18),
              ...List.generate(
                learners.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: _RankTile(
                    rank: index + 1,
                    name: learners[index].$1,
                    xp: learners[index].$2,
                    initial: learners[index].$3,
                    isMe: learners[index].$4,
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

class _LeagueBanner extends StatelessWidget {
  const _LeagueBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(colors: [Color(0xFF273D68), AppColors.purple]),
        borderRadius: BorderRadius.circular(23),
      ),
      child: const Row(
        children: [
          Icon(Icons.workspace_premium_rounded,
              color: AppColors.gold, size: 54),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الدوري الفضي',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900)),
                SizedBox(height: 4),
                Text('أفضل 5 مراكز يتأهلون إلى دوري النور الذهبي',
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RankTile extends StatelessWidget {
  const _RankTile({
    required this.rank,
    required this.name,
    required this.xp,
    required this.initial,
    required this.isMe,
  });

  final int rank;
  final String name;
  final int xp;
  final String initial;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final medalColor = switch (rank) {
      1 => AppColors.gold,
      2 => const Color(0xFFA9B7BD),
      3 => const Color(0xFFC77A48),
      _ => AppColors.muted,
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primarySoft : Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
            color: isMe ? AppColors.primary : AppColors.line,
            width: isMe ? 1.8 : 1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text('$rank',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: medalColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor:
                isMe ? AppColors.primary : medalColor.withValues(alpha: .17),
            child: Text(initial,
                style: TextStyle(
                    color: isMe ? Colors.white : medalColor,
                    fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(isMe ? '$name (أنت)' : name,
                style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: isMe ? FontWeight.w900 : FontWeight.w700)),
          ),
          const Icon(Icons.bolt_rounded, color: AppColors.gold, size: 20),
          Text('$xp XP',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.ink, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
