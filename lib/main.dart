import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quiz_app/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: String.fromEnvironment("FIREBASE_API_KEY"),
      appId: String.fromEnvironment("FIREBASE_APP_ID"),
      messagingSenderId: String.fromEnvironment("FIREBASE_MESSAGING_SENDER_ID"),
      projectId: String.fromEnvironment("FIREBASE_PROJECT_ID"),
      storageBucket: String.fromEnvironment("FIREBASE_STORAGE_BUCKET"),
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz App',
      theme: ThemeData(
        primaryColor: Colors.indigo,
        scaffoldBackgroundColor: Color(0xFFF5F7FB),

        appBarTheme: AppBarTheme(backgroundColor: Colors.indigo, elevation: 0),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        textTheme: TextTheme(bodyMedium: TextStyle(fontSize: 16)),
      ),
      home: HomeScreen(),
    );
  }
}
