import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController nameController = TextEditingController();

  bool get isNameValid => nameController.text.trim().isNotEmpty;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text("Quiz App")),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0E1530), Color(0xFF182448), Color(0xFF0A1022)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withValues(alpha: 0.18),
              ),
              child: Icon(Icons.quiz, size: 72, color: colorScheme.primary),
            ),

            SizedBox(height: 20),

            Text(
              "Welcome to Quiz App",
              style: TextStyle(
                fontSize: 26,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            Text(
              "Sharpen your knowledge with a clean and focused quiz experience.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFFB4BED9)),
            ),

            SizedBox(height: 30),

            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF151C33),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFF2A355B)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: "Enter your name",
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 54),
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                    ),
                    onPressed: isNameValid
                        ? () {
                            final trimmedName = nameController.text.trim();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QuizScreen(name: trimmedName),
                              ),
                            );
                          }
                        : null,
                    child: Text("Start Quiz"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
