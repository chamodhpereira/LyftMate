// import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
// import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:lyft_mate/services/chat/chat_service.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'mock.dart';
//
// void main() async {
//   // Initialize Firebase for testing
//   setupFirebaseAuthMocks();
//   setUpAll(() async {
//     await Firebase.initializeApp();
//   });
//
//   group('ChatService with Mock Authentication', () {
//     late ChatService chatService;
//     late FakeFirebaseFirestore fakeFirestore;
//     late MockFirebaseAuth mockAuth;
//     late MockUser mockUser;
//
//     const testUserId = 'test_user_id';
//     const testUserEmail = 'test_user@example.com';
//     const receiverId = 'receiver_user_id';
//     const testMessage = 'Hello there!';
//
//     setUp(() {
//       // Initialize fake Firestore
//       fakeFirestore = FakeFirebaseFirestore();
//
//       // Initialize MockUser with required attributes
//       mockUser = MockUser(
//         uid: testUserId,
//         email: testUserEmail,
//       );
//
//       // Pass the mock user to MockFirebaseAuth
//       mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
//
//       // Print or assert current user
//       assert(mockAuth.currentUser != null, 'MockAuth current user should not be null');
//       print('MockAuth User: ${mockAuth.currentUser?.uid}');  // Check the user UID
//
//       // Create the ChatService and set mock dependencies
//       chatService = ChatService();
//       chatService.firebaseAuth = mockAuth;
//       chatService.firestore = fakeFirestore;
//     });
//
//     test('sendMessage should create a new chat room and send a message', () async {
//       await chatService.sendMessage(receiverId, testMessage);
//
//       final chatRoomId = [testUserId, receiverId]..sort();
//       final chatRoomDocId = chatRoomId.join('_');
//       final chatRoomDoc = await fakeFirestore.collection('chat_rooms').doc(chatRoomDocId).get();
//       expect(chatRoomDoc.exists, isTrue);
//
//       final messagesSnapshot = await fakeFirestore
//           .collection('chat_rooms')
//           .doc(chatRoomDocId)
//           .collection('messages')
//           .get();
//
//       expect(messagesSnapshot.docs.length, equals(1));
//     });
//   });
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lyft_mate/services/chat/chat_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'mock.dart';

void main() async {
  // Initialize Firebase for testing
  setupFirebaseAuthMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('ChatService with Mock Authentication', () {
    late ChatService chatService;
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;

    const testUserId = 'test_user_id';
    const testUserEmail = 'test_user@example.com';
    const receiverId = 'receiver_user_id';
    const receiverEmail = 'receiver_user@example.com';
    const testMessage = 'Hello there!';
    const testMessage2 = 'How are you doing?';

    setUp(() {
      // Initialize fake Firestore
      fakeFirestore = FakeFirebaseFirestore();

      // Initialize MockUser with required attributes
      mockUser = MockUser(
        uid: testUserId,
        email: testUserEmail,
      );

      // Pass the mock user to MockFirebaseAuth
      mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

      // Print or assert current user
      assert(mockAuth.currentUser != null, 'MockAuth current user should not be null');
      print('MockAuth User: ${mockAuth.currentUser?.uid}');  // Check the user UID

      // Create the ChatService and set mock dependencies
      chatService = ChatService();
      chatService.firebaseAuth = mockAuth;
      chatService.firestore = fakeFirestore;

      // Pre-populate with some messages
      final chatRoomId = [testUserId, receiverId]..sort();
      final chatRoomDocId = chatRoomId.join('_');
      fakeFirestore.collection('chat_rooms').doc(chatRoomDocId).set({
        'users': [testUserId, receiverId],
      });
      fakeFirestore
          .collection('chat_rooms')
          .doc(chatRoomDocId)
          .collection('messages')
          .add({
        'senderId': testUserId,
        'senderEmail': testUserEmail,
        'receiverId': receiverId,
        'message': testMessage,
        'timestamp': FieldValue.serverTimestamp(),
      });
      fakeFirestore
          .collection('chat_rooms')
          .doc(chatRoomDocId)
          .collection('messages')
          .add({
        'senderId': receiverId,
        'senderEmail': receiverEmail,
        'receiverId': testUserId,
        'message': testMessage2,
        'timestamp': FieldValue.serverTimestamp(),
      });


    });

    test('sendMessage should create a new chat room and send a message', () async {
      await chatService.sendMessage(receiverId, testMessage);

      final chatRoomId = [testUserId, receiverId]..sort();
      final chatRoomDocId = chatRoomId.join('_');
      final chatRoomDoc = await fakeFirestore.collection('chat_rooms').doc(chatRoomDocId).get();
      expect(chatRoomDoc.exists, isTrue);

      final messagesSnapshot = await fakeFirestore
          .collection('chat_rooms')
          .doc(chatRoomDocId)
          .collection('messages')
          .get();

      expect(messagesSnapshot.docs.length, equals(3));
    });

    test('getMessages should return a stream of messages', () async {
      final messagesStream = chatService.getMessages(testUserId, receiverId);
      final messagesSnapshot = await messagesStream.first;

      // Check the number of messages in the chat room
      expect(messagesSnapshot.docs.length, equals(2));

      // Verify message content
      final firstMessage = messagesSnapshot.docs[0].data() as Map<String, dynamic>;
      final secondMessage = messagesSnapshot.docs[1].data() as Map<String, dynamic>;
      expect(firstMessage['message'], equals(testMessage));
      expect(secondMessage['message'], equals(testMessage2));
    });

    // test('getUsersWithMessages should return a list of user IDs', () async {
    //   final usersList = await chatService.getUsersWithMessages();
    //
    //   // Check if the receiver's ID is returned, indicating that they've sent messages to the test user
    //   expect(usersList, contains(receiverId));
    // });


  });
}

