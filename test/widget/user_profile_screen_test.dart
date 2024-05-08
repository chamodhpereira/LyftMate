import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lyft_mate/screens/profile/user_profile_screen.dart';
import 'package:lyft_mate/userprofile_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import '../mock.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseApp extends Mock implements FirebaseApp {}

void main() {
  // setUpAll(() async {
  //   // TestWidgetsFlutterBinding.ensureInitialized();
  //   //
  //   // // Create mock instances
  //   // final mockFirebaseApp = MockFirebaseApp();
  //   // final mockFirebaseAuth = MockFirebaseAuth();
  //   // final mockFirebaseFirestore = MockFirebaseFirestore();
  //   //
  //   // // Mock Firebase.initializeApp to return the mocked Firebase App
  //   // when(Firebase.initializeApp).thenAnswer((_) async => mockFirebaseApp);
  //   //
  //   // // Set up FirebaseAuth to use the mocked app
  //   // when(() => FirebaseAuth.instance).thenReturn(mockFirebaseAuth);
  //   // when(() => FirebaseFirestore.instance).thenReturn(mockFirebaseFirestore);
  //   //
  //   // // Initialize Firebase with the mocked setup
  //   // await Firebase.initializeApp();
  // });

  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
    // registerFallbackValue(FakeOfferRideEvent());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: UserProfileScreen(),
      ),
    );
  }

  testWidgets('UserProfileScreen displays loading indicator while waiting for data', (WidgetTester tester) async {
    // Render the UserProfileScreen
    await tester.pumpWidget(createWidgetUnderTest());

    // Check for the CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}