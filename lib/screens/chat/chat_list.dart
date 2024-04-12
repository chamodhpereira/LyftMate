// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:lyft_mate/services/chat/chat_service.dart';
// import 'package:lyft_mate/models/message.dart'; // Assuming you have a Message model
//
// import 'chatpage.dart';
//
// class InteractedUsersPage extends StatefulWidget {
//   @override
//   _InteractedUsersPageState createState() => _InteractedUsersPageState();
// }
//
// class _InteractedUsersPageState extends State<InteractedUsersPage> {
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//   final ChatService _chatService = ChatService();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Interacted Users'),
//       ),
//       body: Center(
//         child: FutureBuilder<List<String>>(
//           future: _chatService.getUsersInteractedWith(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return CircularProgressIndicator();
//             } else if (snapshot.hasError) {
//               return Text('Error: ${snapshot.error}');
//             } else {
//               List<String> interactedUsers = snapshot.data ?? [];
//               return ListView.builder(
//                 itemCount: interactedUsers.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(interactedUsers[index]),
//                     onTap: () {
//                       // Assuming you have another screen to display messages
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => MyChatPage(
//                             userId: _firebaseAuth.currentUser!.uid,
//                             otherUserId: interactedUsers[index],
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
//
// class MyChatPage extends StatelessWidget {
//   final String userId;
//   final String otherUserId;
//
//   final ChatService _chatService = ChatService();
//
//   MyChatPage({Key? key, required this.userId, required this.otherUserId}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat with $otherUserId'),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _chatService.getMessages(userId, otherUserId),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return CircularProgressIndicator();
//           } else if (snapshot.hasError) {
//             return Text('Error: ${snapshot.error}');
//           } else {
//             List<Message> messages = (snapshot.data?.docs ?? []).map<Message>((doc) {
//               final data = doc.data() as Map<String, dynamic>; // Explicit cast to Map<String, dynamic>
//               return Message(
//                 senderId: data['senderId'],
//                 senderEmail: data['senderEmail'],
//                 receiverId: data['receiverId'],
//                 message: data['message'],
//                 timestamp: data['timestamp'],
//               );
//             }).toList();
//             return ListView.builder(
//               itemCount: messages.length,
//               itemBuilder: (context, index) {
//                 Message message = messages[index];
//                 return ListTile(
//                   title: Text(message.message),
//                   subtitle: Text(message.senderEmail),
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }
//
