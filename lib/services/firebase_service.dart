import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question.dart';
import '../models/quiz_attempt.dart';

class FirebaseService {
  final db = FirebaseFirestore.instance;

  Future<List<Question>> fetchQuestions() async {
    try {
      final snapshot = await db.collection('questions').get();
      final questions = <Question>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();

        try {
          questions.add(Question.fromMap(doc.id, data));
        } on FormatException {
          // Skip malformed documents so one bad record doesn't block the quiz.
          continue;
        }
      }

      return questions;
    } on FirebaseException catch (e) {
      throw Exception(
        'Failed to load questions: ${e.message ?? 'Unknown Firebase error'}',
      );
    }
  }

  Future<void> saveQuizAttempt({
    required String name,
    required int score,
    required int total,
  }) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      throw Exception('Name cannot be empty while saving the attempt.');
    }

    try {
      await db.collection('quiz_attempts').add({
        'name': trimmedName,
        'score': score,
        'total': total,
        'completedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw Exception(
        'Failed to save attempt: ${e.message ?? 'Unknown Firebase error'}',
      );
    }
  }

  Future<List<QuizAttempt>> fetchRecentAttempts({
    required String name,
    int limit = 5,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return [];
    }

    try {
      final query = await db
          .collection('quiz_attempts')
          .where('name', isEqualTo: trimmedName)
          .orderBy('completedAt', descending: true)
          .limit(limit)
          .get();

      return _parseAttempts(query.docs);
    } on FirebaseException {
      // Fallback query if composite index is not available yet.
      final fallback = await db
          .collection('quiz_attempts')
          .orderBy('completedAt', descending: true)
          .limit(limit * 5)
          .get();

      return _parseAttempts(
        fallback.docs,
        expectedName: trimmedName,
      ).take(limit).toList();
    }
  }

  List<QuizAttempt> _parseAttempts(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, {
    String? expectedName,
  }) {
    final attempts = <QuizAttempt>[];

    for (final doc in docs) {
      final data = doc.data();

      try {
        final attempt = QuizAttempt.fromMap(doc.id, data);

        if (expectedName != null && attempt.name != expectedName) {
          continue;
        }

        attempts.add(attempt);
      } on FormatException {
        continue;
      }
    }

    return attempts;
  }
}
