import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../progress_store.dart';
import '../services/auth_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _selectedLeagueIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedLeagueIndex = GameProgress.instance.currentLeague.index;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([GameProgress.instance, AuthService.instance]),
      builder: (context, _) {
        final progress = GameProgress.instance;
        final myXp = progress.xp;
        final myName = AuthService.instance.currentUser?.displayName ?? 'أنت';

        final learners = [
          ('مريم بنت عمران', 1850, 'م', false),
          ('عبدالله بن مسعود', 1710, 'ع', false),
          ('أحمد الفاروق', 1565, 'أ', false),
          (myName, myXp, myName.isNotEmpty ? myName[0] : 'أ', true),
          ('يوسف الصديق', 920, 'ي', false),
          ('نور الهدى', 745, 'ن', false),
          ('خالد بن الوليد', 670, 'خ', false),
          ('سارة الأندلسية', 580, 'س', false),
          ('حمزة بن عبدالمطلب', 420, 'ح', false),
          ('عائشة المباركة', 310, 'ع', false),
        ];

        learners.sort((a, b) => b.$2.compareTo(a.$2));
        final myRank = learners.indexWhere((l) => l.$4) + 1;

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الدوريات الأسبوعية',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer_outlined, color: AppColors.primaryDark, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'يومان و 14 ساعة',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w900,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                'تنافس بشرف مع طلاب العلم · ترتيبك الحالي: #$myRank',
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              _LeagueSelector(
                selectedIndex: _selectedLeagueIndex,
                currentLeagueIndex: progress.currentLeague.index,
                onSelect: (index) => setState(() => _selectedLeagueIndex = index),
              ),
              const SizedBox(height: 14),
              _ActiveLeagueBanner(
                tier: LeagueTier.values[_selectedLeagueIndex],
                isMyLeague: _selectedLeagueIndex == progress.currentLeague.index,
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_upward_rounded, color: AppColors.primary, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'المراكز الثلاثة الأولى تصعد للدوري الأعلى الأسبوع القادم 🚀',
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
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
                    isPromotionZone: index < 3,
                    isDemotionZone: index >= learners.length - 2,
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

class _LeagueSelector extends StatelessWidget {
  const _LeagueSelector({
    required this.selectedIndex,
    required this.currentLeagueIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final int currentLeagueIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(LeagueTier.values.length, (index) {
          final tier = LeagueTier.values[index];
          final isSelected = selectedIndex == index;
          final isCurrent = currentLeagueIndex == index;

          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () => onSelect(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : isCurrent
                          ? AppColors.goldSoft
                          : Colors.black.withValues(alpha: .05),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : isCurrent
                            ? AppColors.gold
                            : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(tier.badge, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      tier.title.replaceFirst('دوري النور ', ''),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : isCurrent
                                ? AppColors.ink
                                : AppColors.muted,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 5),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ActiveLeagueBanner extends StatelessWidget {
  const _ActiveLeagueBanner({required this.tier, required this.isMyLeague});
  final LeagueTier tier;
  final bool isMyLeague;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: switch (tier) {
            LeagueTier.bronze => [const Color(0xFF3E2723), const Color(0xFF6D4C41)],
            LeagueTier.silver => [const Color(0xFF263238), const Color(0xFF455A64)],
            LeagueTier.gold => [const Color(0xFF1B3B2B), const Color(0xFFD4AF37)],
            LeagueTier.emerald => [const Color(0xFF004D40), const Color(0xFF00897B)],
            LeagueTier.diamond => [const Color(0xFF1A237E), const Color(0xFF5C6BC0)],
          },
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(tier.badge, style: const TextStyle(fontSize: 48)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      tier.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (isMyLeague) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'دوريك الحالي',
                          style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isMyLeague
                      ? 'أنت تتنافس في هذا الدوري هذا الأسبوع. حافظ على الترتيب!'
                      : 'تحتاج إلى ${tier.minXp} XP للوصول إلى هذا الدوري.',
                  style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
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
    required this.isPromotionZone,
    required this.isDemotionZone,
  });

  final int rank;
  final String name;
  final int xp;
  final String initial;
  final bool isMe;
  final bool isPromotionZone;
  final bool isDemotionZone;

  @override
  Widget build(BuildContext context) {
    final medalColor = switch (rank) {
      1 => AppColors.gold,
      2 => const Color(0xFFA9B7BD),
      3 => const Color(0xFFC77A48),
      _ => AppColors.muted,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primarySoft : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isMe
              ? AppColors.primary
              : isPromotionZone
                  ? AppColors.primary.withValues(alpha: .35)
                  : isDemotionZone
                      ? Colors.orange.withValues(alpha: .35)
                      : AppColors.line,
          width: isMe ? 2 : 1.2,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: medalColor,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: isMe ? AppColors.primary : medalColor.withValues(alpha: .18),
            child: Text(
              initial,
              style: TextStyle(
                color: isMe ? Colors.white : medalColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMe ? '$name (أنت)' : name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: isMe ? FontWeight.w900 : FontWeight.w700,
                  ),
                ),
                if (isPromotionZone)
                  const Text(
                    'منطقة الصعود 🚀',
                    style: TextStyle(color: AppColors.primary, fontSize: 10.5, fontWeight: FontWeight.w800),
                  )
                else if (isDemotionZone)
                  const Text(
                    'منطقة الخطر ⚠️',
                    style: TextStyle(color: Colors.orange, fontSize: 10.5, fontWeight: FontWeight.w800),
                  ),
              ],
            ),
          ),
          const Icon(Icons.bolt_rounded, color: AppColors.gold, size: 20),
          Text(
            '$xp XP',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
