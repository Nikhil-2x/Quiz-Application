import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String name;

  QuizScreen({required this.name});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List questions = [];
  int currentIndex = 0;
  int score = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  void loadQuestions() async {
    questions = await FirebaseService().fetchQuestions();
    setState(() => isLoading = false);
  }

  // void checkAnswer(String selected) {
  //   if (selected == questions[currentIndex]['answer']) {
  //     score++;
  //   }

  //   if (currentIndex < questions.length - 1) {
  //     setState(() => currentIndex++);
  //   } else {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (_) => ResultScreen(
  //           score: score,
  //           total: questions.length,
  //           name: widget.name,
  //         ),
  //       ),
  //     );
  //   }
  // }

  void checkAnswer(String selected) {
    bool isCorrect = selected == questions[currentIndex]['answer'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isCorrect ? "Correct ✅" : "Wrong ❌"),
        content: Text(
          isCorrect
              ? "Good job!"
              : "Correct answer: ${questions[currentIndex]['answer']}",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              if (isCorrect) score++;

              if (currentIndex < questions.length - 1) {
                setState(() => currentIndex++);
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResultScreen(
                      score: score,
                      total: questions.length,
                      name: widget.name,
                    ),
                  ),
                );
              }
            },
            child: Text("Next"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());

    var q = questions[currentIndex];

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
                  q['question'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Options
            ...q['options'].map<Widget>((opt) {
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
            }).toList(),
          ],
        ),
      ),
    );
  }
}
