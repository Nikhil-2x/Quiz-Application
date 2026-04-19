import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/quiz_attempt.dart';
import '../services/firebase_service.dart';
import 'home_screen.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int total;
  final String name;
  final String? saveErrorMessage;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.name,
    this.saveErrorMessage,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late Future<List<QuizAttempt>> recentAttemptsFuture;

  @override
  void initState() {
    super.initState();
    recentAttemptsFuture = FirebaseService().fetchRecentAttempts(
      name: widget.name,
    );
  }

  double get percentage =>
      widget.total == 0 ? 0 : (widget.score / widget.total) * 100;

  String get performanceLabel {
    if (percentage >= 90) return 'Outstanding';
    if (percentage >= 75) return 'Great Work';
    if (percentage >= 50) return 'Good Progress';
    return 'Keep Practicing';
  }

  String get performanceMessage {
    if (percentage >= 90) return 'You are doing excellent. Keep it up!';
    if (percentage >= 75) return 'Strong performance with solid accuracy.';
    if (percentage >= 50) return 'Nice effort. Review and improve your score.';
    return 'Do not worry. A few more rounds will help a lot.';
  }

  String formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year;
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  Widget buildLegendItem({
    required Color color,
    required String label,
    required int value,
    required int total,
  }) {
    final ratio = total == 0 ? 0 : (value / total) * 100;
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: $value (${ratio.toStringAsFixed(0)}%)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final wrongCount = widget.total - widget.score;

    final correctValue = widget.score == 0 ? 0.0001 : widget.score.toDouble();
    final wrongValue = wrongCount == 0 ? 0.0001 : wrongCount.toDouble();

    final sections = <PieChartSectionData>[
      PieChartSectionData(
        value: correctValue,
        showTitle: false,
        color: Colors.green.shade500,
        radius: 56,
      ),
      PieChartSectionData(
        value: wrongValue,
        showTitle: false,
        color: Colors.red.shade500,
        radius: 56,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text("Result")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF151C33),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Color(0xFF2A355B)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 74,
                      color: Colors.amber.shade700,
                    ),
                    SizedBox(height: 12),
                    Text(
                      '$performanceLabel, ${widget.name}!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      performanceMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Color(0xFFB4BED9)),
                    ),
                    SizedBox(height: 18),
                    Text(
                      '${widget.score} / ${widget.total}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}% Accuracy',
                      style: TextStyle(fontSize: 15, color: Color(0xFF9AA4C3)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF151C33),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Color(0xFF2A355B)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Performance Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 3,
                              centerSpaceRadius: 54,
                              startDegreeOffset: -90,
                              sections: sections,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${percentage.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'Score',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF9AA4C3),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    buildLegendItem(
                      color: Colors.green.shade500,
                      label: 'Correct',
                      value: widget.score,
                      total: widget.total,
                    ),
                    SizedBox(height: 8),
                    buildLegendItem(
                      color: Colors.red.shade500,
                      label: 'Wrong',
                      value: wrongCount,
                      total: widget.total,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              if (widget.saveErrorMessage != null)
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Color(0xFF311116),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF7F1D1D)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFFCA5A5),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Result shown, but attempt was not saved: ${widget.saveErrorMessage}',
                          style: TextStyle(color: Color(0xFFFCA5A5)),
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF151C33),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Color(0xFF2A355B)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Attempts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8),
                    FutureBuilder<List<QuizAttempt>>(
                      future: recentAttemptsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (snapshot.hasError) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Could not load history right now.',
                              style: TextStyle(color: Color(0xFFFCA5A5)),
                            ),
                          );
                        }

                        final attempts = snapshot.data ?? [];
                        if (attempts.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'No attempts available yet.',
                              style: TextStyle(color: Color(0xFF9AA4C3)),
                            ),
                          );
                        }

                        return Column(
                          children: attempts.map((attempt) {
                            return Container(
                              margin: EdgeInsets.only(top: 10),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFF0F1630),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Color(0xFF2A355B)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withValues(
                                        alpha: 0.16,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${attempt.percentage.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${attempt.score}/${attempt.total} correct',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          formatDateTime(attempt.completedAt),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF9AA4C3),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                  );
                },
                icon: Icon(Icons.refresh),
                label: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
