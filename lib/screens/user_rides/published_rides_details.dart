import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:lyft_mate/screens/chat/dash_chatpage.dart';

class MyPublishedRideDetailsPage extends StatelessWidget {
  final Map<String, dynamic> rideData;
  final String rideId;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  MyPublishedRideDetailsPage({Key? key, required this.rideData, required this.rideId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> passengers = rideData['passengers'] ?? [];
    final DateFormat formatter = DateFormat('yyyy-MM-dd'); // Date format

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Details'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
        leadingWidth: 50.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ride ID: $rideId',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 20, thickness: 1),
                      _buildRideInfoRow('Starting Point:', rideData['pickupCityName']),
                      _buildRideInfoRow('Ending Point:', rideData['dropoffCityName']),
                      _buildRideInfoRow('Date:', formatter.format(rideData['date'].toDate())),
                      _buildRideInfoRow('Price per Seat:', 'LKR ${rideData['pricePerSeat']}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Passengers:',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: passengers.length,
                itemBuilder: (context, index) {
                  return FutureBuilder<DocumentSnapshot>(
                    future: firestore.collection('users').doc(passengers[index]['userId']).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const ListTile(
                          leading: CircularProgressIndicator(),
                          title: Text('Loading passenger details...'),
                        );
                      } else if (snapshot.hasError) {
                        return const ListTile(
                          title: Text('Error loading data'),
                        );
                      } else {
                        var userData = snapshot.data!.data() as Map<String, dynamic>;
                        String? profileImageUrl = userData['profileImageUrl'];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ListTile(
                            leading: profileImageUrl != null && profileImageUrl.isNotEmpty
                                ? CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(profileImageUrl),
                            )
                                : const CircleAvatar(
                              radius: 25,
                              child: Icon(Icons.person, color: Colors.blue),
                            ),
                            title: Text('${userData['firstName']} ${userData['lastName']}'),
                            subtitle: Text('Rating: ${userData['ratings'] ?? "N/A"}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.message, color: Colors.deepPurple),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DashChatPage(
                                      receiverUserEmail: userData['email'] ?? "",
                                      receiverUserID: passengers[index]['userId'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRideInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }
}
