import 'package:flutter/material.dart';
import '../models/quiz_question.dart';
import '../models/topic_category.dart';

abstract final class CurriculumData {
  static const categories = <TopicCategory>[
    TopicCategory(
      id: 'aqeedah',
      title: 'العقيدة',
      description: 'أصول الإيمان، والتوحيد، وأسماء الله الحسنى',
      icon: Icons.favorite_rounded,
      color: Color(0xFF7867C9),
    ),
    TopicCategory(
      id: 'pillars',
      title: 'أركان الإسلام والإيمان',
      description: 'الأركان الخمسة والستة ودلائلها',
      icon: Icons.looks_5_rounded,
      color: Color(0xFF137F78),
    ),
    TopicCategory(
      id: 'prayer',
      title: 'الصلاة والطهارة',
      description: 'الوضوء، مواقيت الصلوات، وشروط صحتها',
      icon: Icons.water_drop_rounded,
      color: Color(0xFF389B9B),
    ),
    TopicCategory(
      id: 'seerah',
      title: 'السيرة النبوية',
      description: 'محطات حياة الحبيب المصطفى ﷺ والهجرة',
      icon: Icons.auto_stories_rounded,
      color: Color(0xFFB77A34),
    ),
    TopicCategory(
      id: 'quran',
      title: 'القرآن وعلومه',
      description: 'نزول القرآن، السور المكية والمدنية، وفضائله',
      icon: Icons.menu_book_rounded,
      color: Color(0xFF1B6A58),
    ),
    TopicCategory(
      id: 'hadith',
      title: 'الحديث النبوي',
      description: 'أحاديث نبوية جامعة في العبادات والمعاملات',
      icon: Icons.record_voice_over_rounded,
      color: Color(0xFF4C81C6),
    ),
    TopicCategory(
      id: 'ethics',
      title: 'الأخلاق والآداب',
      description: 'الصدق، بر الوالدين، حسن الجوار، وحفظ اللسان',
      icon: Icons.volunteer_activism_rounded,
      color: Color(0xFFE56B86),
    ),
    TopicCategory(
      id: 'occasions',
      title: 'المناسبات والتقويم',
      description: 'التقويم الهجري، رمضان، الأعياد، والأشهر الحرم',
      icon: Icons.nights_stay_rounded,
      color: Color(0xFFF4B740),
    ),
    TopicCategory(
      id: 'history',
      title: 'التاريخ الإسلامي',
      description: 'الخلفاء الراشدون، وبناء الدولة والعلماء',
      icon: Icons.history_edu_rounded,
      color: Color(0xFF5A728E),
    ),
  ];

  static const allQuestions = <QuizQuestion>[
    // 1. العقيدة
    QuizQuestion(
      id: 'aq_1',
      type: QuestionType.multipleChoice,
      prompt: 'ما هي أعظم سورة بيّنت توحيد الله وإخلاص العبادة له؟',
      options: ['سورة الإخلاص', 'سورة الفلق', 'سورة الناس', 'سورة الكوثر'],
      correctIndex: 0,
      explanation: 'سورة الإخلاص تعدل ثلث القرآن لكونها أخلصت لبيان صفات الرب جل وعلا وتوحيده.',
      source: 'صحيح البخاري، حديث 5013',
      difficulty: DifficultyLevel.beginner,
      status: ContentStatus.underReview,
      reviewerName: 'هيئة التدقيق العلمي',
      reviewDate: '2026-09-01',
    ),
    QuizQuestion(
      id: 'aq_2',
      type: QuestionType.trueFalse,
      prompt: 'أركان الإيمان ستة أركان.',
      options: ['صحيح', 'خطأ'],
      correctIndex: 0,
      explanation: 'أركان الإيمان ستة: الإيمان بالله، وملائكته، وكتبه، ورسله، واليوم الآخر، والقدر خيره وشره.',
      source: 'صحيح مسلم، حديث جبريل الطويل رقم 8',
      difficulty: DifficultyLevel.beginner,
      status: ContentStatus.underReview,
      reviewerName: 'هيئة التدقيق العلمي',
      reviewDate: '2026-09-01',
    ),
    QuizQuestion(
      id: 'aq_3',
      type: QuestionType.flashCard,
      prompt: 'ما معنى شهادة «أن لا إله إلا الله»؟',
      cardAnswer: 'لا معبود بحق إلا الله سبحانه وحده لا شريك له.',
      explanation: 'تتضمن النفي (لا إله) لجميع ما يعبد من دون الله، والإثبات (إلا الله) لله وحده.',
      source: 'تفسير ابن كثير، سورة محمد الآية 19',
      difficulty: DifficultyLevel.beginner,
      status: ContentStatus.underReview,
      reviewerName: 'هيئة التدقيق العلمي',
      reviewDate: '2026-09-01',
    ),

    // 2. أركان الإسلام
    QuizQuestion(
      id: 'pil_1',
      prompt: 'كم عدد أركان الإسلام؟',
      options: ['ثلاثة', 'خمسة', 'سبعة', 'عشرة'],
      correctIndex: 1,
      explanation: 'أركان الإسلام خمسة: شهادة أن لا إله إلا الله وأن محمداً رسول الله، وإقام الصلاة، وإيتاء الزكاة، وصوم رمضان، وحج البيت.',
      source: 'صحيح البخاري ومسلم، حديث ابن عمر رضي الله عنهما',
      difficulty: DifficultyLevel.beginner,
      status: ContentStatus.underReview,
      reviewerName: 'هيئة التدقيق العلمي',
      reviewDate: '2026-09-01',
    ),
    QuizQuestion(
      id: 'pil_2',
      type: QuestionType.matching,
      prompt: 'صِل كل ركن من أركان الإسلام بطبيعته الشرعية.',
      pairs: {
        'الصلاة': 'صلة يومية بين العبد وربه',
        'الزكاة': 'حق مالي للفقراء والمساكين',
        'الصيام': 'إمساك عن المفطرات بنية التعبد',
      },
      explanation: 'تتكامل أركان الإسلام لتشمل العبادات البدنية والمالية والروحية.',
      source: 'رياض الصالحين، باب وجوب الصلاة والزكاة والصوم',
      difficulty: DifficultyLevel.beginner,
      status: ContentStatus.underReview,
      reviewerName: 'هيئة التدقيق العلمي',
      reviewDate: '2026-09-01',
    ),

    // 3. الصلاة والطهارة
    QuizQuestion(
      id: 'pray_1',
      type: QuestionType.ordering,
      prompt: 'رتّب الصلوات المفروضة حسب وقتها اليومي.',
      correctOrder: ['الفجر', 'الظهر', 'العصر', 'المغرب', 'العشاء'],
      explanation: 'يبدأ اليوم الشرعي بأذان الفجر، وتتوالى الصلوات الخمس في أوقاتها المحددة.',
      source: 'سورة النساء، الآية 103 «إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَوْقُوتًا»',
      difficulty: DifficultyLevel.beginner,
      status: ContentStatus.underReview,
      reviewerName: 'هيئة التدقيق العلمي',
      reviewDate: '2026-09-01',
    ),
    QuizQuestion(
      id: 'pray_2',
      type: QuestionType.fillBlank,
      prompt: 'أكمل العبارة: قبلة المسلمين التي يتوجهون إليها في الصلاة هي _____.',
      correctText: 'الكعبة',
      alternativeAnswers: ['الكعبة', 'الكعبة المشرفة', 'البيت الحرام', 'المسجد الحرام'],
      explanation: 'حوّل الله القبلة إلى الكعبة المشرفة في مكة المكرمة استجابة لرغبة نبيه الكريم ﷺ.',
      source: 'سورة البقرة، الآية 144',
      difficulty: DifficultyLevel.beginner,
      status: ContentStatus.underReview,
      reviewerName: 'هيئة التدقيق العلمي',
      reviewDate: '2026-09-01',
    ),
    QuizQuestion(
      id: 'pray_3',
      type: QuestionType.trueFalse,
      prompt: 'الوضوء شرط أساسي لصحة الصلاة لمن كان غير متوضئ.',
      options: ['صحيح', 'خطأ'],
      correctIndex: 0,
      explanation: 'قال النبي ﷺ: «لا تُقبل صلاةُ من أحدث حتى يتوضأ».',
      source: 'صحيح البخاري، حديث 135',
      difficulty: DifficultyLevel.beginner,
      status: ContentStatus.underReview,
      reviewerName: 'هيئة التدقيق العلمي',
      reviewDate: '2026-09-01',
    ),

    // 4. السيرة النبوية
    QuizQuestion(
      id: 'seer_1',
      type: QuestionType.multipleChoice,
      prompt: 'أين نزل الوحي أول مرة على النبي محمد ﷺ؟',
      options: ['في غار حراء', 'في غار ثور', 'في المسجد النبوي', 'في دار الأرقم'],
      correctIndex: 0,
      explanation: 'كان النبي ﷺ يتحنث ويتعبد في غار حراء في جبل النور حين جاءه الملك جبريل عليه السلام بأول آيات القرآن الكريم.',
      source: 'صحيح البخاري، كتاب بدء الوحي حديث رقم 3',
      difficulty: DifficultyLevel.beginner,
      status: ContentStatus.underReview,
      reviewerName: 'هيئة التدقيق العلمي',
      reviewDate: '2026-09-01',
    ),
    QuizQuestion(
      id: 'seer_2',
      type: QuestionType.ordering,
      prompt: 'رتّب المحطات الأولى في حياة النبي ﷺ تسلسلياً.',
      correctOrder: ['المولد الشريف في مكة', 'نزول الوحي في غار حراء', 'الهجرة النبوية إلى المدينة', 'حجة الوداع'],
      explanation: 'ولد ﷺ في عام الفيل، وبُعث في سن الأربعين، وهاجر بعد 13 سنة من البعثة، وحج حجة الوداع في السنة العاشرة للهجرة.',
      source: 'الرحيق المختوم، صفي الرحمن المباركفوري',
      difficulty: DifficultyLevel.intermediate,
      status: ContentStatus.underReview,
      reviewerName: 'هيئة التدقيق العلمي',
      reviewDate: '2026-09-01',
    ),
    QuizQuestion(
      id: 'seer_3',
      type: QuestionType.flashCard,
      prompt: 'من كان رفيق النبي ﷺ في رحلة الهجرة النبوية؟',
      cardAnswer: 'الصحابي الجليل أبو بكر الصديق رضي الله عنه.',
      explanation: 'رافقه الصديق رضي الله عنه في رحلة الهجرة، وقد سجل القرآن ذلك في سورة التوبة: «إِذْ يَقُولُ لِصَاحِبِهِ لَا تَحْزَنْ إِنَّ اللَّهَ مَعَنَا».',
      source: 'سورة التوبة، الآية 40',
      difficulty: DifficultyLevel.beginner,
      status: ContentStatus.underReview,
      reviewerName: 'هيئة التدقيق العلمي',
      reviewDate: '2026-09-01',
    ),

    // 5. القرآن وعلومه
    QuizQuestion(
      id: 'qur_1',
      type: QuestionType.fillBlank,
      prompt: 'أول كلمة نزلت من القرآن الكريم هي كلمة: _____.',
      correctText: 'اقرأ',
      alternativeAnswers: ['اقرأ', 'إقرأ'],
      explanation: 'نزلت أول آية من سورة العلق: «اقْرَأْ بِاسْمِ رَبِّكَ الَّذِي خَلَقَ».',
      source: 'سورة العلق، الآية 1',
      difficulty: DifficultyLevel.beginner,
      status: ContentStatus.underReview,
      reviewerName: 'هيئة التدقيق العلمي',
      reviewDate: '2026-09-01',
    ),
    QuizQuestion(
      id: 'qur_2',
      type: QuestionType.multipleChoice,
      prompt: 'كم عدد سور القرآن الكريم كاملة؟',
      options: ['114 سورة', '110 سور', '120 سورة', '100 سورة'],
      correctIndex: 0,
      explanation: 'عدد سور القرآن الكريم 114 سورة، أولها الفاتحة وآخرها سورة الناس.',
      source: 'الإتقان في علوم القرآن للسيوطي',
      difficulty: DifficultyLevel.beginner,
      status: ContentStatus.underReview,
      reviewerName: 'هيئة التدقيق العلمي',
      reviewDate: '2026-09-01',
    ),

    // 6. الحديث النبوي
    QuizQuestion(
      id: 'had_1',
      type: QuestionType.flashCard,
      prompt: 'ما نص الحديث النبوي الشريف في حسن الخلق؟',
      cardAnswer: '«إن من أحبكم إليّ وأقربكم مني مجلساً يوم القيامة أحاسنكم أخلاقاً».',
      explanation: 'يرغب النبي ﷺ أمته في التخلق بمكارم الأخلاق واللين والبشاشة.',
      source: 'سنن الترمذي، حديث حسن',
      difficulty: DifficultyLevel.beginner,
      status: ContentStatus.underReview,
      reviewerName: 'هيئة التدقيق العلمي',
      reviewDate: '2026-09-01',
    ),
    QuizQuestion(
      id: 'had_2',
      type: QuestionType.trueFalse,
      prompt: 'الحديث الصحيح هو ما اتصل سنده بنقل العدل الضابط عن مثله وسلم من الشذوذ والعلة.',
      options: ['صحيح', 'خطأ'],
      correctIndex: 0,
      explanation: 'هذا هو التعريف المعتمد عند علماء الحديث لصحة الرواية وقبولها.',
      source: 'مقدمة ابن الصلاح في علوم الحديث',
      difficulty: DifficultyLevel.intermediate,
      status: ContentStatus.underReview,
      reviewerName: 'هيئة التدقيق العلمي',
      reviewDate: '2026-09-01',
    ),

    // 7. الأخلاق والآداب
    QuizQuestion(
      id: 'eth_1',
      type: QuestionType.matching,
      prompt: 'صِل كل أدب إسلامي بثمرته في المجتمع.',
      pairs: {
        'الصدق': 'يهدي إلى البر والجنة',
        'إفشاء السلام': 'ينشر المحبة والألفة بين الناس',
        'كف الأذى': 'يحفظ حرمات المسلمين وأعراضهم',
      },
      explanation: 'الأخلاق الإسلامية تجمع بين الأجر الأخروي الكبير والأثر الإيجابي الواقعي في تماسك المجتمع.',
      source: 'الأدب المفرد للإمام البخاري',
      difficulty: DifficultyLevel.beginner,
      status: ContentStatus.underReview,
      reviewerName: 'هيئة التدقيق العلمي',
      reviewDate: '2026-09-01',
    ),
    QuizQuestion(
      id: 'eth_2',
      type: QuestionType.fillBlank,
      prompt: 'أكمل قول النبي ﷺ: «المسلم من سَلِم المسلمون من لسانه و_____.»',
      correctText: 'يده',
      alternativeAnswers: ['يده', 'ويده'],
      explanation: 'المسلم الحق لا يؤذي أحداً لا بقول ولا بفعل.',
      source: 'صحيح البخاري، حديث رقم 10',
      difficulty: DifficultyLevel.beginner,
      status: ContentStatus.underReview,
      reviewerName: 'هيئة التدقيق العلمي',
      reviewDate: '2026-09-01',
    ),

    // 8. المناسبات والتقويم
    QuizQuestion(
      id: 'occ_1',
      type: QuestionType.multipleChoice,
      prompt: 'كم عدد الأشهر الحرم في التقويم الهجري؟',
      options: ['أربعة أشهر', 'ثلاثة أشهر', 'شهر واحد', 'ستة أشهر'],
      correctIndex: 0,
      explanation: 'الأشهر الحرم أربعة: ثلاثة متتالية (ذو القعدة، ذو الحجة، المحرم) وواحد منفرد (رجب).',
      source: 'سورة التوبة، الآية 36؛ وصحيح البخاري حديث 4662',
      difficulty: DifficultyLevel.beginner,
      status: ContentStatus.underReview,
      reviewerName: 'هيئة التدقيق العلمي',
      reviewDate: '2026-09-01',
    ),
    QuizQuestion(
      id: 'occ_2',
      type: QuestionType.flashCard,
      prompt: 'متى يبدأ التقويم الهجري الإسلامي؟',
      cardAnswer: 'اعتُمد ابتداء التقويم من سنة الهجرة النبوية المباركة في عهد الخليفة عمر بن الخطاب رضي الله عنه.',
      explanation: 'اختار الصحابة الهجرة لأنها فرقت بين الحق والباطل وكانت بداية تأسيس دولة الإسلام.',
      source: 'تاريخ الطبري، الجزء الثاني',
      difficulty: DifficultyLevel.intermediate,
      status: ContentStatus.underReview,
      reviewerName: 'هيئة التدقيق العلمي',
      reviewDate: '2026-09-01',
    ),

    // 9. التاريخ الإسلامي
    QuizQuestion(
      id: 'hist_1',
      type: QuestionType.ordering,
      prompt: 'رتّب الخلفاء الراشدين رضي الله عنهم حسب تعاقبهم في الخلافة.',
      correctOrder: [
        'أبو بكر الصديق',
        'عمر بن الخطاب',
        'عثمان بن عفان',
        'علي بن أبي طالب'
      ],
      explanation: 'تولى الخلافة الراشدة بالترتيب الصديق ثم الفاروق ثم ذو النورين ثم أبو السبطين رضي الله عنهم أجمعين.',
      source: 'تاريخ الخلفاء للإمام السيوطي',
      difficulty: DifficultyLevel.beginner,
      status: ContentStatus.underReview,
      reviewerName: 'هيئة التدقيق العلمي',
      reviewDate: '2026-09-01',
    ),
  ];

  static List<QuizQuestion> getQuestionsForLesson({int worldIndex = 0, int lessonIndex = 0}) {
    switch (worldIndex) {
      case 0:
        return allQuestions.where((q) => q.id.startsWith('pil_') || q.id.startsWith('pray_') || q.id.startsWith('aq_')).take(6).toList();
      case 1:
        return allQuestions.where((q) => q.id.startsWith('seer_') || q.id.startsWith('had_')).toList();
      case 2:
        return allQuestions.where((q) => q.id.startsWith('eth_') || q.id.startsWith('had_')).toList();
      case 3:
        return allQuestions.where((q) => q.id.startsWith('qur_') || q.id.startsWith('had_')).toList();
      case 4:
        return allQuestions.where((q) => q.id.startsWith('occ_') || q.id.startsWith('hist_')).toList();
      default:
        return allQuestions.take(6).toList();
    }
  }

  static List<QuizQuestion> getQuestionsForTopic(String topicId) {
    return allQuestions.where((q) => q.id.startsWith(_prefixForTopic(topicId))).toList();
  }

  static String _prefixForTopic(String topicId) => switch (topicId) {
    'aqeedah' => 'aq_',
    'pillars' => 'pil_',
    'prayer' => 'pray_',
    'seerah' => 'seer_',
    'quran' => 'qur_',
    'hadith' => 'had_',
    'ethics' => 'eth_',
    'occasions' => 'occ_',
    'history' => 'hist_',
    _ => '',
  };
}
