import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lyft_mate/home.dart';
import 'package:lyft_mate/screens/chat/chatpage.dart';

import '../../services/authentication_service.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat List"),
      ),
      body: SafeArea(
        child: _buildUserList(),
      ),
    );
  }

  //build a list of user except the current logged user
  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("loading....");
        }
        List<Widget> userWidgets = snapshot.data!.docs
            .map<Widget>((doc) => _buildUserListItem(doc))
            .toList();
        return ListView(
          children: userWidgets,
        );
      },
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    // Extract document data
    Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

    // Ensure document data is not null
    if (data != null) {
      // Check if the user is not the current logged-in user
      if (_auth.currentUser!.uid != data["userID"]) {
        // If not the current user, build the ListTile
        return ListTile(
          title: Text("${data["firstName"]} ${data["lastName"]}"), // Displaying full name
          onTap: () {
            // Go to chat page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  receiverUserEmail: data['email'] ?? "", // Accessing the 'email' field
                  receiverUserID: data['userID'] ?? "", // Accessing the 'userID' field
                ),
              ),
            );
          },
        );
      }
    }

    // If the document data is null or the current user, return an empty container
    return Container();
  }


}
