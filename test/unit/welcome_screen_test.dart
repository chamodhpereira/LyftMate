import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lyft_mate/screens/welcome/welcome_screen.dart';
import 'package:lyft_mate/screens/login/login_screen.dart';

import '../mock.dart';

void main() {

  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });


  group('WelcomeScreen Tests', () {
    testWidgets('Verify image and texts are displayed correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: WelcomeScreen()));

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('LyftMate🚀'), findsOneWidget);
      expect(find.text('join the community, and enjoy the ride'), findsOneWidget);
    });

    testWidgets('Login button navigates to LoginScreen', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: WelcomeScreen()));
      await tester.tap(find.text('LOGIN'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Signup button navigates to LoginScreen', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: WelcomeScreen()));
      await tester.tap(find.text('SIGNUP'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
