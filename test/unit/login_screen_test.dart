// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:lyft_mate/screens/login/login_form.dart';
// import 'package:lyft_mate/screens/login/login_screen.dart';
// import 'package:lyft_mate/screens/signup/screens/signup_screen.dart';
// import 'package:mockito/mockito.dart';
//
// // Mock classes
// class MockFirebaseCore extends Mock implements Firebase {}
//
// class FakeFirebaseApp extends Fake implements FirebaseApp {}
//
// void main() {
//   TestWidgetsFlutterBinding.ensureInitialized();
//
//   group('FirebaseApp Tests', () {
//     final MockFirebaseCore mockFirebaseCore = MockFirebaseCore();
//     const FirebaseOptions testOptions = FirebaseOptions(
//       apiKey: 'apiKey',
//       appId: 'appId',
//       messagingSenderId: 'messagingSenderId',
//       projectId: 'projectId',
//     );
//
//     setUpAll(() async {
//       when(mockFirebaseCore.initializeApp(
//         name: anyNamed('name'),
//         options: anyNamed('options'),
//       )).thenAnswer((_) async {
//         return FakeFirebaseApp();
//       });
//
//       await Firebase.initializeApp(
//         name: 'testApp',
//         options: testOptions,
//         // This parameter is illustrative; in actual code, you'd initialize differently
//       );
//     });
//
//     testWidgets('LoginScreen UI Test', (WidgetTester tester) async {
//       // Build your widget
//       await tester.pumpWidget(MaterialApp(home: LoginScreen()));
//
//       // Verify that a widget is displayed
//       expect(find.byType(Image), findsOneWidget);
//       expect(find.byType(LoginForm), findsOneWidget);
//
//       // Interact with your widget
//       await tester.tap(find.byKey(Key('signup_button')));
//       await tester.pumpAndSettle();
//
//       // Verify another widget is displayed after interaction
//       expect(find.byType(SignupScreen), findsOneWidget);
//     });
//   });
// }
//
//
//
//
// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_test/flutter_test.dart';
// // import 'package:lyft_mate/screens/login/login_form.dart';
// // import 'package:lyft_mate/screens/signup/screens/signup_screen.dart';
// // import 'package:lyft_mate/screens/login/login_screen.dart';
// //
// // import '../mock.dart';
// //
// // void main() {
// //   setupFirebaseAuthMocks();
// //
// //   setUpAll(() async {
// //     await Firebase.initializeApp();
// //   });
// //
// //   testWidgets('Login screen widget test', (WidgetTester tester) async {
// //     await tester.pumpWidget(MaterialApp(
// //       home: LoginScreen(),
// //     ));
// //
// //     // Verify that the login form is present
// //     expect(find.byType(LoginForm), findsOneWidget);
// //
// //     // Scroll to the signup button if it's not immediately visible
// //     final Finder signupButton = find.byKey(Key('signup_button'));
// //     await tester.ensureVisible(signupButton);
// //
// //     // Tap on the signup button and verify navigation
// //     await tester.tap(signupButton);
// //     await tester.pumpAndSettle(); // Wait for the navigation to complete
// //
// //     // Check if SignupScreen is present after navigation
// //     expect(find.byType(SignupScreen), findsOneWidget);
// //   });
// // }
