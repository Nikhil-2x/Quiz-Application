import 'package:flutter/material.dart';
import '../models/answered_question.dart';
import '../models/question.dart';
import '../services/ai_api_service.dart';
import '../services/firebase_service.dart';
import '../widgets/hint_dialog.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String name;

  const QuizScreen({super.key, required this.name});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> questions = [];
  final List<AnsweredQuestion> answeredQuestions = [];
  final AiApiService aiApiService = AiApiService();
  int currentIndex = 0;
  int score = 0;
  int wrongAttemptsForCurrentQuestion = 0;
  bool isLoading = true;
  String? errorMessage;
  bool isSavingResult = false;
  bool isProcessingAnswer = false;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedQuestions = await FirebaseService().fetchQuestions();

      if (!mounted) return;

      setState(() {
        questions = fetchedQuestions;
        currentIndex = 0;
        score = 0;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> checkAnswer(String selected) async {
    final currentQuestion = questions[currentIndex];
    final isCorrect = selected == currentQuestion.answer;

    setState(() {
      isProcessingAnswer = true;
    });

    if (isCorrect) {
      score++;

      _recordFinalAttempt(
        question: currentQuestion,
        selected: selected,
        correct: true,
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Correct ✅'),
          content: Text('Great answer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Next Question'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      await _advanceToNextQuestionOrFinish();
      return;
    }

    if (wrongAttemptsForCurrentQuestion == 0) {
      wrongAttemptsForCurrentQuestion = 1;

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 14),
              Expanded(child: Text('Fetching hint...')),
            ],
          ),
        ),
      );

      String hintText;
      try {
        hintText = await aiApiService.fetchHint(
          correct: currentQuestion.answer,
          question: currentQuestion.question,
          selected: selected,
        );
      } catch (_) {
        hintText =
            'No hint available right now. Correct answer: ${currentQuestion.answer}';
      }

      if (!mounted) return;

      Navigator.pop(context);

      await showDialog(
        context: context,
        builder: (_) => HintDialog(hint: hintText),
      );

      setState(() {
        isProcessingAnswer = false;
      });

      return;
    }

    _recordFinalAttempt(
      question: currentQuestion,
      selected: selected,
      correct: false,
    );

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Wrong ❌'),
        content: Text('Correct answer: ${currentQuestion.answer}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Next Question'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    await _advanceToNextQuestionOrFinish();
  }

  void _recordFinalAttempt({
    required Question question,
    required String selected,
    required bool correct,
  }) {
    answeredQuestions.add(
      AnsweredQuestion(
        category: question.category ?? 'General',
        question: question.question,
        options: question.options,
        correctAnswer: question.answer,
        selectedAnswer: selected,
        correct: correct,
      ),
    );
  }

  Future<void> _advanceToNextQuestionOrFinish() async {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        wrongAttemptsForCurrentQuestion = 0;
        isProcessingAnswer = false;
      });
      return;
    }

    await finishQuiz();
  }

  Future<void> finishQuiz() async {
    setState(() {
      isSavingResult = true;
    });

    String? saveErrorMessage;

    try {
      await FirebaseService().saveQuizAttempt(
        name: widget.name,
        score: score,
        total: questions.length,
      );
    } catch (e) {
      saveErrorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    if (!mounted) return;

    setState(() {
      isSavingResult = false;
      isProcessingAnswer = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          score: score,
          total: questions.length,
          name: widget.name,
          answeredQuestions: answeredQuestions,
          saveErrorMessage: saveErrorMessage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Quiz")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text("Quiz")),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 54, color: colorScheme.error),
                SizedBox(height: 12),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                ElevatedButton(onPressed: loadQuestions, child: Text("Retry")),
              ],
            ),
          ),
        ),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Quiz")),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.quiz_outlined, size: 54, color: colorScheme.primary),
                SizedBox(height: 12),
                Text(
                  "No valid questions found.",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text(
                  "Add question documents in Firestore and try again.",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(onPressed: loadQuestions, child: Text("Reload")),
              ],
            ),
          ),
        ),
      );
    }

    final q = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text("Quiz")),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Bar
                LinearProgressIndicator(
                  value: (currentIndex + 1) / questions.length,
                ),

                SizedBox(height: 20),

                Text(
                  "Question ${currentIndex + 1}/${questions.length}",
                  style: TextStyle(fontSize: 16, color: Color(0xFF9AA4C3)),
                ),

                SizedBox(height: 10),

                // Question Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      q.question,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Options
                ...q.options.map<Widget>((opt) {
                  return Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF151C33),
                        foregroundColor: colorScheme.onSurface,
                        elevation: 0,
                        side: BorderSide(color: Color(0xFF2A355B)),
                        padding: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 20,
                        ),
                      ),
                      onPressed: isProcessingAnswer || isSavingResult
                          ? null
                          : () => checkAnswer(opt),
                      child: Text(opt),
                    ),
                  );
                }),
              ],
            ),
          ),
          if (isSavingResult)
            Container(
              color: Colors.black.withValues(alpha: 0.45),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
