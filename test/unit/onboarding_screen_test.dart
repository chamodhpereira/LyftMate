import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lyft_mate/screens/onboarding/onboarding_screen.dart';
import 'package:lyft_mate/screens/welcome/welcome_screen.dart';

void main() {
  testWidgets('OnBoardingScreen UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: OnBoardingScreen(),
    ));

    // Verify the presence of "SKIP" button
    expect(find.text('SKIP'), findsOneWidget);

    // Verify the presence of PageView
    expect(find.byType(PageView), findsOneWidget);

    // Verify the presence of "Next" button
    expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);

    // Get initial page index
    final initialPageIndex = tester.widget<PageView>(
      find.byType(PageView),
    ).controller!.page!.round();

    // Tap on the "Next" button until the last page and verify page slide/scroll
    for (int i = initialPageIndex; i < demoData.length - 1; i++) {
      await tester.tap(find.byIcon(Icons.arrow_forward_ios));
      await tester.pumpAndSettle();
    }

    // Verify navigation to WelcomeScreen after reaching the last page
    await tester.tap(find.byIcon(Icons.arrow_forward_ios));
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
  });
}





