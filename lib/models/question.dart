class Question {
  final String id;
  final String question;
  final List<String> options;
  final String answer;
  final String? category;
  final String? difficulty;

  const Question({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
    this.category,
    this.difficulty,
  });

  factory Question.fromMap(String id, Map<String, dynamic> data) {
    final rawQuestion = data['question'];
    final rawOptions = data['options'];
    final rawAnswer = data['answer'];

    if (rawQuestion is! String || rawQuestion.trim().isEmpty) {
      throw const FormatException('Invalid or missing question field.');
    }

    if (rawOptions is! List) {
      throw const FormatException('Invalid or missing options field.');
    }

    final parsedOptions = rawOptions
        .whereType<String>()
        .map((option) => option.trim())
        .where((option) => option.isNotEmpty)
        .toList();

    if (parsedOptions.length < 2) {
      throw const FormatException('At least two options are required.');
    }

    if (rawAnswer is! String || rawAnswer.trim().isEmpty) {
      throw const FormatException('Invalid or missing answer field.');
    }

    final normalizedAnswer = rawAnswer.trim();

    if (!parsedOptions.contains(normalizedAnswer)) {
      throw const FormatException('Answer must be one of the options.');
    }

    return Question(
      id: id,
      question: rawQuestion.trim(),
      options: parsedOptions,
      answer: normalizedAnswer,
      category: data['category'] as String?,
      difficulty: data['difficulty'] as String?,
    );
  }
}
