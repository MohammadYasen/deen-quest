import 'package:deen_quest/data/curriculum_data.dart';
import 'package:deen_quest/models.dart';
import 'package:deen_quest/progress_store.dart';
import 'package:deen_quest/screens/auth/login_screen.dart';
import 'package:deen_quest/screens/lesson_screen.dart';
import 'package:deen_quest/screens/splash_screen.dart';
import 'package:deen_quest/services/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _testApp(Widget home) {
  return MaterialApp(
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: home,
    ),
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.instance.init();
    await GameProgress.instance.init();
  });

  testWidgets('startup, onboarding, and guest navigation work', (tester) async {
    await tester.pumpWidget(_testApp(const SplashScreen()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();
    expect(find.text('رحلة معرفة خطوة بخطوة'), findsOneWidget);

    await tester.tap(find.text('تخطي'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login-email')), findsOneWidget);

    await tester.tap(find.byKey(const Key('guest-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
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
    const testQuestion = QuizQuestion(
      id: 'test_q',
      prompt: 'كم عدد أركان الإسلام؟',
      options: ['ثلاثة', 'خمسة', 'سبعة', 'عشرة'],
      correctIndex: 1,
      explanation: 'أركان الإسلام خمسة',
      source: 'صحيح البخاري ومسلم',
    );

    await tester.pumpWidget(
      _testApp(const LessonScreen(
        title: 'أركان الإسلام',
        customQuestions: [testQuestion],
      )),
    );
    await tester.pump();

    await tester.tap(find.text('خمسة'));
    await tester.pump();

    await tester.tap(find.text('تحقق من الإجابة'));
    await tester.pump();

    expect(find.text('أحسنت! +10 XP'), findsOneWidget);
  });

  testWidgets('completing the current lesson unlocks the next one and awards XP', (tester) async {
    final progress = GameProgress.instance;
    final initialSteps = progress.completedSteps;
    final initialXp = progress.xp;

    progress.finishLesson(
      worldIndex: 0,
      lessonIndex: 1,
      earnedXp: 30,
      remainingHearts: 5,
      stars: 3,
    );

    expect(progress.completedSteps, greaterThan(initialSteps));
    expect(progress.xp, equals(initialXp + 30));
    expect(progress.isLessonCompleted(0, 1), isTrue);
    expect(progress.getLessonStars(0, 1), equals(3));
  });

  testWidgets('challenge claiming is idempotent and awards rewards once', (tester) async {
    final progress = GameProgress.instance;
    final initialXp = progress.xp;

    final firstClaim = progress.claimChallenge('test_challenge', xpReward: 50, heartReward: 1);
    expect(firstClaim, isTrue);
    expect(progress.xp, equals(initialXp + 50));
    expect(progress.isChallengeClaimed('test_challenge'), isTrue);

    final secondClaim = progress.claimChallenge('test_challenge', xpReward: 50);
    expect(secondClaim, isFalse);
    expect(progress.xp, equals(initialXp + 50));
  });

  testWidgets('curriculum data has valid questions across all 9 categories', (tester) async {
    expect(CurriculumData.categories.length, equals(9));
    for (final cat in CurriculumData.categories) {
      final questions = CurriculumData.getQuestionsForTopic(cat.id);
      expect(questions.isNotEmpty, isTrue);
      for (final q in questions) {
        expect(q.prompt.isNotEmpty, isTrue);
        expect(q.explanation.isNotEmpty, isTrue);
        expect(q.source.isNotEmpty, isTrue);
      }
    }
  });

  testWidgets('mistakes tracking records and removes items correctly', (tester) async {
    final progress = GameProgress.instance;
    final sampleQuestion = CurriculumData.allQuestions.first;

    progress.addMistake(sampleQuestion);
    expect(progress.mistakesReview.any((q) => q.prompt == sampleQuestion.prompt), isTrue);

    progress.removeMistake(sampleQuestion);
    expect(progress.mistakesReview.any((q) => q.prompt == sampleQuestion.prompt), isFalse);
  });
}
