import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/firebase_service.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String name;

  const QuizScreen({super.key, required this.name});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> questions = [];
  int currentIndex = 0;
  int score = 0;
  bool isLoading = true;
  String? errorMessage;
  bool isSavingResult = false;

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

  void checkAnswer(String selected) {
    final currentQuestion = questions[currentIndex];
    final isCorrect = selected == currentQuestion.answer;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isCorrect ? "Correct ✅" : "Wrong ❌"),
        content: Text(
          isCorrect ? "Good job!" : "Correct answer: ${currentQuestion.answer}",
        ),
        actions: [
          TextButton(
            onPressed: isSavingResult
                ? null
                : () {
                    Navigator.pop(context);

                    if (isCorrect) score++;

                    if (currentIndex < questions.length - 1) {
                      setState(() => currentIndex++);
                    } else {
                      finishQuiz();
                    }
                  },
            child: Text("Next"),
          ),
        ],
      ),
    );
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
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          score: score,
          total: questions.length,
          name: widget.name,
          saveErrorMessage: saveErrorMessage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                Icon(Icons.error_outline, size: 54, color: Colors.redAccent),
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
                Icon(Icons.quiz_outlined, size: 54, color: Colors.indigo),
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
      body: Padding(
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
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            SizedBox(height: 10),

            // Question Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  q.question,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 2,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  ),
                  onPressed: () => checkAnswer(opt),
                  child: Text(opt),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
