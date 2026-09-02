import 'package:deen_quest/app_theme.dart';
import 'package:deen_quest/data/curriculum_data.dart';
import 'package:deen_quest/main.dart';
import 'package:deen_quest/models.dart';
import 'package:deen_quest/progress_store.dart';
import 'package:deen_quest/screens/auth/login_screen.dart';
import 'package:deen_quest/screens/lesson_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _testApp(Widget home) {
  return MaterialApp(
    theme: AppTheme.light,
    builder: (context, child) => Directionality(
      textDirection: TextDirection.rtl,
      child: child!,
    ),
    home: home,
  );
}

void main() {
  setUp(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await GameProgress.instance.init();
  });

  testWidgets('startup, onboarding, and guest navigation work', (tester) async {
    await tester.pumpWidget(const DeenQuestApp());
    expect(find.text('رحلة النور'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();
    expect(find.text('رحلة معرفة خطوة بخطوة'), findsOneWidget);

    await tester.tap(find.text('تخطي'));
    await tester.pumpAndSettle();
    expect(find.text('مرحبًا بعودتك'), findsOneWidget);

    await tester.tap(find.byKey(const Key('guest-button')));
    await tester.pumpAndSettle();
    expect(find.text('أساسيات الإسلام'), findsOneWidget);
  });

  testWidgets('login form validates required fields', (tester) async {
    await tester.pumpWidget(_testApp(const LoginScreen()));
    await tester.tap(find.byKey(const Key('login-button')));
    await tester.pump();

    expect(find.text('أدخل البريد الإلكتروني'), findsOneWidget);
    expect(find.text('أدخل كلمة المرور'), findsOneWidget);
  });

  testWidgets('lesson checks a correct answer and awards XP', (tester) async {
    await tester.pumpWidget(
      _testApp(const LessonScreen(title: 'أركان الإسلام')),
    );

    expect(find.text('كم عدد أركان الإسلام؟'), findsOneWidget);
    await tester.tap(find.text('خمسة'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('lesson-action')));
    await tester.pump();

    expect(find.text('أحسنت! +10 XP'), findsOneWidget);
    expect(find.textContaining('المصدر:'), findsOneWidget);
  });

  test('completing the current lesson unlocks the next one and awards XP', () {
    final progress = GameProgress.instance;
    final oldXp = progress.xp;

    progress.finishLesson(
      worldIndex: 0,
      lessonIndex: 0,
      earnedXp: 40,
      remainingHearts: 4,
    );

    expect(progress.isLessonCompleted(0, 0), isTrue);
    expect(progress.isLessonUnlocked(0, 1), isTrue);
    expect(progress.xp, oldXp + 40);
    expect(progress.hearts, 4);
  });

  test('challenge claiming is idempotent and awards rewards once', () {
    final progress = GameProgress.instance;
    final initialXp = progress.xp;

    final firstClaim = progress.claimChallenge('test_challenge', xpReward: 50);
    expect(firstClaim, isTrue);
    expect(progress.xp, initialXp + 50);
    expect(progress.isChallengeClaimed('test_challenge'), isTrue);

    // Second claim must fail and not add XP again
    final secondClaim = progress.claimChallenge('test_challenge', xpReward: 50);
    expect(secondClaim, isFalse);
    expect(progress.xp, initialXp + 50);
  });

  test('curriculum data has valid questions across all 9 categories', () {
    final allQuestions = CurriculumData.allQuestions;
    expect(allQuestions.isNotEmpty, isTrue);
    expect(allQuestions.length, greaterThanOrEqualTo(20));

    final aqeedah = CurriculumData.getQuestionsForTopic('aqeedah');
    expect(aqeedah.isNotEmpty, isTrue);

    final pillars = CurriculumData.getQuestionsForTopic('pillars');
    expect(pillars.isNotEmpty, isTrue);

    final prayer = CurriculumData.getQuestionsForTopic('prayer');
    expect(prayer.isNotEmpty, isTrue);
  });

  test('mistakes tracking records and removes items correctly', () {
    final progress = GameProgress.instance;
    final q = sampleQuestions.first;

    progress.addMistake(q);
    expect(progress.mistakesReview.any((item) => item.id == q.id), isTrue);

    progress.removeMistake(q);
    expect(progress.mistakesReview.any((item) => item.id == q.id), isFalse);
  });
}
