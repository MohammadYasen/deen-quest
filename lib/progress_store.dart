import 'package:flutter/foundation.dart';
import 'models/quiz_question.dart';
import 'services/local_storage_service.dart';

enum LeagueTier {
  bronze('دوري النور البرونزي', '🥉', 0, 300),
  silver('دوري النور الفضي', '🥈', 300, 700),
  gold('دوري النور الذهبي', '🥇', 700, 1500),
  emerald('دوري النور الزمردي', '💎', 1500, 3000),
  diamond('دوري النور الماسي', '👑', 3000, 999999);

  const LeagueTier(this.title, this.badge, this.minXp, this.maxXp);
  final String title;
  final String badge;
  final int minXp;
  final int maxXp;
}

class GameProgress extends ChangeNotifier {
  GameProgress._();

  static final GameProgress instance = GameProgress._();

  static const lessonsPerWorld = 4;
  static const maxHearts = 5;
  static const minutesPerHeartRegen = 30;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  LeagueTier get currentLeague {
    if (_xp >= 3000) return LeagueTier.diamond;
    if (_xp >= 1500) return LeagueTier.emerald;
    if (_xp >= 700) return LeagueTier.gold;
    if (_xp >= 300) return LeagueTier.silver;
    return LeagueTier.bronze;
  }

  int _completedSteps = 1;
  int get completedSteps => _completedSteps;
  set completedSteps(int val) {
    _completedSteps = val;
    _save();
    notifyListeners();
  }

  int _xp = 320;
  int get xp => _xp;
  set xp(int val) {
    _xp = val;
    _save();
    notifyListeners();
  }

  int _hearts = 5;
  int get hearts => _hearts;
  set hearts(int val) {
    _hearts = val.clamp(0, maxHearts);
    _save();
    notifyListeners();
  }

  int _streak = 7;
  int get streak => _streak;
  set streak(int val) {
    _streak = val;
    _save();
    notifyListeners();
  }

  int _streakFreezes = 1;
  int get streakFreezes => _streakFreezes;

  String? _lastActiveDate;
  String? get lastActiveDate => _lastActiveDate;

  DateTime? _lastHeartRestoredAt;
  DateTime? get lastHeartRestoredAt => _lastHeartRestoredAt;

  final Set<String> _completedLessonKeys = {};
  Set<String> get completedLessonKeys => Set.unmodifiable(_completedLessonKeys);

  final Map<String, int> _lessonStars = {};
  Map<String, int> get lessonStars => Map.unmodifiable(_lessonStars);

  final Set<String> _claimedChallenges = {};
  final Set<int> _claimedChests = {};
  Set<int> get claimedChests => Set.unmodifiable(_claimedChests);
  Set<String> get claimedChallenges => Set.unmodifiable(_claimedChallenges);

  final Set<String> _unlockedAchievements = {'start_strong', 'diligent_student'};
  Set<String> get unlockedAchievements => Set.unmodifiable(_unlockedAchievements);

  final List<QuizQuestion> _mistakesReview = [];
  List<QuizQuestion> get mistakesReview => List.unmodifiable(_mistakesReview);

  final Set<int> _masteredWorlds = {};
  Set<int> get masteredWorlds => Set.unmodifiable(_masteredWorlds);

  DateTime? _doubleXpUntil;
  bool get isDoubleXpActive =>
      _doubleXpUntil != null && DateTime.now().isBefore(_doubleXpUntil!);

  int _blitzHighScore = 0;
  int get blitzHighScore => _blitzHighScore;

  // Settings
  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  int _reminderHour = 19;
  int get reminderHour => _reminderHour;

  int _reminderMinute = 0;
  int get reminderMinute => _reminderMinute;

  bool _soundEnabled = true;
  bool get soundEnabled => _soundEnabled;

  bool _hapticEnabled = true;
  bool get hapticEnabled => _hapticEnabled;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  int _dailyGoalLessons = 1;
  int get dailyGoalLessons => _dailyGoalLessons;

  int _todayCompletedLessons = 0;
  int get todayCompletedLessons => _todayCompletedLessons;

  int _todayCorrectAnswers = 3;
  int get todayCorrectAnswers => _todayCorrectAnswers;

  int flatIndex(int worldIndex, int lessonIndex) =>
      worldIndex * lessonsPerWorld + lessonIndex;

  bool isWorldUnlocked(int worldIndex) =>
      flatIndex(worldIndex, 0) <= _completedSteps;

  bool isLessonUnlocked(int worldIndex, int lessonIndex) =>
      flatIndex(worldIndex, lessonIndex) <= _completedSteps;

  bool isLessonCompleted(int worldIndex, int lessonIndex) {
    final key = '${worldIndex}_$lessonIndex';
    return _completedLessonKeys.contains(key) || flatIndex(worldIndex, lessonIndex) < _completedSteps;
  }

  int getLessonStars(int worldIndex, int lessonIndex) {
    final key = '${worldIndex}_$lessonIndex';
    return _lessonStars[key] ?? (isLessonCompleted(worldIndex, lessonIndex) ? 3 : 0);
  }

  Future<void> init() async {
    await LocalStorageService.instance.init();
    final storage = LocalStorageService.instance;

    _completedSteps = storage.getInt('completed_steps', defaultValue: 1);
    _xp = storage.getInt('xp_points', defaultValue: 320);
    _hearts = storage.getInt('hearts_count', defaultValue: 5);
    _streak = storage.getInt('streak_days', defaultValue: 7);
    _streakFreezes = storage.getInt('streak_freezes', defaultValue: 1);
    _lastActiveDate = storage.getString('last_active_date', defaultValue: '');
    if (_lastActiveDate!.isEmpty) _lastActiveDate = null;

    final heartRestoredRaw = storage.getString('last_heart_restored_at');
    if (heartRestoredRaw.isNotEmpty) {
      _lastHeartRestoredAt = DateTime.tryParse(heartRestoredRaw);
    }

    _completedLessonKeys.addAll(storage.getStringList('completed_lesson_keys'));
    _claimedChallenges.addAll(storage.getStringList('claimed_challenges'));
    final loadedChests = storage.getStringList('claimed_chests');
    for (final c in loadedChests) {
      final parsed = int.tryParse(c);
      if (parsed != null) _claimedChests.add(parsed);
    }
    final loadedMastered = storage.getStringList('mastered_worlds');
    for (final w in loadedMastered) {
      final parsed = int.tryParse(w);
      if (parsed != null) _masteredWorlds.add(parsed);
    }
    _blitzHighScore = storage.getInt('blitz_high_score', defaultValue: 0);
    final doubleXpRaw = storage.getString('double_xp_until');
    if (doubleXpRaw.isNotEmpty) {
      _doubleXpUntil = DateTime.tryParse(doubleXpRaw);
    }
    _unlockedAchievements.addAll(storage.getStringList('unlocked_achievements', defaultValue: ['start_strong', 'diligent_student']));

    final starsJson = storage.getJson('lesson_stars');
    if (starsJson is Map) {
      starsJson.forEach((k, v) {
        if (v is int) _lessonStars[k.toString()] = v;
      });
    }

    final mistakesJson = storage.getJson('mistakes_review');
    if (mistakesJson is List) {
      for (final item in mistakesJson) {
        if (item is Map) {
          _mistakesReview.add(QuizQuestion.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    _notificationsEnabled = storage.getBool('settings_notifications', defaultValue: true);
    _reminderHour = storage.getInt('reminder_hour', defaultValue: 19);
    _reminderMinute = storage.getInt('reminder_minute', defaultValue: 0);
    _soundEnabled = storage.getBool('settings_sound', defaultValue: true);
    _hapticEnabled = storage.getBool('settings_haptics', defaultValue: true);
    _isDarkMode = storage.getBool('settings_dark_mode', defaultValue: false);
    _dailyGoalLessons = storage.getInt('settings_daily_goal', defaultValue: 1);

    _regenerateHeartsIfNeeded();
    _checkDailyReset();

    _isLoaded = true;
    notifyListeners();
  }

  void _save() {
    final storage = LocalStorageService.instance;
    storage.setInt('completed_steps', _completedSteps);
    storage.setInt('xp_points', _xp);
    storage.setInt('hearts_count', _hearts);
    storage.setInt('streak_days', _streak);
    storage.setInt('streak_freezes', _streakFreezes);
    if (_lastActiveDate != null) storage.setString('last_active_date', _lastActiveDate!);
    if (_lastHeartRestoredAt != null) {
      storage.setString('last_heart_restored_at', _lastHeartRestoredAt!.toIso8601String());
    }
    storage.setStringList('completed_lesson_keys', _completedLessonKeys.toList());
    storage.setStringList('claimed_challenges', _claimedChallenges.toList());
    storage.setStringList('claimed_chests', _claimedChests.map((e) => e.toString()).toList());
    storage.setStringList('mastered_worlds', _masteredWorlds.map((e) => e.toString()).toList());
    storage.setInt('blitz_high_score', _blitzHighScore);
    if (_doubleXpUntil != null) {
      storage.setString('double_xp_until', _doubleXpUntil!.toIso8601String());
    }
    storage.setStringList('unlocked_achievements', _unlockedAchievements.toList());
    storage.saveJson('lesson_stars', _lessonStars);
    storage.saveJson('mistakes_review', _mistakesReview.map((q) => q.toJson()).toList());

    storage.setBool('settings_notifications', _notificationsEnabled);
    storage.setInt('reminder_hour', _reminderHour);
    storage.setInt('reminder_minute', _reminderMinute);
    storage.setBool('settings_sound', _soundEnabled);
    storage.setBool('settings_haptics', _hapticEnabled);
    storage.setBool('settings_dark_mode', _isDarkMode);
    storage.setInt('settings_daily_goal', _dailyGoalLessons);
  }

  void _regenerateHeartsIfNeeded() {
    if (_hearts >= maxHearts) {
      _lastHeartRestoredAt = DateTime.now();
      return;
    }
    if (_lastHeartRestoredAt == null) {
      _lastHeartRestoredAt = DateTime.now();
      return;
    }

    final now = DateTime.now();
    final diffMinutes = now.difference(_lastHeartRestoredAt!).inMinutes;
    if (diffMinutes >= minutesPerHeartRegen) {
      final heartsToAdd = diffMinutes ~/ minutesPerHeartRegen;
      _hearts = (_hearts + heartsToAdd).clamp(0, maxHearts);
      _lastHeartRestoredAt = now;
      _save();
    }
  }

  void _checkDailyReset() {
    final today = _formatDate(DateTime.now());
    final lastReset = LocalStorageService.instance.getString('last_daily_reset');
    if (lastReset != today) {
      _todayCompletedLessons = 0;
      _todayCorrectAnswers = 0;
      LocalStorageService.instance.setString('last_daily_reset', today);
    }
  }

  static String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  void updateStreakOnActivity(DateTime now) {
    final todayStr = _formatDate(now);
    if (_lastActiveDate == todayStr) {
      return;
    }

    if (_lastActiveDate == null) {
      _streak = 1;
      _lastActiveDate = todayStr;
      _save();
      notifyListeners();
      return;
    }

    final parts = _lastActiveDate!.split('-').map(int.parse).toList();
    final lastDate = DateTime(parts[0], parts[1], parts[2]);
    final todayDate = DateTime(now.year, now.month, now.day);
    final daysDiff = todayDate.difference(lastDate).inDays;

    if (daysDiff == 1) {
      _streak++;
    } else if (daysDiff == 2 && _streakFreezes > 0) {
      _streakFreezes--;
      _streak++;
    } else if (daysDiff > 1) {
      _streak = 1;
    }

    _lastActiveDate = todayStr;
    _checkAchievements();
    _save();
    notifyListeners();
  }

  void finishLesson({
    required int worldIndex,
    required int lessonIndex,
    required int earnedXp,
    required int remainingHearts,
    int stars = 3,
  }) {
    final lessonKey = '${worldIndex}_$lessonIndex';
    final alreadyDone = _completedLessonKeys.contains(lessonKey);

    final lessonFlat = flatIndex(worldIndex, lessonIndex);
    if (lessonFlat >= 0 && lessonFlat == _completedSteps) {
      _completedSteps++;
    }

    _completedLessonKeys.add(lessonKey);
    final currentStars = _lessonStars[lessonKey] ?? 0;
    if (stars > currentStars) {
      _lessonStars[lessonKey] = stars;
    }

    final actualEarned = isDoubleXpActive ? earnedXp * 2 : earnedXp;
    _xp += alreadyDone ? (actualEarned ~/ 2) : actualEarned;
    _hearts = remainingHearts.clamp(0, maxHearts);
    if (_hearts < maxHearts && _lastHeartRestoredAt == null) {
      _lastHeartRestoredAt = DateTime.now();
    }

    _todayCompletedLessons++;
    updateStreakOnActivity(DateTime.now());
    _checkAchievements();
    _save();
    notifyListeners();
  }

  void finishPractice({
    required int earnedXp,
    required int remainingHearts,
  }) {
    final actualEarned = isDoubleXpActive ? earnedXp * 2 : earnedXp;
    _xp += actualEarned;
    _hearts = remainingHearts.clamp(0, maxHearts);
    _save();
    notifyListeners();
  }

  void refillHearts() {
    _hearts = maxHearts;
    _lastHeartRestoredAt = DateTime.now();
    _save();
    notifyListeners();
  }

  void addMistake(QuizQuestion question) {
    if (!_mistakesReview.any((q) => q.prompt == question.prompt)) {
      _mistakesReview.add(question);
      _save();
      notifyListeners();
    }
  }

  void removeMistake(QuizQuestion question) {
    _mistakesReview.removeWhere((q) => q.prompt == question.prompt);
    _save();
    notifyListeners();
  }

  bool isChallengeClaimed(String challengeId) => _claimedChallenges.contains(challengeId);

  bool claimChallenge(String challengeId, {int xpReward = 0, int heartReward = 0, int freezeReward = 0}) {
    if (_claimedChallenges.contains(challengeId)) return false;

    _claimedChallenges.add(challengeId);
    _xp += xpReward;
    _hearts = (_hearts + heartReward).clamp(0, maxHearts);
    _streakFreezes += freezeReward;

    _save();
    notifyListeners();
    return true;
  }

  void _checkAchievements() {
    if (_completedLessonKeys.isNotEmpty) {
      _unlockedAchievements.add('first_step');
    }
    if (_completedSteps >= 5) {
      _unlockedAchievements.add('diligent_student');
    }
    if (_streak >= 7) {
      _unlockedAchievements.add('start_strong');
    }
    if (_xp >= 500) {
      _unlockedAchievements.add('point_collector');
    }
    if (_masteredWorlds.isNotEmpty) {
      _unlockedAchievements.add('world_conqueror');
    }
  }

  // Settings Setters
  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    _save();
    notifyListeners();
  }

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    _save();
    notifyListeners();
  }

  void setReminderTime(int hour, int minute) {
    _reminderHour = hour;
    _reminderMinute = minute;
    _save();
    notifyListeners();
  }

  void toggleSound(bool value) {
    _soundEnabled = value;
    _save();
    notifyListeners();
  }

  void toggleHaptics(bool value) {
    _hapticEnabled = value;
    _save();
    notifyListeners();
  }

    bool isChestClaimed(int worldIndex) => _claimedChests.contains(worldIndex);

  bool canClaimChest(int worldIndex) {
    if (isChestClaimed(worldIndex)) return false;
    for (int i = 0; i < lessonsPerWorld; i++) {
      if (!isLessonCompleted(worldIndex, i)) return false;
    }
    return true;
  }

  bool claimWorldChest(int worldIndex) {
    if (!canClaimChest(worldIndex)) return false;
    _claimedChests.add(worldIndex);
    _xp += 75;
    _hearts = (_hearts + 2).clamp(0, maxHearts);
    _checkAchievements();
    _save();
    notifyListeners();
    return true;
  }

  bool isWorldMastered(int worldIndex) => _masteredWorlds.contains(worldIndex);

  bool canAttemptWorldMastery(int worldIndex) {
    for (int i = 0; i < lessonsPerWorld; i++) {
      if (!isLessonCompleted(worldIndex, i)) return false;
    }
    return true;
  }

  void completeWorldMastery(int worldIndex, {int bonusXp = 150}) {
    _masteredWorlds.add(worldIndex);
    final actualBonus = isDoubleXpActive ? bonusXp * 2 : bonusXp;
    _xp += actualBonus;
    _unlockedAchievements.add('world_conqueror');
    _checkAchievements();
    _save();
    notifyListeners();
  }

  bool buyDoubleXp({int cost = 120, int durationMinutes = 30}) {
    if (_xp < cost) return false;
    _xp -= cost;
    final now = DateTime.now();
    final base = isDoubleXpActive ? _doubleXpUntil! : now;
    _doubleXpUntil = base.add(Duration(minutes: durationMinutes));
    _save();
    notifyListeners();
    return true;
  }

  void recordBlitzScore(int score, {int earnedXp = 0}) {
    if (score > _blitzHighScore) {
      _blitzHighScore = score;
    }
    final actualXp = isDoubleXpActive ? earnedXp * 2 : earnedXp;
    _xp += actualXp;
    if (_blitzHighScore >= 8) {
      _unlockedAchievements.add('speed_scholar');
    }
    _checkAchievements();
    _save();
    notifyListeners();
  }

  bool buyStreakFreeze({int cost = 100}) {
    if (_xp < cost) return false;
    _xp -= cost;
    _streakFreezes++;
    _save();
    notifyListeners();
    return true;
  }

  bool buyHeartRefill({int cost = 50}) {
    if (_xp < cost || _hearts >= maxHearts) return false;
    _xp -= cost;
    _hearts = maxHearts;
    _lastHeartRestoredAt = DateTime.now();
    _save();
    notifyListeners();
    return true;
  }

  void setDailyGoal(int lessons) {
    _dailyGoalLessons = lessons;
    _save();
    notifyListeners();
  }
}
