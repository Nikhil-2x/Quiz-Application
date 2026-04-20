class AnsweredQuestion {
  final String category;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String selectedAnswer;
  final bool correct;

  const AnsweredQuestion({
    required this.category,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.selectedAnswer,
    required this.correct,
  });

  Map<String, dynamic> toAnalysisJson() {
    return {
      'category': category,
      'correctAnswer': correctAnswer,
      'options': options,
      'question': question,
      'selectedAnswer': selectedAnswer,
    };
  }
}
