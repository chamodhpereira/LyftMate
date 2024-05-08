// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:lyft_mate/screens/signup/screens/signup_screen.dart';
// import 'package:lyft_mate/screens/otp/otp_screen.dart';
// import 'package:lyft_mate/services/otp/otp_service.dart';
// import 'package:mockito/mockito.dart';
//
// import '../mock.dart';
// import '../twillio_mock.dart';
//
// void main() {
//
//   setupFirebaseAuthMocks();
//
//   setUpAll(() async {
//     await Firebase.initializeApp();
//   });
//
//
//   group('SignupScreen Tests', () {
//     MockTwilioVerification mockTwilioVerification = MockTwilioVerification();
//
//     setUp(() {
//       // mockTwilioVerification = MockTwilioVerification();
//
//       // Set the mock instance before tests
//       TwilioVerification.setMock(mockTwilioVerification);
//
//       // Setup the mock to return 'Successful' when sendCode is called
//       when(mockTwilioVerification.sendCode(any))
//           .thenAnswer((_) async => 'Successful');
//     });
//
//     tearDown(() {
//       // Reset the singleton to avoid side effects in other tests
//       TwilioVerification.setMock(TwilioVerification()); // Reset with a new instance
//     });
//
//     testWidgets('Test for successful OTP sending', (WidgetTester tester) async {
//       await tester.pumpWidget(MaterialApp(home: SignupScreen()));
//
//       // Enter phone number
//       await tester.enterText(find.byType(TextField), '1234567890');
//       // Tap the proceed button
//       await tester.tap(find.text('PROCEED'.toUpperCase()));
//       await tester.pumpAndSettle(); // Ensure animation and navigation are complete
//
//       // Verify that the correct method was called on the mock
//       verify(mockTwilioVerification.sendCode('+941234567890')).called(1);
//
//       // Assertions to ensure the navigation or error display worked as expected
//     });
//   });
// }
