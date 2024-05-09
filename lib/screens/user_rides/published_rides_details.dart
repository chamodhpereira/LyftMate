import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:lyft_mate/screens/chat/dash_chatpage.dart';

class MyPublishedRideDetailsPage extends StatefulWidget {
  final String rideId;

  const MyPublishedRideDetailsPage({Key? key, required this.rideId}) : super(key: key);

  @override
  _MyPublishedRideDetailsPageState createState() => _MyPublishedRideDetailsPageState();
}

class _MyPublishedRideDetailsPageState extends State<MyPublishedRideDetailsPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? rideData;

  @override
  void initState() {
    super.initState();
    _fetchRideData();
  }

  Future<void> _fetchRideData() async {
    // Fetch the latest ride data from Firestore
    final DocumentSnapshot rideDoc = await firestore.collection('rides').doc(widget.rideId).get();
    setState(() {
      rideData = rideDoc.data() as Map<String, dynamic>?;
    });
  }

  Future<void> _acceptRequest(Map<String, dynamic> request) async {
    final passenger = {
      'userId': request['passengerId'],
      'amount': request['amount'],
      'dropoffCoordinate': request['dropoffCoordinate'],
      'pickupCoordinate': request['pickupCoordinate'],
      'seats': request['seatsRequested'],
      'paidStatus': false,
    };

    await firestore.collection('rides').doc(widget.rideId).update({
      'passengers': FieldValue.arrayUnion([passenger]),
      'rideRequests': FieldValue.arrayRemove([request]),
    });

    // Refresh ride data
    _fetchRideData();
  }

  Future<void> _declineRequest(Map<String, dynamic> request) async {
    await firestore.collection('rides').doc(widget.rideId).update({
      'rideRequests': FieldValue.arrayRemove([request]),
    });

    // Refresh ride data
    _fetchRideData();
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
    List<dynamic> requests = rideData!['rideRequests'] ?? [];
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

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
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 20, thickness: 1),
                      _buildRideInfoRow('Starting Point:', rideData!['pickupCityName']),
                      _buildRideInfoRow('Ending Point:', rideData!['dropoffCityName']),
                      _buildRideInfoRow('Date:', formatter.format(rideData!['date'].toDate())),
                      _buildRideInfoRow('Price per Seat:', 'LKR ${rideData!['pricePerSeat']}'),
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
                  return _buildPassengerCard(passengers[index]);
                },
              ),
              const SizedBox(height: 20),
              Visibility(
                visible: requests.isNotEmpty, // Show only if there are requests
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ride Requests:',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        return _buildRequestCard(context, requests[index]);
                      },
                    ),
                  ],
                ),
              )


              // Text(
              //   'Ride Requests:',
              //   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              // ),
              // const SizedBox(height: 10),
              // ListView.builder(
              //   physics: const NeverScrollableScrollPhysics(),
              //   shrinkWrap: true,
              //   itemCount: requests.length,
              //   itemBuilder: (context, index) {
              //     return _buildRequestCard(context, requests[index]);
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPassengerCard(Map<String, dynamic> passenger) {
    return FutureBuilder<DocumentSnapshot>(
      future: firestore.collection('users').doc(passenger['userId']).get(),
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
                        receiverUserID: passenger['userId'],
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
  }

  Widget _buildRequestCard(BuildContext context, Map<String, dynamic> request) {
    return FutureBuilder<DocumentSnapshot>(
      future: firestore.collection('users').doc(request['passengerId']).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: CircularProgressIndicator(),
            title: Text('Loading request details...'),
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
              subtitle: Text('Requested Seats: ${request['seatsRequested']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => _acceptRequest(request),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _declineRequest(request),
                  ),
                ],
              ),
            ),
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
