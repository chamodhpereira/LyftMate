import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:lyft_mate/models/message.dart';

import '../../services/chat/chat_service.dart';

class DashChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;

  const DashChatPage(
      {super.key,
      required this.receiverUserEmail,
      required this.receiverUserID});

  @override
  State<DashChatPage> createState() => _DashChatPageState();
}

class _DashChatPageState extends State<DashChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  ChatUser? currentUser, otherUser;
  String receiverName = "";
  String? receiverImage;

  // void sendMessage() async {
  //   if (_messageController.text.isNotEmpty) {
  //     await _chatService.sendMessage(
  //         widget.receiverUserID, _messageController.text);
  //     //clear controller after sending
  //     _messageController.clear();
  //   }
  // }

  // // Fetch the receiver's name and profile image from Firestore
  // Future<void> _getReceiverDetails() async {
  //   final receiverDoc = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(widget.receiverUserID)
  //       .get();
  //
  //   setState(() {
  //     final firstName = receiverDoc['firstName'] ?? '';
  //     final lastName = receiverDoc['lastName'] ?? '';
  //     receiverName = '$firstName $lastName';
  //     debugPrint("THIS IS RECIEVER NAME: $receiverName");
  //     receiverImage = receiverDoc['profileImageUrl'] ?? null;
  //     otherUser = ChatUser(id: widget.receiverUserID, profileImage: receiverImage);
  //   });
  // }

  // Fetch the receiver's name and profile image from Firestore
  Future<void> _getReceiverDetails() async {
    final receiverDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.receiverUserID)
        .get();

    debugPrint("reciever detailssss called");

    // Safely access fields that might not exist
    setState(() {
      final data = receiverDoc.data();
      final firstName = data != null && data.containsKey('firstName') ? data['firstName'] : 'Unknown';
      final lastName = data != null && data.containsKey('lastName') ? data['lastName'] : 'User';
      receiverName = '$firstName $lastName';

      // Handle missing or empty profile image URL
      if (data != null && data.containsKey('profileImageUrl') && data['profileImageUrl'] != null) {
        receiverImage = data['profileImageUrl'];
        debugPrint("REciever imageeeeeeeeeeeee- $receiverImage");
      } else {
        receiverImage = null; // or provide a default image URL here
      }

      otherUser = ChatUser(id: widget.receiverUserID, profileImage: receiverImage);
    });
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    await _chatService.sendMessage(widget.receiverUserID, chatMessage.text);
    //clear controller after sending
    // _messageController.clear();
  }

  @override
  void initState() {
    User? user = _firebaseAuth.currentUser;
    currentUser = ChatUser(id: user!.uid);
    // otherUser = ChatUser(
    //   id: widget.receiverUserID,
    //   // profileImage: getProfilepicture and show here to show before chat bubble
    // );
    _getReceiverDetails(); // Retrieve receiver details for the app bar
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(widget.receiverUserEmail),
        title: Row(
          children: [
            // Circular avatar with the user's profile picture
            CircleAvatar(
              radius: 18,
              backgroundImage: receiverImage != null
                  ? NetworkImage(receiverImage!)
                  : null,
              child: receiverImage == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 8), // Space between avatar and name
            // Display the username in the app bar
            Text(receiverName),
          ],
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
        leadingWidth: 50.0,
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(
          widget.receiverUserID, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        QuerySnapshot? querySnapshot = snapshot.data;
        if (querySnapshot == null || querySnapshot.docs.isEmpty) {
          return DashChat(
            messageOptions: const MessageOptions(showOtherUsersAvatar: true, showTime: true),
            inputOptions: InputOptions(
              alwaysShowSend: true,
              trailing: [_mediaMessageButton()],
            ),
            currentUser: currentUser!,
            onSend: _sendMessage,
            messages: [],
          );
        }

        List<ChatMessage> messages = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String senderId = data["senderId"];

          // Use the correct user object for the sender
          ChatUser user = senderId == currentUser!.id
              ? currentUser!
              : ChatUser(id: senderId, profileImage: receiverImage);

          return ChatMessage(
            user: user,
            createdAt: (data['timestamp'] as Timestamp).toDate().toLocal(),
            text: data['message'] ?? '',
          );
        }).toList();

        messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return DashChat(
          messageOptions: const MessageOptions(showOtherUsersAvatar: true, showTime: true),
          inputOptions: InputOptions(
            alwaysShowSend: true,
            trailing: [_mediaMessageButton()],
          ),
          currentUser: currentUser!,
          onSend: _sendMessage,
          messages: messages,
        );
      },
    );
  }


  Widget _mediaMessageButton() {
    return IconButton(onPressed: () {}, icon: Icon(
      Icons.image,
      color: Theme.of(context).colorScheme.primary,
    ));
  }
}
