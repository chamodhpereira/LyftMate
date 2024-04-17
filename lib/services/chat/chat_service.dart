import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lyft_mate/models/message.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String receiverId, String message) async {
    try {
      // Get current user info
      final String currentUserId = _firebaseAuth.currentUser!.uid;
      final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
      final Timestamp timestamp = Timestamp.now();

      // Construct chat room id from current user id and receiver id (sorted to ensure uniqueness)
      List<String> ids = [currentUserId, receiverId];
      ids.sort();
      String chatRoomId = ids.join("_"); // Combine ids into single string to use as chat room id

      // Check if the chat room already exists
      bool chatRoomExists = await _firestore.collection('chat_rooms').doc(chatRoomId).get().then((doc) => doc.exists);

      if (!chatRoomExists) {
        // Create the chat room if it doesn't exist
        await _firestore.collection('chat_rooms').doc(chatRoomId).set({
          'users': [currentUserId, receiverId], // Store user IDs in the chat room document
        });
      }

      // Create a new message
      Message newMessage = Message(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        receiverId: receiverId,
        message: message,
        timestamp: timestamp,
      );

      // Add new message to the chat room
      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMessage.toMap());

      print('Message sent successfully!');
    } catch (e) {
      print('Error sending message: $e');
      // Handle any errors that occur during message sending
    }
  }


  // below is working   --------

  // Future<void> sendMessage(String receiverId, String message) async {
  //   try {
  //     // Get current user info
  //     final String currentUserId = _firebaseAuth.currentUser!.uid;
  //     final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
  //     final Timestamp timestamp = Timestamp.now();
  //
  //     // Create a new message
  //     Message newMessage = Message(
  //       senderId: currentUserId,
  //       senderEmail: currentUserEmail,
  //       receiverId: receiverId,
  //       message: message,
  //       timestamp: timestamp,
  //     );
  //
  //     // Construct chat room id from current user id and receiver id (sorted to ensure uniqueness)
  //     List<String> ids = [currentUserId, receiverId];
  //     ids.sort();
  //     String chatRoomId = ids.join("_"); // Combine ids into single string to use as chat room id
  //
  //     // Add new message to db
  //     await _firestore
  //         .collection('chat_rooms')
  //         .doc(chatRoomId)
  //         .collection('messages')
  //         .add(newMessage.toMap());
  //
  //     print('Message sent successfully!');
  //   } catch (e) {
  //     print('Error sending message: $e');
  //     // Handle any errors that occur during message sending
  //   }
  // }


//get messgaes --------- working everything commenteed for dashcaht checking

  // Future<Stream<QuerySnapshot<Object?>>> getMessages(String userId, String otherUserId) async {
  //   // Construct chat room id from user ids (sorted to ensure it matches the id used when sending messages)
  //   List<String> ids = [userId, otherUserId];
  //   ids.sort();
  //   String chatRoomId = ids.join("_");
  //
  //   print("Checking chat room: $chatRoomId"); // Log the chat room ID being checked
  //
  //   // Check if the chat room exists
  //   QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('chat_rooms').get();
  //   if (querySnapshot.docs.isNotEmpty) {
  //     // Chat rooms exist
  //     print("Chat rooms found: ${querySnapshot.docs.length}");
  //     querySnapshot.docs.forEach((doc) {
  //       print("Chat room ID: ${doc.id}, Data: ${doc.data()}");
  //     });
  //   } else {
  //     // No chat rooms found
  //     print("No chat rooms found");
  //   }
  //
  //   // Return a stream of snapshots from the Firestore query
  //   return FirebaseFirestore.instance
  //       .collection('chat_rooms')
  //       .doc(chatRoomId)
  //       .collection('messages')
  //       .orderBy('timestamp', descending: false)
  //       .snapshots();
  // }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    // Construct chat room id from user ids (sorted to ensure it matches the id used when sending messages)
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    print("Checking chat room: $chatRoomId"); // Log the chat room ID being checked

    // Return a stream of snapshots from the Firestore query
    return FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }



  // Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
  //   // Construct chat room id from user ids (sorted to ensure it matches the id used when sending messages)
  //   List<String> ids = [userId, otherUserId];
  //   ids.sort();
  //   String chatRoomId = ids.join("_");
  //
  //   // Return a stream of snapshots from the Firestore query
  //   return _firestore
  //       .collection('chat_rooms')
  //       .doc(chatRoomId)
  //       .collection('messages')
  //       .orderBy('timestamp', descending: false)
  //       .snapshots();
  // }

  // Get users that the logged-in user has sent messages to
  // Future<List<String>> getUsersWithMessages() async {
  //   final String currentUserId = _firebaseAuth.currentUser!.uid;
  //
  //   // Query the Firestore collection to get receivers of messages sent by the logged-in user
  //   QuerySnapshot querySnapshot = await _firestore
  //       .collection('chat_rooms').get();
  //       // .where('senderId', isEqualTo: currentUserId)
  //       // .get();
  //
  //   if(querySnapshot.docs.isEmpty) {
  //     print("botjnggggg");
  //   }
  //
  //   // Extract receiver IDs
  //   List<String> receiverIds = [];
  //   querySnapshot.docs.forEach((doc) {
  //     receiverIds.add(doc['receiverId']);
  //   });
  //
  //   return receiverIds;
  // }\

  // Future<List<String>> getUsersWithMessages() async {
  //   final String currentUserId = _firebaseAuth.currentUser!.uid;
  //
  //   // Query the Firestore collection to get receivers of messages sent by the logged-in user
  //   QuerySnapshot querySnapshot = await _firestore
  //       .collection('chat_rooms')
  //       .where('chat', isEqualTo: currentUserId)
  //       .get();
  //
  //   if (querySnapshot.docs.isEmpty) {
  //     print("No messages found");
  //   }
  //
  //   // Extract receiver IDs
  //   List<String> receiverIds = [];
  //   querySnapshot.docs.forEach((doc) {
  //     receiverIds.add(doc['receiverId']);
  //   });
  //
  //   return receiverIds;
  // }


// worrrrrrrrrrrrrkigggggggggggg
  //
  // Future<List<String>> getUsersWithMessages() async {
  //
  //   final String userId = _firebaseAuth.currentUser!.uid;
  //
  //   List<String> usersWithMessages = [];
  //
  //   // Query the chat_rooms collection
  //   QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //       .collection('chat_rooms')
  //       .get();
  //
  //   print("Total chat rooms found: ${querySnapshot.docs.length}");
  //
  //   // Iterate through chat room documents
  //   querySnapshot.docs.forEach((doc) {
  //     print("Checking chat room: ${doc.id}");
  //
  //     // Parse chat room ID to get user IDs
  //     List<String> ids = doc.id.split("_");
  //
  //     print("User IDs in chat room: $ids");
  //
  //     // Determine the other user ID
  //     String otherUserId = ids.firstWhere((id) => id != userId, orElse: () => '');
  //     if (otherUserId != null && !usersWithMessages.contains(otherUserId)) {
  //       print("User with ID $otherUserId has sent messages to the logged-in user.");
  //       usersWithMessages.add(otherUserId);
  //     }
  //   });
  //
  //   return usersWithMessages;
  // }

  Future<List<String>> getUsersWithMessages() async {
    final String userId = _firebaseAuth.currentUser!.uid;
    List<String> usersWithMessages = [];

    // Query the chat_rooms collection
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('chat_rooms')
        .get();

    print("Total chat rooms found: ${querySnapshot.docs.length}");

    // Iterate through chat room documents
    querySnapshot.docs.forEach((doc) {
      print("Checking chat room: ${doc.id}");

      // Parse chat room ID to get user IDs
      List<String> ids = doc.id.split("_");

      print("User IDs in chat room: $ids");

      // Check if the logged-in user's ID is part of the chat room ID
      if (ids.contains(userId)) {
        print("Logged-in user is a part of this chat room.");

        // Determine the other user ID
        String otherUserId = ids.firstWhere((id) => id != userId);
        if (otherUserId != null && !usersWithMessages.contains(otherUserId)) {
          print("User with ID $otherUserId has sent messages to the logged-in user.");
          usersWithMessages.add(otherUserId);
        }
      } else {
        print("Logged-in user is not a part of this chat room.");
      }
    });

    return usersWithMessages;
  }


}



