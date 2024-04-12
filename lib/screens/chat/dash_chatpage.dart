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

  // void sendMessage() async {
  //   if (_messageController.text.isNotEmpty) {
  //     await _chatService.sendMessage(
  //         widget.receiverUserID, _messageController.text);
  //     //clear controller after sending
  //     _messageController.clear();
  //   }
  // }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    await _chatService.sendMessage(widget.receiverUserID, chatMessage.text);
    //clear controller after sending
    // _messageController.clear();
  }

  @override
  void initState() {
    User? user = _firebaseAuth.currentUser;
    currentUser = ChatUser(id: user!.uid);
    otherUser = ChatUser(
      id: widget.receiverUserID,
      // profileImage: getProfilepicture and show here to show before chat bubble
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverUserEmail),
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
          return Text("Loading...");
        }
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        QuerySnapshot? querySnapshot = snapshot.data;
        if (querySnapshot == null || querySnapshot.docs.isEmpty) {
          return Center(
            child: Text("No messages yet."),
          );
        }

        // Print the data to the console
        querySnapshot.docs.forEach((doc) {
          print(doc.data());
        });

        List<ChatMessage> messages = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return ChatMessage(
            user: ChatUser(id: data["senderId"]),
            createdAt: (data['timestamp'] as Timestamp).toDate().toLocal(),
            text: data['message']?.toString() ?? '',
            // isMarkdown: data['isMarkdown']?.toString() == 'true',
            // medias: data['medias'] != null
            //     ? (data['medias'] as List<dynamic>)
            //     .map((dynamic media) =>
            //     ChatMedia.fromJson(media as Map<String, dynamic>))
            //     .toList()
            //     : <ChatMedia>[],
            // quickReplies: data['quickReplies'] != null
            //     ? (data['quickReplies'] as List<dynamic>)
            //     .map((dynamic quickReply) =>
            //     QuickReply.fromJson(quickReply as Map<String, dynamic>))
            //     .toList()
            //     : <QuickReply>[],
            // customProperties: data['customProperties'] as Map<String, dynamic>?,
            // mentions: data['mentions'] != null
            //     ? (data['mentions'] as List<dynamic>)
            //     .map((dynamic mention) =>
            //     Mention.fromJson(mention as Map<String, dynamic>))
            //     .toList()
            //     : <Mention>[],
            // status: MessageStatus.parse(data['status'].toString()),
            // replyTo: data['replyTo'] != null
            //     ? chatMessageFromJson(data['replyTo'] as Map<String, dynamic>)
            //     : null,
          );
        }).toList();
        messages.sort((a, b) {
          return b.createdAt.compareTo(a.createdAt);
        });

        return DashChat(
          messageOptions:
              const MessageOptions(showOtherUsersAvatar: true, showTime: true),
          inputOptions: InputOptions(
            alwaysShowSend: true,
            trailing: [
              _mediaMessageButton(),
            ],
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
