// This is a basic Flutter widget test for the SimpleStep Flutter app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simple_step_flutter/main.dart';
import 'package:simple_step_flutter/utils/app_icons.dart';

void main() {
  testWidgets('App launches and shows main screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Let the app initialize (important for async operations)
    await tester.pumpAndSettle();

    // Verify that the main screen elements are present
    expect(find.text('Simple Step Counter'), findsOneWidget);

    // Check for key UI elements that should be present
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.byIcon(Icons.health_and_safety_outlined), findsOneWidget);
    expect(find.byIcon(Icons.api), findsOneWidget);

    // Check for debug info toggle button
    expect(find.text('Show Debug Info'), findsOneWidget);
  });

  testWidgets('Debug info toggle works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Initially, debug info should not be shown
    expect(find.text('Show Debug Info'), findsOneWidget);

    // Tap the debug info toggle button
    await tester.tap(find.text('Show Debug Info'));
    await tester.pumpAndSettle();

    // Now it should show "Hide Debug Info"
    expect(find.text('Hide Debug Info'), findsOneWidget);
  });

  testWidgets('Goal setting agent navigation works', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Tap the API icon to open goal setting agent
    await tester.tap(find.byIcon(AppIcons.brain()));
    await tester.pumpAndSettle();

    // Verify that the Goal Setting Agent screen is shown
    expect(find.text('Goal Setting Agent'), findsOneWidget);
  });
}
