import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:lyft_mate/screens/user_rides/published_rides_details.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ride_tracking/ride_tracking_screen.dart';

class UserRides extends StatefulWidget {
  @override
  _UserRidesState createState() => _UserRidesState();
}

class _UserRidesState extends State<UserRides> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Location location = Location();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  late CollectionReference ridesCollection;

  late User _user = FirebaseAuth.instance.currentUser!; // Add a User object to store the current user

  List<String> canceledRideIds = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    ridesCollection = firestore.collection('rides');
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
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(_user.uid)
                .snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return Center(child: Text('No data available'));
              }
              Map<String, dynamic>? userData =
                  snapshot.data?.data() as Map<String, dynamic>?;

              List<dynamic>? ridesPublishedIds = userData?['ridesPublished'];
              print("Rideeee booked idsss: $ridesPublishedIds");

              if (ridesPublishedIds == null || ridesPublishedIds.isEmpty) {
                return Center(child: Text('No rides offered'));
              }

              // Retrieve ride details for each ride ID
              return FutureBuilder(
                future: _fetchRidesDetails(ridesPublishedIds),
                builder: (context,
                    AsyncSnapshot<List<Map<String, dynamic>>> ridesSnapshot) {
                  if (ridesSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!ridesSnapshot.hasData || ridesSnapshot.data!.isEmpty) {
                    return Center(child: Text('No ride details available'));
                  }

                  // Display ridesOffered with details in a list
                  return ListView.builder(
                    itemCount: ridesSnapshot.data!.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> rideData =
                          ridesSnapshot.data![index];
                      String rideId = rideData['id']; // Get the document ID
                      return _buildPublishedRideCard(rideData, rideId);

                      // return _buildRideCard(ridesSnapshot.data![index]);
                    },
                  );
                },
              );
            },
          ),
          // Rides Published Tab
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(_user.uid)
                .snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return Center(child: Text('No data available'));
              }
              Map<String, dynamic>? userData =
                  snapshot.data?.data() as Map<String, dynamic>?;
              print("USERRRR DATAAAAA $userData");

              List<dynamic>? ridesBookedIds = userData?['ridesBooked'];
              print("Rideeee booked idsss: $ridesBookedIds");

              if (ridesBookedIds == null || ridesBookedIds.isEmpty) {
                return const Center(child: Text('No rides booked'));
              }

              // Retrieve ride details for each ride ID
              return FutureBuilder(
                future: _fetchRidesDetails(ridesBookedIds),
                builder: (context,
                    AsyncSnapshot<List<Map<String, dynamic>>> ridesSnapshot) {
                  if (ridesSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!ridesSnapshot.hasData || ridesSnapshot.data!.isEmpty) {
                    return Center(child: Text('No ride details available'));
                  }

                  // Display ridesBooked with details in a list
                  return ListView.builder(
                    itemCount: ridesSnapshot.data!.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> rideData =
                          ridesSnapshot.data![index];
                      String rideId = rideData['id']; // Get the document ID
                      return _buildBookedRideCard(rideData, rideId);
                      // return _buildRideCard(ridesSnapshot.data![index]);
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

    for (var rideId in rideIds) {
      // Fetch ride details
      DocumentSnapshot rideSnapshot = await FirebaseFirestore.instance
          .collection('rides')
          .doc(rideId)
          .get();
      if (rideSnapshot.exists) {
        print("RIDESSSS EXISISTSSS");
        // Fetch driver details using driverId from ride details
        String driverId =
            (rideSnapshot.data() as Map<String, dynamic>)['userId'];
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(driverId)
            .get();
        if (userSnapshot.exists) {
          print("USEEEERRR EXISISTS");
          Map<String, dynamic> rideData =
              rideSnapshot.data() as Map<String, dynamic>;
          Map<String, dynamic> userData =
              userSnapshot.data() as Map<String, dynamic>;
          rideData['driverDetails'] =
              userData; // Adding driver details to rideData
          rideData['id'] = rideSnapshot.id;
          ridesDetails.add(rideData);

          print(ridesDetails.length);
        }
      }
    }
    return ridesDetails;
  }


  Future<void> updateRideLocation(String rideId, double newLatitude, double newLongitude) async {
    try {
      final DocumentSnapshot rideTrackingDoc = await ridesCollection.doc(rideId).get();

      // Check if doc with ride id exists:
      if (rideTrackingDoc.exists) {
        // Update the existing doc
        await ridesCollection.doc(rideId).update({
          'rideLocation': GeoPoint(newLatitude, newLongitude),
        });

        print("Updatedddd ride location in ride Document $rideId");
      } else {
        // Create a new one
        print("NOOOOOOOOOOOO DOCSSSSSSS FOUNF WITH ID $rideId");
        // await addRideTracking(rideId, newLatitude, newLongitude);
      }
    } catch(e) {
      print("Error updating in update order loc method: $e");
    }
  }

  double _previousLatitude = 0;
  double _previousLongitude = 0;

  void _subscribeToLocationChanges(String rideId) {
    location.onLocationChanged.listen((LocationData currentLocation) {
      double newLatitude = currentLocation.latitude ?? 0;
      double newLongitude = currentLocation.longitude ?? 0;

      // Calculate the distance between the new and previous locations
      double distance = _calculateDistance(_previousLatitude, _previousLongitude, newLatitude, newLongitude);

      // Update Firestore only if the distance exceeds a certain threshold (e.g., 100 meters)
      if (distance >= 1000) {
        print("Location changed: ${currentLocation}");
        updateRideLocation(rideId, newLatitude, newLongitude);

        // Update previous location data
        _previousLatitude = newLatitude;
        _previousLongitude = newLongitude;
      }
    });

    location.enableBackgroundMode(enable: true);
  }

// Function to calculate distance between two coordinates (in meters)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Radius of the earth in meters
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }


  Widget _buildPublishedRideCard(Map<String, dynamic> rideData, String rideId) {
    // Replace this with your actual ride data
    String startingPoint = rideData['pickupCityName'] ?? 'Starting Point';
    String endingPoint = rideData['dropoffCityName'] ?? 'Ending Point';
    double pricePerSeat = rideData['pricePerSeat'] ?? 10;
    DateTime rideDate = rideData['date'].toDate();
    String formattedDate = DateFormat('yyyy-MM-dd').format(rideDate);
    TimeOfDay startingTime = TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endingTime = TimeOfDay(hour: 10, minute: 0);
    String rideStatus = rideData['rideStatus'] ?? 'None';
    List<dynamic> passengers = rideData['passengers'] ?? [];

    bool isRideCancelled = canceledRideIds.contains(rideId);

    bool isRideStarted = false;

    // Extract driver details
    Map<String, dynamic> driverDetails = rideData['driverDetails'];
    String driverName = driverDetails['firstName'] + " " + driverDetails['lastName'] ?? 'Unknown';
    double driverRating = driverDetails['rating'] ?? 0.0;
    int numberOfReviews = driverDetails['numberOfReviews'] ?? 0;


    void _startJourney() async {
      // Update ride status to 'In Progress' in Firestore
      await FirebaseFirestore.instance.collection('rides').doc(rideId).update({
        'rideStatus': 'In Progress',
      });

      // Update UI if necessary
      setState(() {
        rideStatus = 'In Progress';
        isRideStarted = true;
      });

      if(isRideStarted) {
        print("Rideeeee JORUNEY STARTEDDDDD $rideId, inside WIDGET CARD");
        _subscribeToLocationChanges(rideId);
        // addRideTracking(rideIDController.text, customerLatitude, customerLongitude);
      }
    }

    void _cancelRide() async {
      // Show confirmation dialog
      bool confirmCancel = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirm Ride Cancellation'),
          content: Text('Are you sure you want to cancel the ride?'),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(false), // No, do not cancel
              child: Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Yes, cancel
              child: Text('Yes'),
            ),
          ],
        ),
      );

      // If user confirms cancellation, cancel the ride
      if (confirmCancel == true) {
        // Update ride status to 'Cancelled' in Firestore
        await FirebaseFirestore.instance
            .collection('rides')
            .doc(rideId)
            .update({
          'rideStatus': 'Cancelled',
        });
        // Update UI if necessary
        setState(() {
          rideStatus = 'Cancelled';
          canceledRideIds.add(rideId);
        });
      }
    }

    void _launchURL(String url) async {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    return GestureDetector(
      onTap: () {
        print("PResssseeedd");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyPublishedRideDetailsPage(rideData: rideData, rideId: rideId),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text('$startingPoint -> $endingPoint'),
              trailing: Chip(
                // label: Text(toBeginningOfSentenceCase(rideStatus)), // TODO: fix intl downgraded dependecy issue
                label: Text(rideStatus + "**"),
                backgroundColor:
                    toBeginningOfSentenceCase(rideStatus) == 'Pending'
                        ? Colors.blue
                        : rideStatus == 'Cancelled'
                            ? Colors.red
                            : Colors.green,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 22, color: Colors.grey.shade600),
                  SizedBox(width: 8),
                  Text(
                      '${startingTime.format(context)} - ${endingTime.format(context)}'),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 22, color: Colors.grey.shade600),
                  SizedBox(width: 8),
                  Text('$formattedDate'),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.attach_money, size: 22, color: Colors.grey.shade600),
                  SizedBox(width: 8),
                  Text('LKR $pricePerSeat'),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.person, size: 22, color: Colors.grey.shade600),
                  SizedBox(width: 8),
                  Text('Passengers: ${passengers.length}'),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Visibility(
                    visible: rideStatus != "Cancelled",
                    child: TextButton(
                      onPressed: isRideCancelled || rideStatus == "Cancelled"
                          ? null
                          : _cancelRide,
                      child: Text(
                        'Cancel Ride',
                        style: isRideCancelled || rideStatus == "Cancelled"
                            ? TextStyle(color: Colors.grey)
                            : TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isRideCancelled || rideStatus == "Cancelled"
                        ? null
                        : () {
                            // Construct the URL for the Google Maps directions
                            if (rideStatus == "In Progress") {
                              String destination =
                                  'latitude,longitude'; // Replace with the destination coordinates
                              String mapsUrl =
                                  'https://www.google.com/maps/dir/?api=1&destination=$destination';
                              _launchURL(mapsUrl); // Call method to launch URL
                            } else {
                              _startJourney();
                            }
                          },
                    style: ButtonStyle(
                      // Set background color to grey when button is disabled
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color?>((states) {
                        return isRideCancelled || rideStatus == "Cancelled"
                            ? Colors.grey
                            : Colors.green;
                      }),
                    ),
                    child: Text(rideStatus == 'In Progress'
                        ? 'Get Directions'
                        : 'Start Journey'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildBookedRideCard(Map<String, dynamic> rideData, String rideId) {

    User? user = FirebaseAuth.instance.currentUser;

    // Replace this with your actual ride data
    String startingPoint = rideData['pickupCityName'] ?? 'Starting Point';
    String endingPoint = rideData['dropoffCityName'] ?? 'Ending Point';
    double pricePerSeat = rideData['pricePerSeat'] ?? 10;
    DateTime rideDate = rideData['date'].toDate();
    String formattedDate = DateFormat('yyyy-MM-dd').format(rideDate);
    TimeOfDay startingTime = TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endingTime = TimeOfDay(hour: 10, minute: 0);
    String rideStatus = rideData['rideStatus'] ?? 'None';
    List<dynamic> passengers = rideData['passengers'] ?? [];

    // Extract driver details
    Map<String, dynamic> driverDetails = rideData['driverDetails'];
    String driverName =
        driverDetails['firstName'] + " " + driverDetails['lastName'] ??
            'Unknown';
    double driverRating = driverDetails['rating'] ?? 0.0;
    int numberOfReviews = driverDetails['numberOfReviews'] ?? 0;

    bool isInProgress = rideStatus.toLowerCase() == 'in progress';

    print("RIDDDDDDDDDDDDEEEEEEEEEE IDDDDD FOR TRACKING $rideId");

    void _leaveRide() async {
      passengers.remove(user?.uid); // Assuming userId is available in the scope

      // Update ride document
      await FirebaseFirestore.instance
          .collection('rides')
          .doc(rideId)
          .update({'passengers': passengers});

      // Remove ride from user's booked rides array
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .update({
        'ridesBooked': FieldValue.arrayRemove([rideId])
      });

      // Optionally, you can also update UI here
    }


    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text('$startingPoint -- --> $endingPoint', style: TextStyle(fontWeight: FontWeight.w900),),
            trailing: Chip(
              // label: Text(toBeginningOfSentenceCase(rideStatus ?? '')), // TODO: fix intl downgraded dependecy issue
            label: Text(rideStatus),
              backgroundColor:
                  toBeginningOfSentenceCase(rideStatus) == 'Pending'
                      ? Colors.blue
                      : rideStatus == 'Cancelled'
                          ? Colors.red
                          : Colors.green,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 20, color: Colors.grey.shade600,),
                SizedBox(width: 8),
                Text(
                    '${startingTime.format(context)} - ${endingTime.format(context)}'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.calendar_today ,size: 19, color: Colors.grey.shade600),
                SizedBox(width: 8),
                Text('$formattedDate'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.attach_money, size: 22, color: Colors.grey.shade600),
                SizedBox(width: 8),
                Text('LKR $pricePerSeat'),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.person, size: 22, color: Colors.grey.shade600),
                SizedBox(width: 8),
                Text('Passengers: ${passengers.length}'),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _leaveRide,
                child: Text("Leave Ride"),
              ),
              Visibility(
                visible: isInProgress,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RideTrackingPage(rideId: rideId, rideData: rideData)),
                      );
                    },
                    child: Text('Track Ride'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

