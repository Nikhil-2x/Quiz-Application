import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/answered_question.dart';

class AiApiService {
  AiApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'https://quiz-app-backend-fbn6.onrender.com';

  final http.Client _client;

  Future<String> fetchHint({
    required String question,
    required String correct,
    required String selected,
  }) async {
    final uri = Uri.parse('$_baseUrl/hint');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'question': question,
        'correct': correct,
        'selected': selected,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Hint API failed with status ${response.statusCode}.');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final hint = decoded['hint'];

    if (hint is! String || hint.trim().isEmpty) {
      throw Exception('Hint API returned an invalid hint payload.');
    }

    return hint.trim();
  }

  Future<String> analyzeQuiz({
    required String name,
    required List<AnsweredQuestion> questions,
    required int score,
    required int total,
  }) async {
    final uri = Uri.parse('$_baseUrl/analyze');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'questions': questions.map((item) => item.toAnalysisJson()).toList(),
        'score': score,
        'total': total,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Analyze API failed with status ${response.statusCode}.');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final analysis = decoded['analysis'];

    if (analysis is! String || analysis.trim().isEmpty) {
      throw Exception('Analyze API returned an invalid analysis payload.');
    }

    return analysis.trim();
  }
}
