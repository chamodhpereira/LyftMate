import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late List<bool> notificationTapped;

  List<String> notifications = [
    "You have a new ride request from John for a trip to downtown tomorrow at 9:00 AM.",
    "Alice accepted your ride request for the trip to the airport on Friday at 6:30 PM.",
    "Your upcoming ride with David has been canceled. Please find an alternate ride.",
    "Reminder: Your ride with Emily is scheduled for Monday at 8:15 AM. Don't forget!",
    "You've received a new message from Sarah regarding your ride to the concert tonight.",
    // Add more notifications as needed
  ];

  @override
  void initState() {
    super.initState();
    notificationTapped = List<bool>.generate(notifications.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
        leadingWidth: 50.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios), // Back button icon
          onPressed: () {
            Navigator.pop(context); // Handle back navigation
          },
        ),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(notifications[index]),
            onDismissed: (direction) {
              setState(() {
                notifications.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Notification dismissed"),
                ),
              );
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Notification",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        notificationTapped[index]
                            ? Icon(Icons.notifications_active, color: Colors.green)
                            : Icon(Icons.notifications_off, color: Colors.red),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      notifications[index],
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
