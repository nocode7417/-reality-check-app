// Basic Flutter widget test for Reality Check app.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reality_check/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: RealityCheckApp(),
      ),
    );

    // Verify the app renders without errors
    await tester.pumpAndSettle();

    // App should have loaded
    expect(find.byType(RealityCheckApp), findsOneWidget);
  });
}
