// This is a basic Flutter widget test for Sushi Roll Rush.

import 'package:flutter_test/flutter_test.dart';

import 'package:sushi_roll_rush/main.dart';

void main() {
  testWidgets('SushiRollRushApp starts correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SushiRollRushApp());

    // Verify that the game screen is present
    expect(find.byType(GameScreen), findsOneWidget);
  });
}
