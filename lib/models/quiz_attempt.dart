import 'package:cloud_firestore/cloud_firestore.dart';

class QuizAttempt {
  final String id;
  final String name;
  final int score;
  final int total;
  final DateTime completedAt;

  const QuizAttempt({
    required this.id,
    required this.name,
    required this.score,
    required this.total,
    required this.completedAt,
  });

  double get percentage => total == 0 ? 0 : (score / total) * 100;

  factory QuizAttempt.fromMap(String id, Map<String, dynamic> data) {
    final rawName = data['name'];
    final rawScore = data['score'];
    final rawTotal = data['total'];
    final rawCompletedAt = data['completedAt'];

    if (rawName is! String || rawName.trim().isEmpty) {
      throw const FormatException('Invalid or missing name field.');
    }

    if (rawScore is! int || rawScore < 0) {
      throw const FormatException('Invalid or missing score field.');
    }

    if (rawTotal is! int || rawTotal <= 0) {
      throw const FormatException('Invalid or missing total field.');
    }

    DateTime parsedCompletedAt;
    if (rawCompletedAt is Timestamp) {
      parsedCompletedAt = rawCompletedAt.toDate();
    } else if (rawCompletedAt is DateTime) {
      parsedCompletedAt = rawCompletedAt;
    } else {
      throw const FormatException('Invalid or missing completedAt field.');
    }

    return QuizAttempt(
      id: id,
      name: rawName.trim(),
      score: rawScore,
      total: rawTotal,
      completedAt: parsedCompletedAt,
    );
  }
}
