import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lyft_mate/screens/offer_ride/ui/offer_ride_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lyft_mate/screens/home/bloc/home_bloc.dart';
import 'package:lyft_mate/screens/offer_ride/bloc/offer_ride_bloc.dart';

import '../mock.dart';

class MockOfferRideBloc extends Mock implements OfferRideBloc {}
class MockHomeBloc extends Mock implements HomeBloc {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeOfferRideEvent extends Fake implements OfferRideEvent {}


void main() {
  late MockOfferRideBloc mockOfferRideBloc;
  late MockHomeBloc mockHomeBloc;
  late MockNavigatorObserver mockNavigatorObserver;

  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
    registerFallbackValue(FakeOfferRideEvent());
  });

  setUp(() {
    mockOfferRideBloc = MockOfferRideBloc();
    mockHomeBloc = MockHomeBloc();
    mockNavigatorObserver = MockNavigatorObserver();

    // Stub the state streams to avoid null errors in tests.
    when(() => mockOfferRideBloc.stream).thenAnswer((_) =>
        Stream.fromIterable([OfferRideInitial()]));
    when(() => mockOfferRideBloc.state).thenReturn(OfferRideInitial());

    // Allow any event to be added to the mockOfferRideBloc without a real implementation
    when(() => mockOfferRideBloc.add(any())).thenReturn(null); // Add this line
  });

  Widget createTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold( // Added Scaffold here to provide Material ancestor
        body: MultiBlocProvider(
          providers: [
            BlocProvider<OfferRideBloc>(create: (context) => mockOfferRideBloc),
            BlocProvider<HomeBloc>(create: (context) => mockHomeBloc),
          ],
          child: child,
        ),
      ),
      navigatorObservers: [mockNavigatorObserver],
    );
  }

  testWidgets('OfferRideScreen initializes and shows required fields', (
      WidgetTester tester) async {
    await tester.pumpWidget(
        createTestableWidget(OfferRideScreen(homeBloc: mockHomeBloc)));

    // Verify all text fields are present
    expect(find.byType(TextField), findsNWidgets(6));
    expect(find.text('Pickup Location'), findsOneWidget);
    expect(find.text('Drop off Location'), findsOneWidget);
    expect(find.text('Select Date'), findsOneWidget);
    expect(find.text('Select Time'), findsOneWidget);
    expect(find.text('Select Vehicle'), findsOneWidget);
    expect(find.text('Select Seats'), findsOneWidget);
    expect(find.text('Proceed'), findsOneWidget);

    // Tap on the 'Pickup Location' TextField to trigger navigation
    await tester.tap(find.widgetWithText(TextField, 'Pickup Location'));
    await tester.pumpAndSettle();

    // Verify that the OfferRideBloc emits the navigation event
    verify(() =>
        mockOfferRideBloc.add(
            any(that: isA<OfferRidePickupNavigateMapEvent>()))).called(1);
  });
}


// void main() {
//   late MockOfferRideBloc mockOfferRideBloc;
//   late MockHomeBloc mockHomeBloc;
//   late MockNavigatorObserver mockNavigatorObserver;
//
//   setupFirebaseAuthMocks();
//
//   setUpAll(() async {
//     await Firebase.initializeApp();
//     registerFallbackValue(FakeOfferRideEvent());
//   });
//
//   setUp(() {
//     mockOfferRideBloc = MockOfferRideBloc();
//     mockHomeBloc = MockHomeBloc();
//     mockNavigatorObserver = MockNavigatorObserver();
//     // Stub the state streams to avoid null errors in tests.
//     when(() => mockOfferRideBloc.stream).thenAnswer((_) => Stream.fromIterable([OfferRideInitial()]));
//     when(() => mockOfferRideBloc.state).thenReturn(OfferRideInitial());
//   });
//
//   // Widget createTestableWidget(Widget child) {
//   //   return MaterialApp(
//   //     home: MultiBlocProvider(
//   //       providers: [
//   //         BlocProvider<OfferRideBloc>(create: (context) => mockOfferRideBloc),
//   //         BlocProvider<HomeBloc>(create: (context) => mockHomeBloc),
//   //       ],
//   //       child: child,
//   //     ),
//   //     navigatorObservers: [mockNavigatorObserver],
//   //   );
//   // }
//   //
//   // testWidgets('OfferRideScreen initializes and shows required fields', (WidgetTester tester) async {
//   //   await tester.pumpWidget(createTestableWidget(OfferRideScreen(homeBloc: mockHomeBloc)));
//   //
//   //   // Verify all text fields are present
//   //   expect(find.byType(TextField), findsNWidgets(4));
//   //   expect(find.text('Pickup Location'), findsOneWidget);
//   //   expect(find.text('Drop off Location'), findsOneWidget);
//   //   expect(find.text('Select Date'), findsOneWidget);
//   //   expect(find.text('Select Time'), findsOneWidget);
//   //   expect(find.text('Select Vehicle'), findsOneWidget);
//   //   expect(find.text('Select Seats'), findsOneWidget);
//   //   expect(find.text('Proceed'), findsOneWidget);
//   //
//   //   // Tap on the 'Pickup Location' TextField to trigger navigation
//   //   await tester.tap(find.widgetWithText(TextField, 'Pickup Location'));
//   //   await tester.pumpAndSettle();
//   //
//   //   // Verify that the OfferRideBloc emits the navigation event
//   //   verify(() => mockOfferRideBloc.add(any(that: isA<OfferRidePickupNavigateMapEvent>()))).called(1);
//   //
//   //   // Similar tests can be done for other interaction like tapping on 'Drop off Location', 'Select Date', 'Select Time', etc.
//   // });
//
//   Widget createTestableWidget(Widget child) {
//     return MaterialApp(
//       home: Scaffold( // Added Scaffold here to provide Material ancestor
//         body: MultiBlocProvider(
//           providers: [
//             BlocProvider<OfferRideBloc>(create: (context) => mockOfferRideBloc),
//             BlocProvider<HomeBloc>(create: (context) => mockHomeBloc),
//           ],
//           child: child,
//         ),
//       ),
//       navigatorObservers: [mockNavigatorObserver],
//     );
//   }
//
//   testWidgets('OfferRideScreen initializes and shows required fields', (WidgetTester tester) async {
//     await tester.pumpWidget(createTestableWidget(OfferRideScreen(homeBloc: mockHomeBloc)));
//
//     // Verify all text fields are present
//     expect(find.byType(TextField), findsNWidgets(6));
//     expect(find.text('Pickup Location'), findsOneWidget);
//     expect(find.text('Drop off Location'), findsOneWidget);
//     expect(find.text('Select Date'), findsOneWidget);
//     expect(find.text('Select Time'), findsOneWidget);
//     expect(find.text('Select Vehicle'), findsOneWidget);
//     expect(find.text('Select Seats'), findsOneWidget);
//     expect(find.text('Proceed'), findsOneWidget);
//
//
//
//     // // Tap on the 'Pickup Location' TextField to trigger navigation
//     // await tester.tap(find.widgetWithText(TextField, 'Pickup Location'));
//     // await tester.pumpAndSettle();
//     //
//     // // Verify that the OfferRideBloc emits the navigation event
//     // verify(() => mockOfferRideBloc.add(any(that: isA<OfferRidePickupNavigateMapEvent>()))).called(1);
//
//     // Similar tests can be done for other interactions like tapping on 'Drop off Location', 'Select Date', 'Select Time', etc.
//   });
//
//
//   testWidgets('OfferRideScreen should trigger navigation event on tap', (WidgetTester tester) async {
//     await tester.pumpWidget(createTestableWidget(OfferRideScreen(homeBloc: mockHomeBloc)));
//     await tester.tap(find.widgetWithText(TextField, 'Pickup Location'));  // Make sure this matches your actual widget text
//     await tester.pumpAndSettle(); // Ensure all animations are completed
//     verify(() => mockOfferRideBloc.add(any(that: isA<OfferRidePickupNavigateMapEvent>()))).called(1);
//   });
// }




// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:bloc_test/bloc_test.dart';
// import 'package:lyft_mate/screens/offer_ride/ui/offer_ride_screen.dart';
// import 'package:mocktail/mocktail.dart';
// // import 'package:lyft_mate/screens/offer_ride/offer_ride_screen.dart';
// import 'package:lyft_mate/screens/offer_ride/bloc/offer_ride_bloc.dart';
// import 'package:lyft_mate/screens/home/bloc/home_bloc.dart';
//
// import '../mock.dart';
//
// // Mock classes
// class MockOfferRideBloc extends MockBloc<OfferRideEvent, OfferRideState> implements OfferRideBloc {}
// class MockHomeBloc extends Mock implements HomeBloc {}
// class FakeOfferRideEvent extends Fake implements OfferRideEvent {}
//
//
// void main() {
//   setupFirebaseAuthMocks();
//
//   setUpAll(() async {
//     await Firebase.initializeApp();
//     registerFallbackValue(FakeOfferRideEvent());
//   });
//
//
//   group('OfferRideScreen Tests', () {
//     late MockOfferRideBloc offerRideBloc;
//     late MockHomeBloc homeBloc;
//
//     setUp(() {
//       offerRideBloc = MockOfferRideBloc();
//       homeBloc = MockHomeBloc();
//
//       // Setup Mock Blocs
//       when(() => offerRideBloc.state).thenReturn(OfferRideInitial());
//     });
//
//     tearDown(() {
//       offerRideBloc.close();
//       homeBloc.close();
//     });
//
//     testWidgets('OfferRideScreen renders correctly with initial UI', (WidgetTester tester) async {
//       await tester.pumpWidget(
//         MaterialApp(
//           home: MultiBlocProvider(
//             providers: [
//               BlocProvider<OfferRideBloc>(
//                 create: (_) => offerRideBloc,
//               ),
//               BlocProvider<HomeBloc>(
//                 create: (_) => homeBloc,
//               ),
//             ],
//             // child: OfferRideScreen(homeBloc: homeBloc),
//             child: Scaffold( // Ensuring Material widget is present
//               body: OfferRideScreen(homeBloc: homeBloc),
//             ),
//           ),
//         ),
//       );
//
//       expect(find.text('Pickup Location'), findsOneWidget);
//       expect(find.text('Drop off Location'), findsOneWidget);
//       expect(find.text('Select Date'), findsOneWidget);
//       expect(find.text('Select Time'), findsOneWidget);
//       expect(find.text('Select Vehicle'), findsOneWidget);
//       expect(find.text('Select Seats'), findsOneWidget);
//     });
//
//     testWidgets('Tap on Pickup Location triggers navigation event', (WidgetTester tester) async {
//       when(() => offerRideBloc.add(any(that: isA<OfferRidePickupNavigateMapEvent>())))
//           .thenReturn(() {});
//
//       await tester.pumpWidget(
//         MaterialApp(
//           home: BlocProvider<OfferRideBloc>(
//             create: (_) => offerRideBloc,
//             // child: OfferRideScreen(homeBloc: homeBloc),
//             child: Scaffold( // Ensuring Material widget is present
//               body: OfferRideScreen(homeBloc: homeBloc),
//             ),
//           ),
//         ),
//       );
//
//       // Simulate tap on the Pickup Location text field
//       await tester.tap(find.widgetWithText(TextField, 'Pickup Location'));
//       await tester.pumpAndSettle();
//
//       // Verify that the correct event is added to the bloc
//       // verify(() => offerRideBloc.add(isA<OfferRidePickupNavigateMapEvent>())).called(1);
//       verify(() => offerRideBloc.add(any(that: isA<OfferRidePickupNavigateMapEvent>()))).called(1);
//
//     });
//   });
// }



// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:bloc_test/bloc_test.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:lyft_mate/screens/offer_ride/offer_ride_screen.dart';
// import 'package:lyft_mate/screens/offer_ride/bloc/offer_ride_bloc.dart';
//
// void main() {
//   group('OfferRideScreen Tests', () {
//     late OfferRideBloc offerRideBloc;
//
//     setUp(() {
//       offerRideBloc = MockOfferRideBloc();
//     });
//
//     tearDown(() {
//       offerRideBloc.close();
//     });
//
//     blocTest<OfferRideBloc, OfferRideState>(
//       'OfferRideBloc should emit [OfferRideNavToPickupMapPageActionState] when OfferRidePickupNavigateMapEvent is added',
//       build: () => offerRideBloc,
//       act: (bloc) => bloc.add(OfferRidePickupNavigateMapEvent()),
//       expect: () => [isA<OfferRideNavToPickupMapPageActionState>()],
//     );
//
//     testWidgets('OfferRideScreen renders correctly with initial UI', (WidgetTester tester) async {
//       await tester.pumpWidget(
//         MaterialApp(
//           home: BlocProvider<OfferRideBloc>(
//             create: (_) => offerRideBloc,
//             child: OfferRideScreen(homeBloc: MockHomeBloc()),
//           ),
//         ),
//       );
//
//       expect(find.text('Pickup Location'), findsOneWidget);
//       expect(find.text('Drop off Location'), findsOneWidget);
//       expect(find.text('Select Date'), findsOneWidget);
//       expect(find.text('Select Time'), findsOneWidget);
//       expect(find.text('Select Vehicle'), findsOneWidget);
//       expect(find.text('Select Seats'), findsOneWidget);
//     });
//
//     testWidgets('Tap on Pickup Location triggers navigation event', (WidgetTester tester) async {
//       await tester.pumpWidget(
//         MaterialApp(
//           home: BlocProvider<OfferRideBloc>(
//             create: (_) => offerRideBloc,
//             child: OfferRideScreen(homeBloc: MockHomeBloc()),
//           ),
//         ),
//       );
//
//       // Simulate tap on the Pickup Location text field
//       await tester.tap(find.byTooltip('Pickup Location'));
//       await tester.pumpAndSettle();
//
//       // Verify that the appropriate event is added to the bloc
//       verify(() => offerRideBloc.add(OfferRidePickupNavigateMapEvent())).called(1);
//     });
//   });
// }