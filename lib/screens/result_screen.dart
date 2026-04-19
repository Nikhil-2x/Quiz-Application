import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final String name;

  ResultScreen({required this.score, required this.total, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Result")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 80, color: Colors.orange),

            SizedBox(height: 20),

            Text(
              "Great Job, $name!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Text(
              "Your Score",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),

            SizedBox(height: 10),

            Text(
              "$score / $total",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 30),

            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: score.toDouble(),
                      title: "Correct",
                    ),
                    PieChartSectionData(
                      value: (total - score).toDouble(),
                      title: "Wrong",
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                );
              },
              icon: Icon(Icons.refresh),
              label: Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
