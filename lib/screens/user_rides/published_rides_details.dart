import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lyft_mate/screens/chat/chatpage.dart';

class MyPublishedRideDetailsPage extends StatelessWidget {
  final Map<String, dynamic> rideData;
  final String rideId;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  MyPublishedRideDetailsPage({Key? key, required this.rideData, required this.rideId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> passengers = rideData['passengers'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ride ID: $rideId', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('Starting Point: ${rideData['pickupCityName']}', style: TextStyle(fontSize: 16)),
            Text('Ending Point: ${rideData['dropoffCityName']}', style: TextStyle(fontSize: 16)),
            Text('Date: ${rideData['date'].toDate()}', style: TextStyle(fontSize: 16)),
            Text('Price per Seat: LKR ${rideData['pricePerSeat']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text('Passengers:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: passengers.length,
                itemBuilder: (context, index) {
                  return FutureBuilder<DocumentSnapshot>(
                    future: firestore.collection('users').doc(passengers[index]).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(
                          title: Text('Loading...'),
                        );
                      } else if (snapshot.hasError) {
                        return ListTile(
                          title: Text('Error: ${snapshot.error}'),
                        );
                      } else {
                        var userData = snapshot.data!.data();
                        return ListTile(
                          title: Text((userData as Map<String, dynamic>)['firstName']),
                          subtitle: Text('Rating: ${(userData as Map<String, dynamic>)['rating'] ?? "N/A"}'),
                          trailing: IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () {
                              // Navigate to the chat page with receiver details
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    receiverUserEmail: userData['email'] ?? "",
                                    receiverUserID: passengers[index],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Send a group message to passengers (You can implement this logic here if needed)
              },
              child: Text('Send Group Message to Passengers'),
            ),
          ],
        ),
      ),
    );
  }
}
