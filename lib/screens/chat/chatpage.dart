import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lyft_mate/services/chat/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  const ChatPage(
      {super.key,
      required this.receiverUserEmail,
      required this.receiverUserID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverUserID, _messageController.text);
      //clear controller after sending
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverUserEmail),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput()
        ],
      ),
    );
  }

  //build message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
          widget.receiverUserID, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if(snapshot.hasError){
          return Text("Error${snapshot.error}");
        }
        
        if(snapshot.connectionState == ConnectionState.waiting) {
          return Text("loading.....");

        }

        List<Widget> messageWidgets = snapshot.data!.docs
            .map<Widget>((document) => _buildMessageItem(document))
            .toList();

        return ListView(
          children: messageWidgets,
        );
      },
    );
  }

// build message item
//   Widget _buildMessageItem(DocumentSnapshot document) {
//     Map<String, dynamic> data = document.data() as Map<String, dynamic>;
//
//     //align the messages to the right if the sender is the current user, otherwise left
//     var alignment = (data["senderId"] == _firebaseAuth.currentUser!uid) ? Alignment.centerRight : Alignment.centerLeft;
//
//     return Container(
//       alignment: alignment,
//       child: Column(
//         children: [
//           Text(data['senderEmail']),
//           Text(data['message']),
//         ],
//       )
//     );
//
//   }
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

    if (data != null &&
        data.containsKey('senderId') &&
        _firebaseAuth.currentUser != null) {
      var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
          ? Alignment.centerRight
          : Alignment.centerLeft;

      return Container(
        alignment: alignment,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['senderEmail'] ??
                ''), // You might want to add a default value if 'senderEmail' is null
            Text(data['message'] ??
                ''), // You might want to add a default value if 'message' is null
          ],
        ),
      );
    }

    // Return a default widget or handle the case where data, 'senderId', or currentUser is null
    return SizedBox();
  }

//build message input

  Widget _buildMessageInput() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _messageController,
            obscureText: false,
          ),
        ),
        IconButton(
            onPressed: sendMessage,
            icon: Icon(
              Icons.arrow_upward,
              size: 40,
            ))
      ],
    );
  }
}
