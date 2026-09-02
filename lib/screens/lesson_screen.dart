import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/curriculum_data.dart';
import '../models.dart';
import '../progress_store.dart';
import 'lesson_result_screen.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    required this.title,
    this.worldIndex,
    this.lessonIndex,
    this.customQuestions,
    this.isMistakeReview = false,
  });

  final String title;
  final int? worldIndex;
  final int? lessonIndex;
  final List<QuizQuestion>? customQuestions;
  final bool isMistakeReview;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> with SingleTickerProviderStateMixin {
  final _fillController = TextEditingController();
  late final List<QuizQuestion> _questions;
  int _current = 0;
  int? _selectedIndex;
  bool _answered = false;
  bool _lastCorrect = false;
  bool _cardRevealed = false;
  int _hearts = 5;
  int _correctAnswers = 0;
  int _xp = 0;
  List<String> _order = [];
  final Map<String, String> _matches = {};

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  QuizQuestion get _question => _questions[_current];

  @override
  void initState() {
    super.initState();
    _hearts = GameProgress.instance.hearts;

    if (widget.customQuestions != null && widget.customQuestions!.isNotEmpty) {
      _questions = List.from(widget.customQuestions!);
    } else if (widget.worldIndex != null && widget.lessonIndex != null) {
      _questions = CurriculumData.getQuestionsForLesson(
        worldIndex: widget.worldIndex!,
        lessonIndex: widget.lessonIndex!,
      );
    } else {
      _questions = sampleQuestions;
    }

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _prepareQuestion();
  }

  void _prepareQuestion() {
    final question = _question;
    _selectedIndex = null;
    _answered = false;
    _lastCorrect = false;
    _cardRevealed = false;
    _flipController.reset();
    _fillController.clear();
    _matches.clear();
    _order = question.type == QuestionType.ordering
        ? question.correctOrder.reversed.toList()
        : [];
  }

  @override
  void dispose() {
    _flipController.dispose();
    _fillController.dispose();
    super.dispose();
  }

  bool get _canCheck {
    return switch (_question.type) {
      QuestionType.multipleChoice ||
      QuestionType.trueFalse =>
        _selectedIndex != null,
      QuestionType.ordering => _order.isNotEmpty,
      QuestionType.matching => _matches.length == _question.pairs.length,
      QuestionType.fillBlank => _fillController.text.trim().isNotEmpty,
      QuestionType.flashCard => true,
    };
  }

  bool _evaluate() {
    return switch (_question.type) {
      QuestionType.multipleChoice ||
      QuestionType.trueFalse =>
        _selectedIndex == _question.correctIndex,
      QuestionType.ordering => _listsEqual(_order, _question.correctOrder),
      QuestionType.matching => _question.pairs.entries.every(
          (entry) => _matches[entry.key] == entry.value,
        ),
      QuestionType.fillBlank => _checkFillBlankAnswer(),
      QuestionType.flashCard => true,
    };
  }

  bool _checkFillBlankAnswer() {
    final userNormalized = _normalize(_fillController.text);
    if (userNormalized.contains(_normalize(_question.correctText))) return true;

    for (final alt in _question.alternativeAnswers) {
      if (userNormalized.contains(_normalize(alt))) return true;
    }
    return false;
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  String _normalize(String value) => value
      .trim()
      .replaceAll(RegExp(r'[\u064B-\u065F]'), '') // remove tashkeel
      .replaceAll(RegExp(r'[أإآ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي')
      .replaceAll(RegExp(r'\s+'), '');

  void _flipCard() {
    if (_cardRevealed) {
      _flipController.reverse();
      setState(() => _cardRevealed = false);
    } else {
      _flipController.forward();
      setState(() {
        _cardRevealed = true;
        if (!_answered) {
          _answered = true;
          _lastCorrect = true;
          _correctAnswers++;
          _xp += 10;
        }
      });
    }
  }

  void _checkAnswer() {
    if (!_canCheck) return;
    if (_question.type == QuestionType.flashCard && !_cardRevealed) {
      _flipCard();
      return;
    }

    final correct = _evaluate();
    setState(() {
      _lastCorrect = correct;
      _answered = true;
      if (correct) {
        _correctAnswers++;
        _xp += 10;
        if (widget.isMistakeReview) {
          GameProgress.instance.removeMistake(_question);
        }
      } else {
        _hearts = (_hearts - 1).clamp(0, 5);
        GameProgress.instance.addMistake(_question);
      }
    });
  }

  void _continue() {
    if (_current == _questions.length - 1) {
      final accuracy = _questions.isEmpty ? 100 : ((_correctAnswers / _questions.length) * 100).round();
      final stars = accuracy >= 90 ? 3 : (accuracy >= 65 ? 2 : 1);

      if (widget.worldIndex != null && widget.lessonIndex != null) {
        GameProgress.instance.finishLesson(
          worldIndex: widget.worldIndex!,
          lessonIndex: widget.lessonIndex!,
          earnedXp: _xp,
          remainingHearts: _hearts,
          stars: stars,
        );
      } else {
        GameProgress.instance.finishPractice(
          earnedXp: _xp,
          remainingHearts: _hearts,
        );
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LessonResultScreen(
            title: widget.title,
            correct: _correctAnswers,
            total: _questions.length,
            xp: _xp,
            hearts: _hearts,
          ),
        ),
      );
      return;
    }
    setState(() {
      _current++;
      _prepareQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_current + 1) / _questions.length;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'إغلاق الدرس',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 16),
            child: Row(
              children: [
                const Icon(Icons.favorite_rounded,
                    color: AppColors.error, size: 22),
                const SizedBox(width: 4),
                Text('$_hearts',
                    style: const TextStyle(fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 0),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 11,
                        backgroundColor: AppColors.line,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${_current + 1}/${_questions.length}',
                      style: const TextStyle(
                          color: AppColors.muted, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _QuestionTypeLabel(type: _question.type),
                        const SizedBox(height: 14),
                        Text(_question.prompt,
                            style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 25),
                        _buildQuestionBody(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_answered)
              _FeedbackPanel(
                question: _question,
                correct: _lastCorrect,
                userOrder: _order,
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: FilledButton(
                  key: const Key('lesson-action'),
                  onPressed:
                      _answered ? _continue : (_canCheck ? _checkAnswer : null),
                  style: FilledButton.styleFrom(
                    backgroundColor: _answered
                        ? (_lastCorrect ? AppColors.primary : AppColors.error)
                        : AppColors.primary,
                  ),
                  child: Text(
                    _answered
                        ? (_current == _questions.length - 1
                            ? 'عرض النتيجة'
                            : 'متابعة')
                        : (_question.type == QuestionType.flashCard
                            ? 'إظهار الإجابة'
                            : 'تحقق من الإجابة'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionBody() {
    return switch (_question.type) {
      QuestionType.multipleChoice || QuestionType.trueFalse => _ChoiceQuestion(
          question: _question,
          selectedIndex: _selectedIndex,
          answered: _answered,
          onSelected: (value) => setState(() => _selectedIndex = value),
        ),
      QuestionType.ordering => _OrderingQuestion(
          items: _order,
          enabled: !_answered,
          onReorder: (oldIndex, newIndex) {
            if (_answered) return;
            setState(() {
              if (newIndex > oldIndex) newIndex--;
              final item = _order.removeAt(oldIndex);
              _order.insert(newIndex, item);
            });
          },
        ),
      QuestionType.matching => _MatchingQuestion(
          pairs: _question.pairs,
          selected: _matches,
          enabled: !_answered,
          onChanged: (key, value) => setState(() => _matches[key] = value),
        ),
      QuestionType.fillBlank => TextField(
          controller: _fillController,
          enabled: !_answered,
          onChanged: (_) => setState(() {}),
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'اكتب الكلمة الناقصة',
            prefixIcon: Icon(Icons.edit_rounded),
          ),
        ),
      QuestionType.flashCard => _AnimatedFlashCard(
          question: _question,
          animation: _flipAnimation,
          onFlip: _flipCard,
        ),
    };
  }
}

class _QuestionTypeLabel extends StatelessWidget {
  const _QuestionTypeLabel({required this.type});

  final QuestionType type;

  @override
  Widget build(BuildContext context) {
    final (icon, text) = switch (type) {
      QuestionType.multipleChoice => (
          Icons.touch_app_rounded,
          'اختر الإجابة الصحيحة'
        ),
      QuestionType.trueFalse => (Icons.rule_rounded, 'صح أم خطأ؟'),
      QuestionType.ordering => (Icons.reorder_rounded, 'اسحب لترتيب العناصر'),
      QuestionType.matching => (
          Icons.compare_arrows_rounded,
          'صِل بين العناصر'
        ),
      QuestionType.fillBlank => (Icons.edit_note_rounded, 'أكمل العبارة'),
      QuestionType.flashCard => (Icons.style_rounded, 'بطاقة معرفة'),
    };
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 7),
        Flexible(
          child: Text(text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.primaryDark, fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }
}

class _ChoiceQuestion extends StatelessWidget {
  const _ChoiceQuestion({
    required this.question,
    required this.selectedIndex,
    required this.answered,
    required this.onSelected,
  });

  final QuizQuestion question;
  final int? selectedIndex;
  final bool answered;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(question.options.length, (index) {
        final selected = selectedIndex == index;
        final isCorrect = answered && index == question.correctIndex;
        final isWrong = answered && selected && !isCorrect;
        final color = isCorrect
            ? AppColors.primary
            : isWrong
                ? AppColors.error
                : selected
                    ? AppColors.primary
                    : AppColors.line;
        return Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: answered ? null : () => onSelected(index),
              borderRadius: BorderRadius.circular(17),
              child: Ink(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (selected || isCorrect)
                      ? color.withValues(alpha: .09)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                      color: color, width: selected || isCorrect ? 2 : 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 31,
                      height: 31,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            (selected || isCorrect) ? color : AppColors.canvas,
                        shape: BoxShape.circle,
                      ),
                      child: isCorrect
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 20)
                          : isWrong
                              ? const Icon(Icons.close_rounded,
                                  color: Colors.white, size: 20)
                              : Text('${index + 1}',
                                  style: TextStyle(
                                      color: selected
                                          ? Colors.white
                                          : AppColors.muted,
                                      fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(question.options[index],
                            style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 16,
                                fontWeight: FontWeight.w700))),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _OrderingQuestion extends StatelessWidget {
  const _OrderingQuestion(
      {required this.items, required this.enabled, required this.onReorder});

  final List<String> items;
  final bool enabled;
  final ReorderCallback onReorder;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: enabled,
      itemCount: items.length,
      onReorder: onReorder,
      itemBuilder: (context, index) => Card(
        key: ValueKey(items[index]),
        margin: const EdgeInsets.only(bottom: 9),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primarySoft,
            child: Text('${index + 1}',
                style: const TextStyle(
                    color: AppColors.primaryDark, fontWeight: FontWeight.w900)),
          ),
          title: Text(items[index],
              style: const TextStyle(fontWeight: FontWeight.w800)),
          trailing: Icon(Icons.drag_handle_rounded,
              color: enabled ? AppColors.muted : AppColors.line),
        ),
      ),
    );
  }
}

class _MatchingQuestion extends StatelessWidget {
  const _MatchingQuestion(
      {required this.pairs,
      required this.selected,
      required this.enabled,
      required this.onChanged});

  final Map<String, String> pairs;
  final Map<String, String> selected;
  final bool enabled;
  final void Function(String, String) onChanged;

  @override
  Widget build(BuildContext context) {
    final values = pairs.values.toList();
    final usedValues = selected.values.toSet();

    return Column(
      children: pairs.keys.map((key) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(15)),
                  child: Text(key,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w900)),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child:
                    Icon(Icons.compare_arrows_rounded, color: AppColors.muted),
              ),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selected[key],
                  decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 11, vertical: 8)),
                  hint: const Text('اختر'),
                  items: values.map((value) {
                    final isChosenElsewhere = usedValues.contains(value) && selected[key] != value;
                    return DropdownMenuItem(
                      value: value,
                      enabled: enabled && !isChosenElsewhere,
                      child: Text(
                        value,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isChosenElsewhere ? AppColors.muted.withValues(alpha: .5) : null,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: enabled
                      ? (value) {
                          if (value != null) onChanged(key, value);
                        }
                      : null,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _AnimatedFlashCard extends StatelessWidget {
  const _AnimatedFlashCard({
    required this.question,
    required this.animation,
    required this.onFlip,
  });

  final QuizQuestion question;
  final Animation<double> animation;
  final VoidCallback onFlip;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final angle = animation.value * math.pi;
        final isBack = animation.value >= 0.5;

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          alignment: Alignment.center,
          child: isBack
              ? Transform(
                  transform: Matrix4.identity()..rotateY(math.pi),
                  alignment: Alignment.center,
                  child: _cardSide(
                    color1: AppColors.primaryDark,
                    color2: AppColors.primary,
                    icon: Icons.lightbulb_rounded,
                    text: question.cardAnswer,
                    subtext: 'الإجابة والبيان الشافي',
                  ),
                )
              : _cardSide(
                  color1: const Color(0xFF243B64),
                  color2: AppColors.purple,
                  icon: Icons.style_rounded,
                  text: 'فكّر في المعنى والإجابة، ثم اضغط لقلب البطاقة',
                  subtext: 'اضغط لقلب البطاقة ومعرفة الإجابة',
                ),
        );
      },
    );
  }

  Widget _cardSide({
    required Color color1,
    required Color color2,
    required IconData icon,
    required String text,
    required String subtext,
  }) {
    return GestureDetector(
      onTap: onFlip,
      child: Container(
        constraints: const BoxConstraints(minHeight: 220),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color1, color2]),
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 24, offset: Offset(0, 12))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.gold, size: 42),
            const SizedBox(height: 18),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  height: 1.6),
            ),
            const SizedBox(height: 12),
            Text(
              subtext,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  const _FeedbackPanel({
    required this.question,
    required this.correct,
    required this.userOrder,
  });

  final QuizQuestion question;
  final bool correct;
  final List<String> userOrder;

  @override
  Widget build(BuildContext context) {
    final color = correct ? AppColors.primary : AppColors.error;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 12),
      decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          border: Border(top: BorderSide(color: color.withValues(alpha: .25)))),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                      correct
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: color),
                  const SizedBox(width: 8),
                  Text(
                    correct ? 'أحسنت! +10 XP' : 'إجابة غير صحيحة',
                    style: TextStyle(
                        color: color,
                        fontSize: 17,
                        fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              if (!correct && question.type == QuestionType.ordering) ...[
                const SizedBox(height: 8),
                const Text('الترتيب الصحيح هو:',
                    style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  children: question.correctOrder
                      .map((item) => Chip(
                            backgroundColor: AppColors.primarySoft,
                            label: Text(item,
                                style: const TextStyle(
                                    color: AppColors.primaryDark,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800)),
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                question.explanation,
                style: const TextStyle(
                    color: AppColors.ink, fontSize: 13.5, height: 1.5),
              ),
              const SizedBox(height: 4),
              Text(
                'المصدر: ${question.source}',
                style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
