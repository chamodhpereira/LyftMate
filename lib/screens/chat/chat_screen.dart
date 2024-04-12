import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _loggedInUser;
  String _receiverId = 'receiverUserId'; // Change this to the receiver's user ID

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final User? user = _auth.currentUser;
    if (user != null) {
      _loggedInUser = user;
    }
  }

  void sendMessage() async {
    final String messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      try {
        await _firestore.collection('chats').add({
          'senderId': _loggedInUser!.uid,
          'receiverId': _receiverId,
          'message': messageText,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _messageController.clear();
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('chats')
                  .where('senderId', isEqualTo: _loggedInUser!.uid)
                  .where('receiverId', isEqualTo: _receiverId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final List<DocumentSnapshot> messages = snapshot.data!.docs;
                return ListView(
                  reverse: true,
                  padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                  children: messages.map((DocumentSnapshot document) {
                    final Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['message']),
                      subtitle: Text(
                        '${data['senderId']} - ${data['timestamp'].toDate()}',
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
