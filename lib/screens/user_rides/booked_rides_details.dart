import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:lyft_mate/screens/chat/dash_chatpage.dart';

import '../profile/other_userprofile.dart';

class MyBookedRidesDetailsPage extends StatefulWidget {
  final String rideId;

  const MyBookedRidesDetailsPage({Key? key, required this.rideId})
      : super(key: key);

  @override
  _MyBookedRidesDetailsPageState createState() =>
      _MyBookedRidesDetailsPageState();
}

class _MyBookedRidesDetailsPageState extends State<MyBookedRidesDetailsPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? rideData;

  @override
  void initState() {
    super.initState();
    _fetchRideData();
  }

  Future<void> _fetchRideData() async {
    final DocumentSnapshot rideDoc =
        await firestore.collection('rides').doc(widget.rideId).get();
    setState(() {
      rideData = rideDoc.data() as Map<String, dynamic>?;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (rideData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ride Details'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    List<dynamic> passengers = rideData!['passengers'] ?? [];
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    String driverId = rideData!['driverId'] ?? "Unknown";

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
                        'Ride ID: ${widget.rideId}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 20, thickness: 1),
                      _buildRideInfoRow(
                          'Starting Point:', rideData!['pickupCityName']),
                      _buildRideInfoRow(
                          'Ending Point:', rideData!['dropoffCityName']),
                      _buildRideInfoRow('Date:',
                          formatter.format(rideData!['date'].toDate())),
                      _buildRideInfoRow('Price per Seat:',
                          'LKR ${rideData!['pricePerSeat']}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Driver:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildDriverInfo(driverId),
              const SizedBox(height: 20),
              const Text(
                'Passengers:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: passengers.length,
                itemBuilder: (context, index) {
                  return _buildPassengerCard(passengers[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildDriverInfo(String driverId) {
  //   return FutureBuilder<DocumentSnapshot>(
  //     future: firestore.collection('users').doc(driverId).get(),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const ListTile(
  //           leading: CircularProgressIndicator(),
  //           title: Text('Loading driver details...'),
  //         );
  //       } else if (snapshot.hasError) {
  //         return const ListTile(
  //           title: Text('Error loading data'),
  //         );
  //       } else if (snapshot.hasData) {
  //         var driverData = snapshot.data!.data() as Map<String, dynamic>;
  //         String? profileImageUrl = driverData['profileImageUrl'];
  //         return ListTile(
  //           leading: profileImageUrl != null && profileImageUrl.isNotEmpty
  //               ? CircleAvatar(
  //             radius: 25,
  //             backgroundImage: NetworkImage(profileImageUrl),
  //           )
  //               : const CircleAvatar(
  //             radius: 25,
  //             child: Icon(Icons.person, color: Colors.blue),
  //           ),
  //           title: Text('${driverData['firstName']} ${driverData['lastName']}'),
  //           subtitle: Text('Contact Driver'),
  //           trailing: IconButton(
  //             icon: const Icon(Icons.message, color: Colors.deepPurple),
  //             onPressed: () {
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) => DashChatPage(
  //                     receiverUserEmail: driverData['email'] ?? "",
  //                     receiverUserID: driverId,
  //                   ),
  //                 ),
  //               );
  //             },
  //           ),
  //         );
  //       } else {
  //         return const ListTile(
  //           title: Text('No data available'),
  //         );
  //       }
  //     },
  //   );
  // }
  Widget _buildDriverInfo(String driverId) {
    return FutureBuilder<DocumentSnapshot>(
      future: firestore.collection('users').doc(driverId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: CircularProgressIndicator(),
            title: Text('Loading driver details...'),
          );
        } else if (snapshot.hasError) {
          return const ListTile(
            title: Text('Error loading data'),
          );
        } else if (snapshot.hasData && snapshot.data!.data() != null) {
          var driverData = snapshot.data!.data() as Map<String, dynamic>;
          String? profileImageUrl = driverData['profileImageUrl'];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OtherUserProfileScreen(userId: driverId),
                ),
              );
            },
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
              title:
                  Text('${driverData['firstName']} ${driverData['lastName']}'),
              subtitle: Text(
                  'Ratings: ${driverData['ratings'] ?? "N/A"}'),
              // subtitle: Text(
              //     'Ratings: ${driverData['ratings'] ?? "N/A"} Reviews: ${driverData['reviews'].length}'),
              trailing: IconButton(
                icon: const Icon(Icons.message, color: Colors.deepPurple),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashChatPage(
                        receiverUserEmail: driverData['email'] ?? "",
                        receiverUserID: driverId,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        } else {
          return const ListTile(
            title: Text('No data available'),
          );
        }
      },
    );
  }

  // Widget _buildPassengerCard(Map<String, dynamic> passenger) {
  //   return FutureBuilder<DocumentSnapshot>(
  //     future: firestore.collection('users').doc(passenger['userId']).get(),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const ListTile(
  //           leading: CircularProgressIndicator(),
  //           title: Text('Loading passenger details...'),
  //         );
  //       } else if (snapshot.hasError) {
  //         return const ListTile(
  //           title: Text('Error loading data'),
  //         );
  //       } else if (snapshot.hasData && snapshot.data!.data() != null) {
  //         var userData = snapshot.data!.data() as Map<String, dynamic>;
  //         String? profileImageUrl = userData['profileImageUrl'];
  //         return GestureDetector(
  //           onTap: () {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) =>
  //                     OtherUserProfileScreen(userId: passenger['userId']),
  //               ),
  //             );
  //           },
  //           child: Card(
  //             margin: const EdgeInsets.symmetric(vertical: 8.0),
  //             elevation: 2,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(8.0),
  //             ),
  //             child: ListTile(
  //               leading: profileImageUrl != null && profileImageUrl.isNotEmpty
  //                   ? CircleAvatar(
  //                       radius: 25,
  //                       backgroundImage: NetworkImage(profileImageUrl),
  //                     )
  //                   : const CircleAvatar(
  //                       radius: 25,
  //                       child: Icon(Icons.person, color: Colors.blue),
  //                     ),
  //               title: Text('${userData['firstName']} ${userData['lastName']}'),
  //               subtitle: Text('Rating: ${userData['ratings'] ?? "N/A"}'),
  //             ),
  //           ),
  //         );
  //       } else {
  //         return const ListTile(
  //           title: Text('No data available'),
  //         );
  //       }
  //     },
  //   );
  // }

  Widget _buildPassengerCard(Map<String, dynamic> passenger) {
    return FutureBuilder<DocumentSnapshot>(
      future: firestore.collection('users').doc(passenger['userId']).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            // leading: CircularProgressIndicator(),
            title: Text('Loading passenger details...'),
          );
        } else if (snapshot.hasError) {
          return const ListTile(
            title: Text('Error loading data'),
          );
        } else if (snapshot.hasData && snapshot.data!.data() != null) {
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String? profileImageUrl = userData['profileImageUrl'];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OtherUserProfileScreen(userId: passenger['userId']),
                ),
              );
            },
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
            ),
          );
        } else {
          return const ListTile(
            title: Text('No data available'),
          );
        }
      },
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
