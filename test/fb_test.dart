// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:lyft_mate/services/authentication_service.dart';
// import 'package:mockito/mockito.dart';
//
//
// // Mock FirebaseAuth instance
// class MockFirebaseAuth extends Mock implements FirebaseAuth {}
//
//
// void main() {
//   group('AuthenticationService', () {
//     late AuthenticationService authService;
//     late MockFirebaseAuth mockFirebaseAuth;
//
//     setUp(() {
//       mockFirebaseAuth = MockFirebaseAuth();
//       // Assume AuthenticationService takes a FirebaseAuth instance in its constructor
//       authService = AuthenticationService(firebaseAuth: mockFirebaseAuth);
//     });
//
//     test('signUpUser returns a UserModel if signup successful', () async {
//       // Setup createUserWithEmailAndPassword to return a FakeUserCredential
//       when(mockFirebaseAuth.createUserWithEmailAndPassword(
//           email: anyNamed('email').toString(),
//           password: anyNamed('password').toString()
//       )).thenAnswer((_) async => FakeUserCredential());
//
//       final result = await authService.signUpUser('test@example.com', 'password');
//
//       expect(result, isA<UserModel>());
//       expect(result?.email, equals('fake@example.com'));
//     });
//
//     test('signUpUser returns null if signup fails', () async {
//       when(mockFirebaseAuth.createUserWithEmailAndPassword(
//           email: anyNamed('email'),
//           password: anyNamed('password')
//       )).thenThrow(FirebaseAuthException(code: 'auth/error', message: 'Error message'));
//
//       final result = await authService.signUpUser('test@example.com', 'password');
//
//       expect(result, isNull);
//     });
//   });
// }
//
// // void main() {
// //   group('AuthenticationService', () {
// //     late AuthenticationService authService;
// //     late MockFirebaseAuth mockFirebaseAuth;
// //
// //     setUp(() {
// //       mockFirebaseAuth = MockFirebaseAuth();
// //       authService = AuthenticationService(mockFirebaseAuth);
// //       // authService.auth = mockFirebaseAuth;
// //     });
// //
// //     test('signUpUser returns a UserModel if signup successful', () async {
// //       when(mockFirebaseAuth.createUserWithEmailAndPassword(
// //           email: anyNamed('email'), password: anyNamed('password')))
// //           .thenAnswer((_) async => FakeUserCredential());
// //
// //       final result = await authService.signUpUser('test@example.com', 'password');
// //
// //       expect(result, isA<UserModel>());
// //     });
// //
// //     test('signUpUser returns null if signup fails', () async {
// //       when(mockFirebaseAuth.createUserWithEmailAndPassword(
// //           email: anyNamed('email'), password: anyNamed('password')))
// //           .thenThrow(FirebaseAuthException(code: 'error'));
// //
// //       final result = await authService.signUpUser('test@example.com', 'password');
// //
// //       expect(result, null);
// //     });
// //   });
// // }
//
// // Fake implementation of UserCredential for mocking
// class FakeUserCredential extends Fake implements UserCredential {
//   @override
//   User get user => FakeUser();
// }
//
// // Fake implementation of User for mocking
// class FakeUser extends Fake implements User {
//   @override
//   String get uid => 'fakeUid';
//
//   @override
//   String get email => 'fake@example.com';
//
//   @override
//   String? get displayName => 'Fake User';
// }