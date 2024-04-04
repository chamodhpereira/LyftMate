import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserRides extends StatefulWidget {
  @override
  _UserRidesState createState() => _UserRidesState();
}

class _UserRidesState extends State<UserRides> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late User _user = FirebaseAuth.instance.currentUser!;// Add a User object to store the current user

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // _getUser(); // Call _getUser method to get the current user
  }

  Future<void> _getUser() async {
    _user = FirebaseAuth.instance.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rides'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
        leadingWidth: 50.0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Published'),
            Tab(text: 'Booked'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Rides Offered Tab
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('users').doc(_user.uid).snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return Center(child: Text('No data available'));
              }
              Map<String, dynamic>? userData = snapshot.data?.data() as Map<String, dynamic>?;

              List<dynamic>? ridesOfferedIds = userData?['ridesPublished'];

              if (ridesOfferedIds == null || ridesOfferedIds.isEmpty) {
                return Center(child: Text('No rides offered'));
              }

              // Retrieve ride details for each ride ID
              return FutureBuilder(
                future: _fetchRidesDetails(ridesOfferedIds),
                builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> ridesSnapshot) {
                  if (ridesSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!ridesSnapshot.hasData || ridesSnapshot.data!.isEmpty) {
                    return Center(child: Text('No ride details available'));
                  }

                  // Display ridesOffered with details in a list
                  return ListView.builder(
                    itemCount: ridesSnapshot.data!.length,
                    itemBuilder: (context, index) {
                      return _buildRideCard(ridesSnapshot.data![index]);
                    },
                  );
                },
              );
            },
          ),
          // Rides Published Tab
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('users').doc(_user.uid).snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return Center(child: Text('No data available'));
              }
              Map<String, dynamic>? userData = snapshot.data?.data() as Map<String, dynamic>?;
              print("USERRRR DATAAAAA $userData");

              List<dynamic>? ridesPublishedIds = userData?['ridesBooked'];
              print("Rideeee publisheddd idsss: $ridesPublishedIds");

              if (ridesPublishedIds == null || ridesPublishedIds.isEmpty) {
                return Center(child: Text('No rides published'));
              }

              // Retrieve ride details for each ride ID
              return FutureBuilder(
                future: _fetchRidesDetails(ridesPublishedIds),
                builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> ridesSnapshot) {
                  if (ridesSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!ridesSnapshot.hasData || ridesSnapshot.data!.isEmpty) {
                    return Center(child: Text('No ride details available'));
                  }

                  // Display ridesPublished with details in a list
                  return ListView.builder(
                    itemCount: ridesSnapshot.data!.length,
                    itemBuilder: (context, index) {
                      return _buildRideCard(ridesSnapshot.data![index]);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchRidesDetails(List<dynamic> rideIds) async {
    List<Map<String, dynamic>> ridesDetails = [];
    // Fetch ride details for each ride ID
    for (var rideId in rideIds) {
      DocumentSnapshot rideSnapshot = await FirebaseFirestore.instance.collection('rides').doc(rideId).get();
      if (rideSnapshot.exists) {
        ridesDetails.add(rideSnapshot.data() as Map<String, dynamic>);
      }
    }
    return ridesDetails;
  }

  // Widget _buildRideCard(Map<String, dynamic> rideData) {
  //   // Customize this method to display rideData in a card
  //   // Example: Extract necessary information from rideData and build a card
  //   // ...
  //   return Card(
  //     // Card widget based on rideData
  //     // ...
  //   );
  // }

  Widget _buildRideCard(Map<String, dynamic> rideData) {
    // Replace this with your actual ride data
    String startingPoint = 'Starting Point';
    String endingPoint = 'Ending Point';
    double price = 50.0;
    DateTime rideDate = DateTime.now();
    TimeOfDay startingTime = TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endingTime = TimeOfDay(hour: 10, minute: 0);
    // int passengers = 3;
    String driverName = 'John Doe';
    double driverRating = 4.5;
    int numberOfReviews = 20;

    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text('$startingPoint -> $endingPoint'),
            trailing: Chip(
              label: Text("rideStatus"),
              // backgroundColor: rideStatus == 'Upcoming'
              //     ? Colors.blue
              //     : rideStatus == 'Cancelled'
              //     ? Colors.red
              //     : Colors.green,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.attach_money),
                SizedBox(width: 8),
                Text('\$$price'),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.calendar_today),
                SizedBox(width: 8),
                Text('${rideDate.year}-${rideDate.month}-${rideDate.day}'),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.access_time),
                SizedBox(width: 8),
                Text('${startingTime.format(context)} - ${endingTime.format(context)}'),
              ],
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              // Replace with driver's profile image
              backgroundColor: Colors.blue,
              child: Icon(Icons.person),
            ),
            title: Text('$driverName'),
            subtitle: Row(
              children: [
                Icon(Icons.star, color: Colors.yellow),
                SizedBox(width: 4),
                Text('$driverRating ($numberOfReviews Reviews)'),
              ],
            ),
          ),
        ],
      ),
    );
  }


}









// --------------- just the ui -------------
// class UserRides extends StatefulWidget {
//   @override
//   _UserRidesState createState() => _UserRidesState();
// }
//
// class _UserRidesState extends State<UserRides> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//
//
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Rides'),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//         elevation: 0.5,
//         leadingWidth: 50.0,
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: [
//             Tab(text: 'Published'),
//             Tab(text: 'Booked'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           // Published Rides Tab
//           Center(
//             child: Text('No any Published Rides'),
//           ),
//           // Booked Rides Tab
//           ListView(
//             children: [
//               _buildBookedRideCard('Upcoming'),
//               _buildBookedRideCard('Cancelled'),
//               _buildBookedRideCard('Completed'),
//               _buildBookedRideCard('Upcoming'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBookedRideCard(String rideStatus) {
//     // Replace this with your actual ride data
//     String startingPoint = 'Starting Point';
//     String endingPoint = 'Ending Point';
//     double price = 50.0;
//     DateTime rideDate = DateTime.now();
//     TimeOfDay startingTime = TimeOfDay(hour: 8, minute: 0);
//     TimeOfDay endingTime = TimeOfDay(hour: 10, minute: 0);
//     int passengers = 3;
//     String driverName = 'John Doe';
//     double driverRating = 4.5;
//     int numberOfReviews = 20;
//
//     return Card(
//       margin: EdgeInsets.all(10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ListTile(
//             title: Text('$startingPoint -> $endingPoint'),
//             trailing: Chip(
//               label: Text(rideStatus),
//               backgroundColor: rideStatus == 'Upcoming'
//                   ? Colors.blue
//                   : rideStatus == 'Cancelled'
//                   ? Colors.red
//                   : Colors.green,
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Row(
//               children: [
//                 Icon(Icons.attach_money),
//                 SizedBox(width: 8),
//                 Text('\$$price'),
//               ],
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Row(
//               children: [
//                 Icon(Icons.calendar_today),
//                 SizedBox(width: 8),
//                 Text('${rideDate.year}-${rideDate.month}-${rideDate.day}'),
//               ],
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Row(
//               children: [
//                 Icon(Icons.access_time),
//                 SizedBox(width: 8),
//                 Text('${startingTime.format(context)} - ${endingTime.format(context)}'),
//               ],
//             ),
//           ),
//           ListTile(
//             leading: CircleAvatar(
//               // Replace with driver's profile image
//               backgroundColor: Colors.blue,
//               child: Icon(Icons.person),
//             ),
//             title: Text('$driverName'),
//             subtitle: Row(
//               children: [
//                 Icon(Icons.star, color: Colors.yellow),
//                 SizedBox(width: 4),
//                 Text('$driverRating ($numberOfReviews Reviews)'),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
