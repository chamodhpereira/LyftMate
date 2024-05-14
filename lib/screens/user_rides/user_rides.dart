import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:lyft_mate/screens/user_rides/booked_rides_details.dart';
import 'package:lyft_mate/screens/user_rides/published_rides_details.dart';


import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart';

import '../../services/authentication/authentication_service.dart';
import '../../services/sms/sms_service.dart';
import '../ride_tracking/driver_ride_tracking_screen.dart';
import '../ride_tracking/ride_tracking_screen.dart';

enum RideStatus {
  Cancelled,
  Pending,
  InProgress,
  Completed,
}

class UserRides extends StatefulWidget {
  @override
  _UserRidesState createState() => _UserRidesState();
}

class _UserRidesState extends State<UserRides>
    with SingleTickerProviderStateMixin {

  final AuthenticationService authService = AuthenticationService();

  late TabController _tabController;
  late RideStatus _selectedStatus = RideStatus.Pending; // Default filter

  Location location = Location();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late CollectionReference ridesCollection;
  late User? _user;

  List<String> canceledRideIds = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    ridesCollection = firestore.collection('rides');
    initializeUser();
    // _getUser(); // Call _getUser method to get the current user
  }


  Future<void> _getUser() async {
    _user = FirebaseAuth.instance.currentUser!;
  }

  void initializeUser() async{
    _user = FirebaseAuth.instance.currentUser;
    // await _user?.reload();
    if (_user == null) {
      debugPrint("No user is logged in.");
    } else {
      // Continue with any operations that require the user to be logged in
      print("User is logged in: ${_user!.uid}");
    }
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
            Tab(
              text: 'Published,',
            ),
            Tab(text: 'Booked'),
          ],
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 23.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<RideStatus>(
                    value: _selectedStatus,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedStatus = newValue!;
                      });
                    },
                    icon: Icon(Icons.keyboard_arrow_down, color: Colors.green),
                    isExpanded: false,
                    style: TextStyle(color: Colors.black, fontSize: 16.0),
                    dropdownColor: Colors.white,
                    items: RideStatus.values.map((status) {
                      return DropdownMenuItem<RideStatus>(
                        value: status,
                        child: Container(
                          child: Row(
                            children: [
                              Text(
                                status.toString().split('.').last,
                                style: TextStyle(color: Colors.black),
                              ),
                              Spacer(),
                              if (status ==
                                  _selectedStatus) // Conditional check for the current selected item
                                Icon(Icons.check,
                                    color: Colors.green, size: 24),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    itemHeight: 48.0,
                    // Add a custom button appearance
                    selectedItemBuilder: (BuildContext context) {
                      return RideStatus.values.map<Widget>((RideStatus status) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          alignment: Alignment.center,
                          child: Text(
                            _selectedStatus.toString().split('.').last,
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Rides Offered Tab
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(_user?.uid)
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

                    List<dynamic>? ridesPublishedIds =
                        userData?['ridesPublished'];
                    print("Rideeee published idsss: $ridesPublishedIds");

                    if (ridesPublishedIds == null ||
                        ridesPublishedIds.isEmpty) {
                      return Center(
                          child: Text(
                        'No rides published',
                        style: TextStyle(fontSize: 16.0),
                      ));
                    }

                    // Retrieve ride details for each ride ID
                    return FutureBuilder(
                      future: _fetchRidesDetails(ridesPublishedIds),
                      builder: (context,
                          AsyncSnapshot<List<Map<String, dynamic>>>
                              ridesSnapshot) {
                        if (ridesSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!ridesSnapshot.hasData ||
                            ridesSnapshot.data!.isEmpty) {
                          return Center(child: Text('No any published rides'));
                        }

                        // Filter rides based on selected status
                        final filteredRides = ridesSnapshot.data!.where((ride) {
                          // Debug statement to print the ride ID
                          print(
                              'Checking ride with ID: ${ride['id']} and status: ${ride['status']}');

                          // Modify this condition as per your ride status logic
                          if (_selectedStatus == RideStatus.Cancelled) {
                            return ride['rideStatus'] == 'Cancelled';
                          } else if (_selectedStatus == RideStatus.Pending) {
                            return ride['rideStatus'] == 'Pending';
                          } else if (_selectedStatus == RideStatus.InProgress) {
                            return ride['rideStatus'] == 'In Progress';
                          } else if (_selectedStatus == RideStatus.Completed) {
                            return ride['rideStatus'] == 'Completed';
                          }

                          // Debug statement to print if the ride does not match any status
                          print('Ride does not match any status');
                          return false;
                        }).toList();

                        print(
                            "FILTEREEEEED RIDEEEES LENGTH: ${filteredRides.length}");

                        // Display filtered rides with details in a list
                        return ListView.builder(
                          itemCount: filteredRides.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> rideData =
                                filteredRides[index];
                            String rideId =
                                rideData['id']; // Get the document ID
                            return _buildPublishedRideCard(rideData, rideId);
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
                      .doc(_user?.uid)
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
                      return const Center(
                          child: Text(
                        'No rides booked',
                        style: TextStyle(fontSize: 16.0),
                      ));
                    }

                    // Retrieve ride details for each ride ID
                    return FutureBuilder(
                      future: _fetchRidesDetails(ridesBookedIds),
                      builder: (context,
                          AsyncSnapshot<List<Map<String, dynamic>>>
                              ridesSnapshot) {
                        if (ridesSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!ridesSnapshot.hasData ||
                            ridesSnapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('No ride details available'));
                        }

                        // Filter rides based on selected status
                        final filteredRides = ridesSnapshot.data!.where((ride) {
                          // Modify this condition as per your ride status logic
                          if (_selectedStatus == RideStatus.Cancelled) {
                            return ride['rideStatus'] == 'Cancelled';
                          } else if (_selectedStatus == RideStatus.Pending) {
                            return ride['rideStatus'] == 'Pending';
                          } else if (_selectedStatus == RideStatus.InProgress) {
                            return ride['rideStatus'] == 'In Progress';
                          }
                          return false;
                        }).toList();

                        // Display filtered rides with details in a list
                        return ListView.builder(
                          itemCount: filteredRides.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> rideData =
                                filteredRides[index];
                            String rideId =
                                rideData['id']; // Get the document ID
                            return _buildBookedRideCard(rideData, rideId);
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchRidesDetails(
      List<dynamic> rideIds) async {
    List<Map<String, dynamic>> ridesDetails = [];

    for (var rideId in rideIds) {
      // Fetch ride details
      print("Fetching ride details for ride ID: $rideId");
      DocumentSnapshot rideSnapshot = await FirebaseFirestore.instance
          .collection('rides')
          .doc(rideId)
          .get();
      if (rideSnapshot.exists) {
        print("Ride with ID $rideId exists");
        // Fetch driver details using driverId from ride details
        String driverId =
            (rideSnapshot.data() as Map<String, dynamic>)['driverId'];
        print("Fetching user details for driver ID: $driverId");
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(driverId)
            .get();
        if (userSnapshot.exists) {
          print("Driver with ID $driverId exists");
          Map<String, dynamic> rideData =
              rideSnapshot.data() as Map<String, dynamic>;
          Map<String, dynamic> userData =
              userSnapshot.data() as Map<String, dynamic>;
          rideData['driverDetails'] =
              userData; // Adding driver details to rideData
          rideData['id'] = rideSnapshot.id;
          ridesDetails.add(rideData);

          print("Added ride details for ride ID: $rideId");
          print("Total rides fetched: ${ridesDetails.length}");
        }
      }
    }
    return ridesDetails;
  }

  Future<void> updateRideLocation(
      String rideId, double newLatitude, double newLongitude) async {
    try {
      final DocumentSnapshot rideTrackingDoc =
          await ridesCollection.doc(rideId).get();

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
    } catch (e) {
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
      double distance = _calculateDistance(
          _previousLatitude, _previousLongitude, newLatitude, newLongitude);

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
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Radius of the earth in meters
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  String encodePolyline(List<LatLng> points) {
    int lastLat = 0;
    int lastLng = 0;
    String result = '';

    for (final point in points) {
      int lat = (point.latitude * 1e5).round();
      int lng = (point.longitude * 1e5).round();

      int dLat = lat - lastLat;
      int dLng = lng - lastLng;

      [dLat, dLng].forEach((value) {
        int shifted = value << 1;
        if (value < 0) shifted = ~shifted;
        int rem = shifted;
        while (rem >= 0x20) {
          result += String.fromCharCode((0x20 | (rem & 0x1f)) + 63);
          rem >>= 5;
        }
        result += String.fromCharCode(rem + 63);
      });

      lastLat = lat;
      lastLng = lng;
    }

    return result;
  }

  Widget _buildPublishedRideCard(Map<String, dynamic> rideData, String rideId) {
    Duration parseDuration(String durationStr) {
      List<String> parts = durationStr.split(' ');
      int hours = 0;
      int minutes = 0;

      for (int i = 0; i < parts.length; i += 2) {
        int value = int.parse(parts[i]);
        if (parts[i + 1] == 'hours' || parts[i + 1] == 'hour') {
          hours = value;
        } else if (parts[i + 1] == 'minutes' || parts[i + 1] == 'minute') {
          minutes = value;
        }
      }

      return Duration(hours: hours, minutes: minutes);
    }

    String formatTime(DateTime time) {
      String period = time.hour < 12 ? 'AM' : 'PM';
      int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
      return "${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period";
    }

    // Parse start time and duration from Firestore document
    DateTime rideStartTime = (rideData['time'] as Timestamp).toDate();
    Duration duration = parseDuration(rideData['rideDuration']);
    DateTime rideEndTime = rideStartTime.add(duration);

    String startingPoint = rideData['pickupCityName'] ?? 'Starting Point';
    String endingPoint = rideData['dropoffCityName'] ?? 'Ending Point';
    double pricePerSeat = rideData['pricePerSeat'] ?? 10;
    DateTime rideDate = (rideData['date'] as Timestamp).toDate();
    String formattedDate = DateFormat('yyyy-MM-dd').format(rideDate);
    List<dynamic> ridePassengers = rideData['passengers'] ?? [];
    List<dynamic> rideRequests = rideData['rideRequests'] ?? [];
    String rideStatus = rideData['rideStatus'] ?? 'None';

    bool isRideCancelled = canceledRideIds.contains(rideId);
    bool isRideStarted = false;

    // Extract driver details
    Map<String, dynamic> driverDetails = rideData['driverDetails'];
    String driverName =
        driverDetails['firstName'] + " " + driverDetails['lastName'] ??
            'Unknown';
    double driverRating = driverDetails['rating'] ?? 0.0;
    int numberOfReviews = driverDetails['numberOfReviews'] ?? 0;

    List<dynamic> polylinePoints = rideData['polylinePoints'];
    List<LatLng> points = polylinePoints
        .map((point) => LatLng(point['latitude'], point['longitude']))
        .toList();
    String encodedPolyline = encodePolyline(points);

    // Create passenger location maps
    List<Map<String, dynamic>> passengers =
        List<Map<String, dynamic>>.from(rideData['passengers']);
    Map<String, LatLng> passengerStartLocations = {};
    Map<String, LatLng> passengerDropLocations = {};

    for (var passenger in passengers) {
      String passengerId = passenger['userId'];
      LatLng startLocation = LatLng(passenger['pickupCoordinate'].latitude,
          passenger['pickupCoordinate'].longitude);
      LatLng dropLocation = LatLng(passenger['dropoffCoordinate'].latitude,
          passenger['dropoffCoordinate'].longitude);

      passengerStartLocations[passengerId] = startLocation;
      passengerDropLocations[passengerId] = dropLocation;
    }

    void _startJourney() async {
      // Update ride status to 'In Progress' in Firestore
      await FirebaseFirestore.instance.collection('rides').doc(rideId).update({
        'rideStatus': 'In Progress',
      });

      // Update UI if necessary
      setState(() {
        // rideStatus = 'In Progress';  // todo checking if working while commented;
        // isRideStarted = true;
        _selectedStatus = RideStatus.InProgress;
      });
    }

    Future<void> sendMultipleRefundRequestEmails(String adminEmail,
        String rideId, List<Map<String, dynamic>> passengers) async {
      String username =
          dotenv.env['EMAIL_USERNAME'] ?? ''; // Load email from .env file
      String password =
          dotenv.env['EMAIL_PASSWORD'] ?? ''; // Load password from .env file

      final smtpServer = gmail(username, password); // Using Gmail SMTP
      final messageBody = StringBuffer();

      messageBody.writeln('Dear Refund Department,');
      messageBody.writeln(
          '\nA request to refund passengers for the canceled ride has been made:');
      messageBody.writeln('\n**Ride Details:**');
      messageBody.writeln('- Ride ID: $rideId');
      messageBody.writeln('\n**Passengers to Refund:**');

      for (var passenger in passengers) {
        String? paymentId = passenger['paymentId'];
        bool paidStatus = passenger['paidStatus'] ?? false;

        // Only consider passengers who have a valid payment ID and have paid
        if (paymentId != null && paidStatus) {
          String email = passenger['email'];
          double amount = passenger['amount'];
          messageBody.writeln('- Passenger Email: $email');
          messageBody.writeln('- Payment ID: $paymentId');
          messageBody.writeln('- Refund Amount: LKR $amount\n');
        }
      }

      messageBody.writeln(
          'Please process these refund requests at your earliest convenience.\n');
      messageBody.writeln('Best Regards,\nLyftMate App Team');

      final message = mailer.Message()
        ..from = mailer.Address(username, 'LyftMate App')
        ..recipients.add(adminEmail) // Add your admin department email
        ..subject = 'Refund Requests for Ride ID: $rideId'
        ..text = messageBody.toString();

      try {
        await mailer.send(message, smtpServer);
        print('Refund request emails sent successfully.');
      } catch (e) {
        print('Failed to send refund request emails: $e');
      }
    }

    void cancelRide() async {
      // Show confirmation dialog
      bool confirmCancel = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Confirm Ride Cancellation',
            style: TextStyle(fontSize: 18.0),
          ),
          content: const Text('Are you sure you want to cancel the ride?'),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(false), // No, do not cancel
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              // Yes, cancel
              child: const Text('Yes'),
            ),
          ],
        ),
      );

      // If user confirms cancellation, cancel the ride
      if (confirmCancel == true) {
        String? adminEmail =
            dotenv.env['ADMIN_EMAIL']; // Replace with the correct admin email
        await sendMultipleRefundRequestEmails(adminEmail!, rideId, passengers);

        await SmsService.notifyPaidPassengersOfRefund(passengers, rideId);

        // Update ride status to 'Cancelled' in Firestore
        await FirebaseFirestore.instance
            .collection('rides')
            .doc(rideId)
            .update({
          'rideStatus': 'Cancelled',
        });
        setState(() {
          // rideStatus = 'Cancelled';
          // canceledRideIds.add(rideId);
          _selectedStatus = RideStatus.Cancelled;
        });
      }
    }

    return GestureDetector(
      onTap: rideData['rideStatus'].toUpperCase() == "COMPLETED"
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MyPublishedRideDetailsPage(rideId: rideId),
                ),
              );
            },
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        elevation: 4.0,
        margin: const EdgeInsets.all(10.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ride ID and Status Chip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Ride No. #$rideId",
                    style:
                        const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                  ),
                  Flexible(
                    child: Chip(
                      label: Text(
                        rideData['rideStatus'].toUpperCase(),
                        style: TextStyle(fontSize: 10),
                      ),
                      backgroundColor:
                          rideData['rideStatus'].toUpperCase() == 'PENDING'
                              ? Colors.orange
                              : rideData['rideStatus'].toUpperCase() ==
                                      'IN PROGRESS'
                                  ? Colors.green
                                  : Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Driver Name and Image
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        NetworkImage(driverDetails['profileImageUrl']),
                    child: driverDetails['profileImageUrl'].isEmpty
                        ? Icon(Icons.person)
                        : null,
                  ),
                  SizedBox(width: 10),
                  Text(
                    driverName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Start and End Locations
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.green),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Start Location",
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 12)),
                              Text(startingPoint),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(formatTime(rideStartTime),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("End Location",
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 12)),
                              Text(endingPoint),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(formatTime(rideEndTime),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
              SizedBox(height: 8),

              // Passengers and Ride Requests
              Row(
                children: [
                  Icon(Icons.people, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'Passengers: ${ridePassengers.length}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  // Show the number of ride requests if available
                  if (rideRequests.isNotEmpty) ...[
                    SizedBox(width: 16), // Adds space between elements
                    Text(
                      'Requests: ${rideRequests.length}',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 10),

              // Ride Date and Price
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEE, d MMM yyyy').format(rideDate),
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'LKR${pricePerSeat.toStringAsFixed(2)} Per Passenger',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ButtonBar(
                alignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Leave Ride Button
                  Visibility(
                    visible:
                        rideStatus != "Cancelled" && rideStatus != "Completed",
                    // visible: rideStatus == "pending" || rideStatus == "In Progress",
                    child: TextButton(
                      onPressed: () {
                        cancelRide();
                      },
                      child: Text('Cancel Ride'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ),
                  // Track Ride Button
                  Visibility(
                    visible:
                        rideStatus != "Cancelled" && rideStatus != "Completed",
                    // visible: rideStatus == "pending" || rideStatus == "In Progress",

                    child: ElevatedButton(
                      onPressed: rideStatus == "Cancelled"
                          ? null
                          : () {
                              // Construct the URL for the Google Maps directions
                              if (rideStatus == "In Progress") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DriverRideTrackingScreen(
                                      // rideId: "A1IxPYLCBhR9JUqPbFhD",
                                      rideId: rideId,
                                      origin: points.first,
                                      destination: points.last,
                                      encodedPolyline: encodedPolyline,
                                      passengerStartLocations:
                                          passengerStartLocations,
                                      passengerDropLocations:
                                          passengerDropLocations,
                                    ),
                                  ),
                                );
                                debugPrint(
                                    "GET DIRECTIONSSSSSSSSSSSSSSSSSSSSSSSSSSS BTN PRESSED");
                              } else {
                                _startJourney();
                              }
                            },
                      style: ButtonStyle(
                        // Set background color to grey when button is disabled
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>((states) {
                          return rideStatus == "Cancelled"
                              ? Colors.grey
                              : Colors.green;
                        }),
                        foregroundColor:
                            MaterialStateProperty.resolveWith<Color?>((states) {
                          return rideStatus == "Cancelled"
                              ? Colors.grey
                              : Colors.white;
                        }),
                      ),
                      child: Text(rideStatus == 'In Progress'
                          ? 'Get Directions'
                          : 'Start Journey'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildBookedRideCard(Map<String, dynamic> rideData, String rideId) {
    Duration parseDuration(String durationStr) {
      List<String> parts = durationStr.split(' ');
      int hours = 0;
      int minutes = 0;

      for (int i = 0; i < parts.length; i += 2) {
        int value = int.parse(parts[i]);
        if (parts[i + 1] == 'hours' || parts[i + 1] == 'hour') {
          hours = value;
        } else if (parts[i + 1] == 'minutes' || parts[i + 1] == 'minute') {
          minutes = value;
        }
      }

      return Duration(hours: hours, minutes: minutes);
    }

    String formatTime(DateTime time) {
      String period = time.hour < 12 ? 'AM' : 'PM';
      int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
      return "${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period";
    }

    // Parse start time and duration from Firestore document
    DateTime rideStartTime = (rideData['time'] as Timestamp).toDate();
    Duration duration = parseDuration(rideData['rideDuration']);

    // Calculate end time by adding duration to start time
    DateTime rideEndTime = rideStartTime.add(duration);

    User? user = FirebaseAuth.instance.currentUser;

    // Replace this with your actual ride data
    String startingPoint = rideData['pickupCityName'] ?? 'Starting Point';
    String endingPoint = rideData['dropoffCityName'] ?? 'Ending Point';
    double pricePerSeat = rideData['pricePerSeat'] ?? 10;
    DateTime rideDate = rideData['date'].toDate();
    String formattedDate = DateFormat('yyyy-MM-dd').format(rideDate);
    TimeOfDay startingTime = TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endingTime = TimeOfDay(hour: 10, minute: 0);
    String rideStatus = rideData['rideStatus'];
    List<dynamic> passengers = rideData['passengers'] ?? [];

    // Extract driver details
    Map<String, dynamic> driverDetails = rideData['driverDetails'];
    String driverName =
        driverDetails['firstName'] + " " + driverDetails['lastName'] ??
            'Unknown';
    double driverRating = driverDetails['rating'] ?? 0.0;
    int numberOfReviews = driverDetails['numberOfReviews'] ?? 0;

    // bool isInProgress = true;

    List<String> pickedUpPassengers =
        List<String>.from(rideData['pickedUpPassengers'] ?? []);
    bool isPickedUp = pickedUpPassengers.contains(user?.uid);

    // Assume 'droppedPassengers' is a list of UIDs who have completed the ride
    List<String> droppedPassengers =
        List<String>.from(rideData['droppedOffPassengers'] ?? []);
    bool isCompleted = droppedPassengers.contains(user?.uid);

    // Set ride status to "Completed" if current user's UID is found in droppedPassengers
    // String rideStatus = isCompleted ? "Completed" : (rideData['rideStatus'] as String).toUpperCase();

    bool isInProgress = rideStatus.toUpperCase() == 'IN PROGRESS';
    bool isPending = rideStatus.toUpperCase() == 'PENDING';

    // Hide buttons if the ride is completed
    bool showButtons = !isCompleted;

    Future<void> sendRefundRequestEmail(
        String adminEmail,
        String passengerEmail,
        String paymentId,
        String rideId,
        double amount) async {
      String username =
          dotenv.env['EMAIL_USERNAME'] ?? ''; // Load email from .env file
      String password =
          dotenv.env['EMAIL_PASSWORD'] ?? ''; // Load password from .env file

      final smtpServer = gmail(username, password); // Using Gmail SMTP
      final message = mailer.Message()
        ..from = mailer.Address(username, 'LyftMate')
        ..recipients.add(adminEmail) // Add your admin department email
        ..subject = 'Refund Request for Passenger $passengerEmail'
        ..text = '''
Dear Refund Department,

We have received a request to refund the following payment for a passenger who has opted to leave the ride:

**Passenger Details:**
- Email: $passengerEmail

**Ride Details:**
- Ride ID: $rideId
- Payment ID: $paymentId
- Refund Amount: LKR $amount

Please review and process this refund request at your earliest convenience.


Best Regards,
LyftMate Team
''';

      try {
        await mailer.send(message, smtpServer);
        print('Refund request email sent successfully.');
      } catch (e) {
        print('Failed to send refund request email: $e');
      }
    }

    void _leaveRide(String adminEmail) async {
      if (user?.uid == null) return;

      // Find the passenger index
      int passengerIndex =
          passengers.indexWhere((p) => p['userId'] == user?.uid);
      if (passengerIndex == -1) return; // Passenger not found

      // Extract the number of seats they had booked
      int seatsToReturn = passengers[passengerIndex]['seats'] as int;
      var passenger = passengers[passengerIndex];

      // Show confirmation dialog
      bool? confirmLeave = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text('Confirm Leave'),
            content: Text('Are you sure you want to leave this ride?'),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(dialogContext).pop(false); // Dismiss the dialog and return false
                },
              ),
              TextButton(
                child: Text('Confirm'),
                onPressed: () {
                  Navigator.of(dialogContext).pop(true); // Dismiss the dialog and return true
                },
              ),
            ],
          );
        },
      );

      // If user does not confirm, stop further execution
      if (confirmLeave != true) return;



      // Check if a refund is needed
      String? paymentId = passenger['paymentId'];
      bool paidStatus = passenger['paidStatus'] ?? false;
      double amount = passenger['amount'] ?? 0.0;

      if (paymentId != null && paidStatus) {
        // Send a refund request email
        await sendRefundRequestEmail(adminEmail, user?.email ?? '', paymentId, rideId, amount);

        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
        if (userDoc.exists) {
          Map<String, dynamic>? userData = userDoc.data();
          String? firstName = userData?['firstName'];
          String? phoneNumber = userData?['phoneNumber'];

          // Check if firstName and phoneNumber are not null
          if (firstName != null && phoneNumber != null) {
            await SmsService.sendRefundNotification(phoneNumber, firstName, amount);
          }
        }
      }

      // Update the local passengers list
      passengers.removeAt(passengerIndex);

      // Firestore transaction to ensure atomic updates
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference rideRef =
            FirebaseFirestore.instance.collection('rides').doc(rideId);
        DocumentReference userRef =
            FirebaseFirestore.instance.collection('users').doc(user?.uid);

        // Get the current state of the ride
        DocumentSnapshot rideSnapshot = await transaction.get(rideRef);
        if (!rideSnapshot.exists) {
          throw Exception("Ride does not exist!");
        }

        // Ensure the data is in the correct format
        Map<String, dynamic> rideData =
            rideSnapshot.data()! as Map<String, dynamic>;

        // Calculate new available seats
        int currentAvailableSeats = rideData['seats'] ?? 0;
        int newAvailableSeats = currentAvailableSeats + seatsToReturn;

        // Update the ride document
        transaction.update(rideRef, {
          'passengers': FieldValue.arrayRemove([passenger]),
          'seats': newAvailableSeats,
        });

        // Update the user document to remove the ride from booked rides
        transaction.update(userRef, {
          'ridesBooked': FieldValue.arrayRemove([rideId])
        });
      });
    }

    Color backgroundColor;
    if (rideStatus.toUpperCase() == "PENDING") {
      backgroundColor = Colors.orangeAccent;
    } else if (rideStatus.toUpperCase() == "IN PROGRESS") {
      backgroundColor = Colors.green;
    } else if (rideStatus.toUpperCase() == "CANCELLED") {
      backgroundColor = Colors.red;
    } else {
      // Default color in case of any other status
      backgroundColor = Colors.grey; // Or any other color you prefer
    }

    return GestureDetector(
        onTap: rideData['rideStatus'].toUpperCase() == "COMPLETED"
        ? null
        : () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MyBookedRidesDetailsPage(rideId: rideId),
        ),
      );
    },
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 4.0,
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Ride No. #$rideId",
                    style:
                    TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                  ),
                  Flexible(
                    // Wrap the Chip with Flexible to prevent overflow
                    child: Chip(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      // Reduce tap target size
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      // Reduce the internal padding
                      label: Text(
                        rideStatus.toUpperCase(),
                        style: TextStyle(fontSize: 10), // Smaller font size
                      ),
                      backgroundColor: rideStatus.toUpperCase() == 'PENDING'
                          ? Colors.orange
                          : rideStatus.toUpperCase() == 'IN PROGRESS'
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero, // Remove padding
              leading: CircleAvatar(
                backgroundImage: NetworkImage(driverDetails['profileImageUrl']),
                child: driverDetails['profileImageUrl'].isEmpty
                    ? Icon(Icons.person)
                    : null,
              ),

              title: Text(driverName),
              // subtitle: Text('${formatTime(rideStartTime)}'),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Start Location",
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12)),
                            Text(startingPoint),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(formatTime(rideStartTime),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.flag, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("End Location",
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12)),
                            Text(endingPoint),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(formatTime(rideEndTime),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Text(formattedDate, style: TextStyle(color: Colors.grey[600])),
                  Text(
                    DateFormat('EEE, d MMM yyyy').format(rideDate),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text('LKR${pricePerSeat.toStringAsFixed(2)} Per Passenger',
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: [
                // Leave Ride Button
                // if (isPending && !isCompleted)
                // // if (isInProgress && !isCompleted)
                //   TextButton(
                //     onPressed: () => _leaveRide(dotenv.env['ADMIN_EMAIL']!),
                //     style: TextButton.styleFrom(foregroundColor: Colors.red),
                //     child: const Text('Leave Ride'),
                //   ),

                // Check if the ride is "PENDING" or "IN PROGRESS," the user isn't picked up, and the ride isn't completed
                if ((isPending || isInProgress) && !isPickedUp && !isCompleted)

                  TextButton(
                    onPressed: () => _leaveRide(dotenv.env['ADMIN_EMAIL']!),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Leave Ride'),
                  ),

                // Track Ride Button
                Visibility(
                  // visible: true,
                  visible: isInProgress && !isCompleted,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                      foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    onPressed: () {
                      // Track ride logic
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RideTrackingPage(
                                rideId: rideId, rideData: rideData)),
                      );
                    },
                    child: const Text('Track Ride'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );

  }
}
