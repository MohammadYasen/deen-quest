import 'package:flutter/material.dart';

export 'models/quiz_question.dart';
export 'models/user_profile.dart';
export 'models/challenge_model.dart';
export 'models/achievement_model.dart';
export 'models/topic_category.dart';

import 'models/quiz_question.dart';

enum LessonStatus { completed, current, available, locked }

class LessonItem {
  const LessonItem({
    this.id = '',
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.status,
    this.stars = 0,
    this.questions = const [],
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final LessonStatus status;
  final int stars;
  final List<QuizQuestion> questions;
}

const sampleLessons = <LessonItem>[
  LessonItem(
    title: 'أركان الإسلام',
    subtitle: '3 أسئلة · 4 دقائق',
    icon: Icons.looks_5_rounded,
    status: LessonStatus.completed,
    stars: 3,
  ),
  LessonItem(
    title: 'الصلوات الخمس',
    subtitle: '3 أسئلة · 5 دقائق',
    icon: Icons.access_time_filled_rounded,
    status: LessonStatus.current,
    stars: 1,
  ),
  LessonItem(
    title: 'الوضوء',
    subtitle: '4 أسئلة · 6 دقائق',
    icon: Icons.water_drop_rounded,
    status: LessonStatus.available,
  ),
  LessonItem(
    title: 'سيرة النبي ﷺ',
    subtitle: '5 أسئلة · 7 دقائق',
    icon: Icons.auto_stories_rounded,
    status: LessonStatus.locked,
  ),
  LessonItem(
    title: 'الأخلاق والآداب',
    subtitle: '5 أسئلة · 7 دقائق',
    icon: Icons.volunteer_activism_rounded,
    status: LessonStatus.locked,
  ),
];

const sampleQuestions = <QuizQuestion>[
  QuizQuestion(
    id: 'sample_1',
    prompt: 'كم عدد أركان الإسلام؟',
    options: ['ثلاثة', 'خمسة', 'سبعة', 'عشرة'],
    correctIndex: 1,
    explanation: 'أركان الإسلام خمسة، وهي الأساس الذي تُبنى عليه أعمال المسلم.',
    source: 'حديث ابن عمر رضي الله عنهما — متفق عليه',
    difficulty: DifficultyLevel.beginner,
    status: ContentStatus.underReview,
  ),
  QuizQuestion(
    id: 'sample_2',
    type: QuestionType.trueFalse,
    prompt: 'الصلوات المفروضة في اليوم والليلة خمس صلوات.',
    options: ['صحيح', 'خطأ'],
    correctIndex: 0,
    explanation: 'العبارة صحيحة؛ فقد فرض الله خمس صلوات في اليوم والليلة.',
    source: 'حديث طلحة بن عبيد الله رضي الله عنه — متفق عليه',
    difficulty: DifficultyLevel.beginner,
    status: ContentStatus.underReview,
  ),
  QuizQuestion(
    id: 'sample_3',
    type: QuestionType.ordering,
    prompt: 'رتّب الصلوات المفروضة حسب وقتها خلال اليوم.',
    correctOrder: ['الفجر', 'الظهر', 'العصر', 'المغرب', 'العشاء'],
    explanation:
        'يبدأ ترتيب الصلوات اليومية بالفجر، ثم الظهر والعصر والمغرب والعشاء.',
    source: 'مواقيت الصلوات الخمس المعروفة في كتب الفقه',
    difficulty: DifficultyLevel.beginner,
    status: ContentStatus.underReview,
  ),
  QuizQuestion(
    id: 'sample_4',
    type: QuestionType.matching,
    prompt: 'صِل كل عبادة بوصفها المناسب.',
    pairs: {
      'الصلاة': 'عبادة يومية',
      'الزكاة': 'حق مالي',
      'الصوم': 'إمساك بنية',
    },
    explanation:
        'تتنوع أركان الإسلام بين عبادة بدنية ومالية، ولكل ركن صفته وأحكامه.',
    source: 'حديث «بُني الإسلام على خمس» — متفق عليه',
    difficulty: DifficultyLevel.beginner,
    status: ContentStatus.underReview,
  ),
  QuizQuestion(
    id: 'sample_5',
    type: QuestionType.fillBlank,
    prompt: 'أكمل العبارة: قبلة المسلمين هي _____.',
    correctText: 'الكعبة',
    alternativeAnswers: ['الكعبة', 'الكعبة المشرفة', 'البيت الحرام'],
    explanation: 'يتجه المسلمون في صلاتهم نحو الكعبة المشرفة في المسجد الحرام.',
    source: 'سورة البقرة، الآية 144',
    difficulty: DifficultyLevel.beginner,
    status: ContentStatus.underReview,
  ),
  QuizQuestion(
    id: 'sample_6',
    type: QuestionType.flashCard,
    prompt: 'ما معنى الإحسان؟',
    cardAnswer: 'أن تعبد الله كأنك تراه، فإن لم تكن تراه فإنه يراك.',
    explanation: 'هذا تعريف الإحسان الوارد في حديث جبريل عليه السلام.',
    source: 'حديث جبريل — صحيح مسلم',
    difficulty: DifficultyLevel.beginner,
    status: ContentStatus.underReview,
  ),
];
