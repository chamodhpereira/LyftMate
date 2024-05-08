import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lyft_mate/home.dart';
import 'package:lyft_mate/screens/chat/chatpage.dart';
import 'package:lyft_mate/screens/chat/dash_chatpage.dart';

import '../../services/authentication_service.dart';
import '../../services/chat/chat_service.dart';

// class UserList extends StatefulWidget {
//   const UserList({Key? key}) : super(key: key);
//
//   @override
//   State<UserList> createState() => _UserListState();
// }
//
// class _UserListState extends State<UserList> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Chat List"),
//       ),
//       body: SafeArea(
//         child: _buildUserList(),
//       ),
//     );
//   }
//
//   // Build the list of users that the logged-in user has sent messages to
//   Widget _buildUserList() {
//     return FutureBuilder<List<String>>(
//       future: ChatService().getUsersWithMessages(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }
//         List<String> receiverIds = snapshot.data ?? [];
//
//         // Return a stream builder to listen for changes in the users collection
//         return StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance.collection('users').snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return Center(child: Text('Error: ${snapshot.error}'));
//             }
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             }
//
//             // Filter out users that are receivers of messages sent by the logged-in user
//             List<DocumentSnapshot> filteredUsers = snapshot.data!.docs.where((doc) {
//               return receiverIds.contains(doc.id);
//             }).toList();
//
//             // Build list of user widgets
//             List<Widget> userWidgets = filteredUsers
//                 .map<Widget>((doc) => _buildUserListItem(doc))
//                 .toList();
//             return ListView(
//               children: userWidgets,
//             );
//           },
//         );
//       },
//     );
//   }
//
//   // Build a single user list item
//   Widget _buildUserListItem(DocumentSnapshot document) {
//     Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
//
//     if (data != null) {
//       return ListTile(
//         title: Text("${data["firstName"]} ${data["lastName"]}"),
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ChatPage(
//                 receiverUserEmail: data['email'] ?? "",
//                 receiverUserID: document.id,
//               ),
//             ),
//           );
//         },
//       );
//     }
//     return Container(); // Return empty container if document data is null
//   }
// }


class UserList extends StatefulWidget {
  const UserList({Key? key}) : super(key: key);

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChatService _chatService = ChatService(); // Instantiate ChatService

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Messages"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: _buildUserList(),
      ),
    );
  }

  // // build a list of users that the current user has messaged with
  // Widget _buildUserList() {
  //   return FutureBuilder<List<String>>(
  //     future: _chatService.getUsersWithMessages(),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return Center(child: CircularProgressIndicator());
  //       } else if (snapshot.hasError) {
  //         return Center(child: Text('Error: ${snapshot.error}'));
  //       } else {
  //         List<String> receiverIds = snapshot.data ?? [];
  //         return ListView.builder(
  //           itemCount: receiverIds.length,
  //           itemBuilder: (context, index) {
  //             return _buildUserListItem(receiverIds[index]);
  //           },
  //         );
  //       }
  //     },
  //   );
  // }

  // build a list of users that the current user has messaged with
  Widget _buildUserList() {
    return FutureBuilder<List<String>>(
      future: _chatService.getUsersWithMessages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<String> receiverIds = snapshot.data ?? [];
          if (receiverIds.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Join the carpooling community!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Start messaging other members to arrange rides and share the journey!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 10),
                    // You can add a button or any other UI element here to encourage users to join the community
                  ],
                ),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: receiverIds.length,
              itemBuilder: (context, index) {
                return _buildUserListItem(receiverIds[index]);
              },
            );
          }
        }
      },
    );
  }

  // build a list item for each user
  Widget _buildUserListItem(String userId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            title: Text("Loading..."),
          );
        } else if (snapshot.hasError) {
          return ListTile(
            title: Text("Error"),
          );
        } else {
          Map<String, dynamic>? userData = snapshot.data?.data() as Map<String, dynamic>?;

          if (userData != null) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 0),
              child: ListTile(
                dense: false,
                leading: const CircleAvatar(
                  child: Icon(
                    Icons.person,   // TODO: get user profile image as network image from model
                    size: 25.0,
                  ),
                ),
                title: Text("${userData['firstName']} ${userData['lastName']}"),
                // onTap: () {   // working commented to add dash chat
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => ChatPage(
                //         receiverUserEmail: userData['email'] ?? "",
                //         receiverUserID: userId,
                //       ),
                //     ),
                //   );
                // },
                onTap: () {   // working commented to add dash chat
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashChatPage(
                        receiverUserEmail: userData['email'] ?? "",
                        receiverUserID: userId,
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return ListTile(
              title: Text("User not found"),
            );
          }
        }
      },
    );
  }
}





// workig i guessss but no sent user retreieval
// class UserList extends StatefulWidget {
//   const UserList({super.key});
//
//   @override
//   State<UserList> createState() => _UserListState();
// }
//
// class _UserListState extends State<UserList> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Chat List"),
//       ),
//       body: SafeArea(
//         child: _buildUserList(),
//       ),
//     );
//   }
//
//   // build a list of user except the current logged user
//   Widget _buildUserList() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('users').snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return const Text('error');
//         }
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Text("loading....");
//         }
//         List<Widget> userWidgets = snapshot.data!.docs
//             .map<Widget>((doc) => _buildUserListItem(doc))
//             .toList();
//         return ListView(
//           children: userWidgets,
//         );
//       },
//     );
//   }
//
//   Widget _buildUserListItem(DocumentSnapshot document) {
//     // Extract document data
//     Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
//
//     // Ensure document data is not null
//     if (data != null) {
//       print("User data: $data"); // Print document data to check its content
//
//       // Check if the 'userID' field exists
//       if (data.containsKey("userID")) {
//         // If the 'userID' field exists, proceed
//         // Check if the 'userID' field is not empty
//         if (data["userID"] != null && data["userID"].toString().isNotEmpty) {
//           // If the 'userID' is not empty, proceed
//           // Check if the user is not the current logged-in user
//           if (_auth.currentUser!.uid != data["userID"]) {
//             // If not the current user, build the ListTile
//             return ListTile(
//               title: Text("${data["firstName"]} ${data["lastName"]}"), // Displaying full name
//               onTap: () {
//                 // Go to chat page
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ChatPage(
//                       receiverUserEmail: data['email'] ?? "", // Accessing the 'email' field
//                       receiverUserID: data['userID'] ?? "", // Accessing the 'userID' field
//                     ),
//                   ),
//                 );
//               },
//             );
//           }
//         } else {
//           print("User ID is empty."); // Print a message if the 'userID' field is empty
//         }
//       } else {
//         print("User ID field does not exist."); // Print a message if the 'userID' field is missing
//       }
//     }
//
//     // Return null if the document data is null or if the conditions are not met
//     return Container();
//   }



  // Widget _buildUserListItem(DocumentSnapshot document) {
  //   // Extract document data
  //   Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
  //
  //   // Ensure document data is not null
  //   if (data != null) {
  //     // Check if the user is not the current logged-in user
  //     if (_auth.currentUser!.uid != data["userID"]) {
  //       // If not the current user, build the ListTile
  //       return ListTile(
  //         title: Text("${data["firstName"]} ${data["lastName"]}"), // Displaying full name
  //         onTap: () {
  //           // Go to chat page
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => ChatPage(
  //                 receiverUserEmail: data['email'] ?? "", // Accessing the 'email' field
  //                 receiverUserID: data['userID'] ?? "", // Accessing the 'userID' field
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     }
  //   }
  //
  //   // If the document data is null or the current user, return an empty container
  //   return Container();
  // }


// }
