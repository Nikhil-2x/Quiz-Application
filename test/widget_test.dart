import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quiz_app/screens/home_screen.dart';

void main() {
  testWidgets('Home screen validates name before starting quiz', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));

    final startButton = find.widgetWithText(ElevatedButton, 'Start Quiz');
    expect(startButton, findsOneWidget);

    ElevatedButton button = tester.widget(startButton);
    expect(button.onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'Nobita');
    await tester.pump();

    button = tester.widget(startButton);
    expect(button.onPressed, isNotNull);
  });
}
