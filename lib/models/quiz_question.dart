enum QuestionType {
  multipleChoice,
  trueFalse,
  ordering,
  matching,
  fillBlank,
  flashCard,
}

enum ContentStatus {
  draft,        // مسودة
  underReview,  // قيد المراجعة
  approved,     // معتمد
  published,    // منشور
}

enum DifficultyLevel {
  beginner,     // مبتدئ
  intermediate, // متوسط
  advanced,     // متقدم
}

class QuizQuestion {
  const QuizQuestion({
    this.id = '',
    this.type = QuestionType.multipleChoice,
    required this.prompt,
    this.options = const [],
    this.correctIndex = 0,
    this.correctOrder = const [],
    this.pairs = const {},
    this.correctText = '',
    this.alternativeAnswers = const [],
    this.cardAnswer = '',
    required this.explanation,
    required this.source,
    this.difficulty = DifficultyLevel.beginner,
    this.status = ContentStatus.underReview,
    this.reviewerName,
    this.reviewDate,
    this.imageUrl,
    this.audioUrl,
  });

  final String id;
  final QuestionType type;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final List<String> correctOrder;
  final Map<String, String> pairs;
  final String correctText;
  final List<String> alternativeAnswers;
  final String cardAnswer;
  final String explanation;
  final String source;
  final DifficultyLevel difficulty;
  final ContentStatus status;
  final String? reviewerName;
  final String? reviewDate;
  final String? imageUrl;
  final String? audioUrl;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'prompt': prompt,
    'options': options,
    'correctIndex': correctIndex,
    'correctOrder': correctOrder,
    'pairs': pairs,
    'correctText': correctText,
    'alternativeAnswers': alternativeAnswers,
    'cardAnswer': cardAnswer,
    'explanation': explanation,
    'source': source,
    'difficulty': difficulty.name,
    'status': status.name,
    'reviewerName': reviewerName,
    'reviewDate': reviewDate,
    'imageUrl': imageUrl,
    'audioUrl': audioUrl,
  };

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String? ?? '',
      type: QuestionType.values.byName(json['type'] as String? ?? 'multipleChoice'),
      prompt: json['prompt'] as String? ?? '',
      options: (json['options'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      correctIndex: json['correctIndex'] as int? ?? 0,
      correctOrder: (json['correctOrder'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      pairs: (json['pairs'] as Map?)?.map((k, v) => MapEntry(k.toString(), v.toString())) ?? const {},
      correctText: json['correctText'] as String? ?? '',
      alternativeAnswers: (json['alternativeAnswers'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      cardAnswer: json['cardAnswer'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      source: json['source'] as String? ?? '',
      difficulty: DifficultyLevel.values.byName(json['difficulty'] as String? ?? 'beginner'),
      status: ContentStatus.values.byName(json['status'] as String? ?? 'underReview'),
      reviewerName: json['reviewerName'] as String?,
      reviewDate: json['reviewDate'] as String?,
      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
    );
  }
}
