import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lyft_mate/screens/offer_ride/ui/offer_ride_screen.dart';
import 'package:mocktail/mocktail.dart';
// import 'package:lyft_mate/screens/offer_ride/offer_ride_screen.dart';
import 'package:lyft_mate/screens/offer_ride/bloc/offer_ride_bloc.dart';

import '../mock.dart';
import '../widget/offer_ride_screen_test.dart';

class MockOfferRideBloc extends Mock implements OfferRideBloc {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockUser extends Mock implements User {}
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}

void main() {


  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
    // registerFallbackValue(FakeOfferRideEvent());
  });

  group('OfferRideScreen Integration Test', () {
    late MockOfferRideBloc offerRideBloc;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;

    setUp(() {
      offerRideBloc = MockOfferRideBloc();
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();

      // Setup fallback values
      registerFallbackValue(OfferRideInitial());
      registerFallbackValue(OfferRidePickupNavigateMapEvent());

      when(() => mockAuth.currentUser).thenReturn(MockUser());

      // Setup Firestore mock to return a QuerySnapshot
      var mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();
      when(() => mockQueryDocumentSnapshot.data()).thenReturn({
        'make': 'Toyota',
        'model': 'Camry',
        'licensePlate': 'ABC123',
      });

      var mockQuerySnapshot = MockQuerySnapshot();
      when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
      when(() => mockFirestore.collection(any()).doc(any()).collection(any()).get())
          .thenAnswer((_) async => mockQuerySnapshot);
    });

    // Widget createWidgetUnderTest() {
    //   return MaterialApp(
    //     home: BlocProvider<OfferRideBloc>(
    //       create: (context) => offerRideBloc,
    //       child: OfferRideScreen(homeBloc: MockHomeBloc()),  // Assuming you have a HomeBloc
    //     ),
    //   );
    // }

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<OfferRideBloc>(
          create: (context) => offerRideBloc,
          child: Scaffold(  // Ensure a Scaffold is used here
            body: OfferRideScreen(homeBloc: MockHomeBloc()),  // Assuming you have a HomeBloc
          ),
        ),
      );
    }

    testWidgets('Should navigate when all fields are filled and proceed is tapped', (WidgetTester tester) async {
      // Arrange
      when(() => offerRideBloc.state).thenReturn(OfferRideInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(find.byType(TextField).at(0), '123 Main St'); // Pickup Location
      await tester.enterText(find.byType(TextField).at(1), '456 Elm St');  // Drop off Location
      await tester.enterText(find.byType(TextField).at(2), '01/01/2024');  // Date
      await tester.enterText(find.byType(TextField).at(3), '12:00 PM');    // Time
      await tester.enterText(find.byType(TextField).at(4), 'Toyota Camry - ABC123'); // Vehicle
      await tester.enterText(find.byType(TextField).at(5), '3');           // Seats
      await tester.tap(find.text('Proceed'));
      await tester.pump();

      // Assert
      verify(() => offerRideBloc.add(any())).called(1);
    });
  });
}