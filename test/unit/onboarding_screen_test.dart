import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lyft_mate/screens/onboarding/onboarding_screen.dart';
import 'package:lyft_mate/screens/welcome/welcome_screen.dart';

void main() {
  testWidgets('OnBoardingScreen Forward Button Navigation Test', (WidgetTester tester) async {
    // Load the OnBoardingScreen widget
    await tester.pumpWidget(MaterialApp(
      home: OnBoardingScreen(),
    ));

    // Swipe through all the pages to the last one
    for (int i = 0; i < 3; i++) {
      await tester.drag(find.byType(PageView), const Offset(-400.0, 0.0));
      await tester.pumpAndSettle();
    }

    // Check that the last page is displayed
    expect(find.text('Save the Planet'), findsOneWidget);

    // Tap the forward button
    final Finder forwardButton = find.byKey(Key('forward_button'));
    await tester.ensureVisible(forwardButton);
    await tester.tap(forwardButton);
    await tester.pumpAndSettle();

    // Check if navigation to the WelcomeScreen occurs
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('OnBoardingScreen Skip Button Navigation Test', (WidgetTester tester) async {
    // Load the OnBoardingScreen widget
    await tester.pumpWidget(MaterialApp(
      home: OnBoardingScreen(),
    ));

    // Tap the "SKIP" button
    await tester.tap(find.text('SKIP'));
    await tester.pumpAndSettle();

    // Check if navigation to the WelcomeScreen occurs
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });
}





