// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
//
// class NotificationsPage extends StatefulWidget {
//   const NotificationsPage({Key? key});
//
//   @override
//   State<NotificationsPage> createState() => _NotificationsPageState();
// }
//
// class _NotificationsPageState extends State<NotificationsPage> {
//   String? userID = FirebaseAuth.instance.currentUser?.uid;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Notifications"),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//         elevation: 0.5,
//         leadingWidth: 50.0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios), // Back button icon
//           onPressed: () {
//             Navigator.pop(context); // Handle back navigation
//           },
//         ),
//       ),
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance
//             .collection('users')
//             .doc(userID)
//             .collection('notifications')
//             .orderBy('timestamp', descending: true)
//             .snapshots(),
//         builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           // Extract notifications from the snapshot
//           final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
//
//           // Group notifications by date
//           final Map<String, List<QueryDocumentSnapshot>> groupedNotifications = {};
//           for (final document in documents) {
//             final Timestamp timestamp = document['timestamp'];
//             final DateTime dateTime = timestamp.toDate();
//             final String dateKey = DateFormat('yyyy-MM-dd').format(dateTime); // Date as the grouping key
//
//             if (!groupedNotifications.containsKey(dateKey)) {
//               groupedNotifications[dateKey] = [];
//             }
//             groupedNotifications[dateKey]!.add(document);
//           }
//
//           return ListView(
//             children: groupedNotifications.entries.map((entry) {
//               final String date = entry.key;
//               final List<QueryDocumentSnapshot> notifications = entry.value;
//
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Section header for the date
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                     child: Text(
//                       DateFormat('EEEE, MMMM d, yyyy').format(DateTime.parse(date)),
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   // List of notifications for the specific date
//                   ...notifications.map((notification) {
//                     final Timestamp timestamp = notification['timestamp'];
//                     final DateTime dateTime = timestamp.toDate();
//                     final String time = DateFormat('h:mm a').format(dateTime); // Display time only
//
//                     return Dismissible(
//                       key: Key(notification.id),
//                       onDismissed: (direction) {
//                         // Remove the notification from Firestore
//                         notification.reference.delete();
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text("Notification dismissed")),
//                         );
//                       },
//                       background: Container(
//                         color: Colors.red,
//                         alignment: Alignment.centerRight,
//                         padding: const EdgeInsets.only(right: 16.0),
//                         child: const Icon(Icons.delete, color: Colors.white),
//                       ),
//                       child: Card(
//                         margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 notification['title'] ?? "",
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 notification['message'] ?? "",
//                                 style: const TextStyle(fontSize: 14),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 'Time: $time',
//                                 style: const TextStyle(fontSize: 12, color: Colors.grey),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ],
//               );
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }
// }


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String? userID = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
        // leadingWidth: 50.0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios),
        //   onPressed: () {
        //     Navigator.pop(context); // Handle back navigation
        //   },
        // ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Extract notifications from the snapshot
          final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

          // Check if there are no notifications
          if (documents.isEmpty) {
            return const Center(
              child: Text(
                "No notifications",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Group notifications by date
          final Map<String, List<QueryDocumentSnapshot>> groupedNotifications = {};
          for (final document in documents) {
            final Timestamp timestamp = document['timestamp'];
            final DateTime dateTime = timestamp.toDate();
            final String dateKey = DateFormat('yyyy-MM-dd').format(dateTime);

            if (!groupedNotifications.containsKey(dateKey)) {
              groupedNotifications[dateKey] = [];
            }
            groupedNotifications[dateKey]!.add(document);
          }

          return ListView(
            children: groupedNotifications.entries.map((entry) {
              final String date = entry.key;
              final List<QueryDocumentSnapshot> notifications = entry.value;

              // Format the date into a readable format with weekday
              final formattedDate = DateFormat('EEEE MMM d, yyyy').format(DateTime.parse(date));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date header with dividers
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        // const Expanded(
                        //   child: Padding(
                        //     padding: EdgeInsets.symmetric(horizontal: 20.0),
                        //     child: Divider(thickness: 1, color: Colors.grey),
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            '$formattedDate',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        // const Expanded(
                        //   child: Divider(thickness: 1, color: Colors.grey),
                        // ),
                      ],
                    ),
                  ),
                  // List of notifications for the specific date
                  ...notifications.map((notification) {
                    final Timestamp timestamp = notification['timestamp'];
                    final DateTime dateTime = timestamp.toDate();
                    final String time = DateFormat('h:mm a').format(dateTime);

                    return Dismissible(
                      key: Key(notification.id),
                      onDismissed: (direction) {
                        // Remove the notification from Firestore
                        notification.reference.delete();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Notification dismissed")),
                        );
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16.0),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification['title'] ?? "",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                notification['message'] ?? "",
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Time: $time',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}






// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:provider/provider.dart';
//
// import '../../providers/notification_provider.dart';
//
// class NotificationsPage extends StatefulWidget {
//   const NotificationsPage({Key? key});
//
//   @override
//   State<NotificationsPage> createState() => _NotificationsPageState();
// }
//
// class _NotificationsPageState extends State<NotificationsPage> {
//   String? userID = FirebaseAuth.instance.currentUser?.uid;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Notifications"),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//         elevation: 0.5,
//         // leadingWidth: 50.0,
//         // leading: IconButton(
//         //   icon: Icon(Icons.arrow_back_ios), // Back button icon
//         //   onPressed: () {
//         //     Navigator.pop(context); // Handle back navigation
//         //   },
//         // ),
//       ),
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance
//             .collection('users')
//             .doc(userID)
//             .collection('notifications')
//             .orderBy('timestamp', descending: true)
//             .snapshots(),
//         builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//
//           // Extract notifications from the snapshot
//           final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
//
//           // Get the provider instance
//           final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
//
//           // Check if there are new notifications
//           // final bool hasNewNotification = documents.isNotEmpty;
//           //
//           // // Update the provider with the new notification status
//           // notificationProvider.setNewNotification(hasNewNotification);
//
//           // Listen for real-time changes in the Firestore collection
//           // FirebaseFirestore.instance
//           //     .collection('users')
//           //     .doc(userID)
//           //     .collection('notifications')
//           //     .snapshots()
//           //     .listen((snapshot) {
//           //   // Check if there are new documents or modifications
//           //   bool hasNewDocument = snapshot.docChanges.any((change) => change.type == DocumentChangeType.added || change.type == DocumentChangeType.modified);
//           //   print("HAASSSSSSSSSSSSSS CHANGEEEEEEEEEE: $hasNewDocument");
//           //   // Update the provider with the new notification status
//           //   // notificationProvider.setNewNotification(hasNewDocument);
//           // });
//
//           return ListView.builder(
//             itemCount: documents.length,
//             itemBuilder: (context, index) {
//               final notification = documents[index];
//               return Dismissible(
//                 key: Key(notification.id),
//                 onDismissed: (direction) {
//                   // Remove the notification from Firestore
//                   notification.reference.delete();
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text("Notification dismissed"),
//                     ),
//                   );
//                 },
//                 background: Container(
//                   color: Colors.red,
//                   alignment: Alignment.centerRight,
//                   padding: EdgeInsets.only(right: 16.0),
//                   child: Icon(
//                     Icons.delete,
//                     color: Colors.white,
//                   ),
//                 ),
//                 child: Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           notification['title'] ?? "",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(height: 8),
//                         Text(
//                           notification['message'] ?? "",
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }






// workingggg-
// class NotificationsPage extends StatefulWidget {
//   const NotificationsPage({Key? key});
//
//   @override
//   State<NotificationsPage> createState() => _NotificationsPageState();
// }
//
// class _NotificationsPageState extends State<NotificationsPage> {
//
//   String? userID = FirebaseAuth.instance.currentUser?.uid;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Notifications"),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//         elevation: 0.5,
//         leadingWidth: 50.0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios), // Back button icon
//           onPressed: () {
//             Navigator.pop(context); // Handle back navigation
//           },
//         ),
//       ),
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance
//             .collection('users')
//             .doc(userID)
//             .collection('notifications')
//             .orderBy('timestamp', descending: true) // Order notifications by timestamp
//             .snapshots(),
//         builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//
//           // Extract notifications from the snapshot
//           final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
//
//           return ListView.builder(
//             itemCount: documents.length,
//             itemBuilder: (context, index) {
//               final notification = documents[index];
//               return Dismissible(
//                 key: Key(notification.id),
//                 onDismissed: (direction) {
//                   // Remove the notification from Firestore
//                   notification.reference.delete();
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text("Notification dismissed"),
//                     ),
//                   );
//                 },
//                 background: Container(
//                   color: Colors.red,
//                   alignment: Alignment.centerRight,
//                   padding: EdgeInsets.only(right: 16.0),
//                   child: Icon(
//                     Icons.delete,
//                     color: Colors.white,
//                   ),
//                 ),
//                 child: Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           notification['title'] ?? "",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(height: 8),
//                         Text(
//                           notification['message'] ?? "",
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }









// hardcoddeddddddd---------------
// import 'package:flutter/material.dart';
//
// class NotificationsPage extends StatefulWidget {
//   const NotificationsPage({Key? key});
//
//   @override
//   State<NotificationsPage> createState() => _NotificationsPageState();
// }
//
// class _NotificationsPageState extends State<NotificationsPage> {
//   late List<bool> notificationTapped;
//
//   List<String> notifications = [
//     "You have a new ride request from John for a trip to downtown tomorrow at 9:00 AM.",
//     "Alice accepted your ride request for the trip to the airport on Friday at 6:30 PM.",
//     "Your upcoming ride with David has been canceled. Please find an alternate ride.",
//     "Reminder: Your ride with Emily is scheduled for Monday at 8:15 AM. Don't forget!",
//     "You've received a new message from Sarah regarding your ride to the concert tonight.",
//     // Add more notifications as needed
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     notificationTapped = List<bool>.generate(notifications.length, (index) => false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Notifications"),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//         elevation: 0.5,
//         leadingWidth: 50.0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios), // Back button icon
//           onPressed: () {
//             Navigator.pop(context); // Handle back navigation
//           },
//         ),
//       ),
//       body: ListView.builder(
//         itemCount: notifications.length,
//         itemBuilder: (context, index) {
//           return Dismissible(
//             key: Key(notifications[index]),
//             onDismissed: (direction) {
//               setState(() {
//                 notifications.removeAt(index);
//               });
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text("Notification dismissed"),
//                 ),
//               );
//             },
//             background: Container(
//               color: Colors.red,
//               alignment: Alignment.centerRight,
//               padding: EdgeInsets.only(right: 16.0),
//               child: Icon(
//                 Icons.delete,
//                 color: Colors.white,
//               ),
//             ),
//             child: Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           "Notification",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         notificationTapped[index]
//                             ? Icon(Icons.notifications_active, color: Colors.green)
//                             : Icon(Icons.notifications_off, color: Colors.red),
//                       ],
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       notifications[index],
//                       style: TextStyle(fontSize: 16),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
