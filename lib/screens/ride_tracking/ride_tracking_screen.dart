import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../services/emergency/emergency_service.dart';


class RideTrackingPage extends StatefulWidget {
  final String rideId;
  final Map<String, dynamic> rideData;

  const RideTrackingPage(
      {super.key, required this.rideId, required this.rideData});

  @override
  State<RideTrackingPage> createState() => _RideTrackingPageState();
}

class _RideTrackingPageState extends State<RideTrackingPage> {
  // LatLng destination = LatLng(37.4220604, -122.0852343);
  // LatLng deliBoyLocation = LatLng(37.4220604, -122.0852343);

  late LatLng userPickUpLocation;
  late LatLng userDropOffLocation;
  late LatLng rideLocation;
  List<LatLng> _polylinePoints = [];

  List<Polyline> _polylines = [];

  GoogleMapController? mapController;
  BitmapDescriptor markerIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late CollectionReference ridesCollection;

  late double remainingDistance = 0;

  late Timer timer;

  void extractRideData() {
    // Assuming rideData contains necessary information such as pickup and dropoff locations
    // Replace these lines with the actual keys from your rideData map
    GeoPoint geoPointUserPickUp = widget.rideData["pickupLocation"]["geopoint"]; // ride start
    GeoPoint geoPointUserDropOff = widget.rideData["dropoffLocation"]["geopoint"]; // ride end
    GeoPoint geoPointRideLocation = widget.rideData["rideLocation"]["geopoint"];


    userPickUpLocation =
        LatLng(geoPointUserPickUp.latitude, geoPointUserPickUp.longitude); // ride data

    userDropOffLocation =
        LatLng(geoPointUserDropOff.latitude, geoPointUserDropOff.longitude);

    rideLocation =
        LatLng(geoPointRideLocation.latitude, geoPointRideLocation.longitude);

  }

  void extractPolylinePoints() {
    List<dynamic> polylineData = widget.rideData['polylinePoints'];
    _polylinePoints = polylineData.map((point) {
      double latitude = point['latitude'];
      double longitude = point['longitude'];
      return LatLng(latitude, longitude);
    }).toList();
  }

  void drawPolyline() {
    Polyline polyline = Polyline(
      polylineId: PolylineId('polyline'),
      color: Colors.blue,
      width: 3,
      points: _polylinePoints,
    );

    setState(() {
      _polylines.add(polyline);
    });
  }

  void addCustomMarker() {
    ImageConfiguration configuration =
        ImageConfiguration(size: Size(0, 0), devicePixelRatio: 5);

    BitmapDescriptor.fromAssetImage(configuration, 'assets/images/your-image')
        .then((value) {
      setState(() {
        markerIcon = value;
      });
    });
  }

  //func to update the current location - user location
  // void updateCurrentLocation(Position position) {
  //   setState(() {
  //     destination = LatLng(position.latitude, position.longitude);
  //   });
  // }

  // void updateDeliBoyLocation(Position position) {
  //   setState(() {
  //     deliBoyLocation = LatLng(position.latitude, position.longitude);
  //   });
  //
  //   mapController?.animateCamera(CameraUpdate.newLatLng(deliBoyLocation));
  //
  //   //calcuate remaining distance
  //   calculateRemainingDistance();
  // }

  //func to calculate remaining distance
  void calculateRemainingDistance() {
    double distance = Geolocator.distanceBetween(
      // deliBoyLocation.latitude,
      // deliBoyLocation.longitude,
      // destination.latitude,
      // destination.longitude,

      rideLocation.latitude,
      rideLocation.longitude,
      userDropOffLocation.latitude,
      userDropOffLocation.longitude,

    );

    double distanceInKm = distance / 1000;

    setState(() {
      remainingDistance = distanceInKm;
    });
  }

  User? _user;
  String? userFirstName;



  Future<void> _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
      });

      // Access Firestore to get user document
      try {
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          // Get firstName field from user document
          userFirstName = userDoc.get('firstName');
          print('UserRRRRRRRR NAMAAAAAAAAAPAGOTTTTTTTTT firstName: $userFirstName');
          // Now you can use the firstName as needed
        } else {
          print('User document does not exist');
        }
      } catch (error) {
        print('Error fetching user document: $error');
      }
    } else {
      print('No user logged in');
    }
  }

  @override
  void initState() {
    _getCurrentUser();
    ridesCollection = firestore.collection('rides');

    extractRideData();
    // addCustomMarker();
    // startTracking("12345");
    startTracking(widget.rideId);
    // startTracking("l8fYgKPy10HoxjuAdwnO");

    extractPolylinePoints(); // Call extractPolylinePoints() here
    drawPolyline(); // Call drawPolyline() here

    //subscribe to locatin changes
    // Geolocator.getPositionStream(
    //   locationSettings:
    //       LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 10),
    // ).listen((Position position) {
    //   updateCurrentLocation(position);
    // });
    super.initState();
  }

  StreamSubscription<DocumentSnapshot>? rideStreamSubscription;

  Future<void> startTracking(String rideId) async {
    print("start tracking beforeeee awaaaait calleddddd $rideId");

    rideStreamSubscription =
        ridesCollection.doc(rideId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        // var trackingData = snapshot.data();
        Map<String, dynamic>? trackingData =
            snapshot.data() as Map<String, dynamic>?;
        if (trackingData != null) {
          // Map<String, dynamic> locationData = trackingData['rideLocation'];
          // GeoPoint geoPoint = trackingData['rideLocation']['geopoint'];
          // LatLng rideLocation = LatLng(geoPoint.latitude, geoPoint.longitude);
          GeoPoint geoPoint = trackingData['rideLocation']['geopoint'];
          LatLng rideLocation = LatLng(geoPoint.latitude, geoPoint.longitude);
          updateUIWithLocation(rideLocation);
          print(
              "THISSS IT THE CURRENT RIDE UPDATE BY STREANNNMMMM LOCATION: $rideLocation");
        } else {
          print("No tracking data available");
        }
      }
    });
  }

// Stop listening for updates when no longer needed
  void stopTracking() {
    rideStreamSubscription?.cancel();
  }

  Future<Map<String, dynamic>?> getRideTracking(String rideId) async {
    try {
      var snapshot = await ridesCollection.doc(rideId).get();

      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print("Error retrieving order tracking info: $e");
      return null;
    }
  }

  void showArrivalPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delivery/Ride Arrival"),
          content: Text("Your delivery/ride is here!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void updateUIWithLocation(LatLng driverLocation) {
    setState(() {
      // deliBoyLocation = LatLng(latitude, longitude);
      rideLocation = driverLocation;
    });

    mapController?.animateCamera(CameraUpdate.newLatLng(rideLocation));

    calculateRemainingDistance();

    // Check if delivery boy is near user's location
    double distanceToUser = Geolocator.distanceBetween(
      // deliBoyLocation.latitude,
      // deliBoyLocation.longitude,
      // destination.latitude,
      // destination.longitude,
        rideLocation.latitude,
        rideLocation.longitude,
        userDropOffLocation.latitude,
        userDropOffLocation.longitude,
    );

    // Assuming a threshold of 100 meters for arrival
    if (distanceToUser <= 1000) {
      showArrivalPopup();
    }
  }

  ////// dispose as well

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    // timer.cancel();
    super.dispose();
  }

  void _showEmergencyOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 0.0), // Adjust padding as needed
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.bolt, size: 40.0,),
                  minLeadingWidth: 0,
                  horizontalTitleGap: 0,
                  title: Text('Send SOS'),
                  onTap: () {
                    // Implement SOS functionality
                    EmergencyService.sendSOS(userFirstName!);
                    Navigator.pop(context);
                  },
                  subtitle: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Send SOS to your emergency contacts"),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.share, size: 35.0,),
                  minLeadingWidth: 0,
                  horizontalTitleGap: 10,
                  title: Text('Share Ride Details'),
                  onTap: () {
                    // Implement share ride details functionality
                    EmergencyService.shareRideDetails(widget.rideId);
                    Navigator.pop(context);
                  },
                  subtitle: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Share ride details with your emergency contacts"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    print("THIS IS THE USERRRR: $_user");
    print(
        "Thisssssssssi ssss the paseeddd ride id for trackingggg ${widget.rideId}");

    return Scaffold(
      appBar: AppBar(
        title: Text("Track Ride Location"),
        actions: [
          IconButton(
            icon: Icon(Icons.warning),
            onPressed: _showEmergencyOptions,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: rideLocation,
              zoom: 15.0,
            ),
            onMapCreated: (controller) {
              mapController = controller;
            },
            markers: {
              Marker(
                  markerId: MarkerId('destination'),
                  position: userDropOffLocation,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue),
                  infoWindow: InfoWindow(
                    title: "destination",
                    snippet: 'LatLng - $userDropOffLocation',
                  )),
              Marker(
                  markerId: const MarkerId('driver'),
                  position: rideLocation,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueOrange),
                  // icon: markerIcon  to add custom marker
                  infoWindow: InfoWindow(
                    title: "ride",
                    snippet: 'LatLng - $rideLocation',
                  )),
            },
            polylines: Set<Polyline>.of(_polylines),
          ),
          Positioned(
            top: 16.0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                // child: Text("ETA"),
                child: Text(
                  "Remaining Distance: ${remainingDistance.toStringAsFixed(2)} kilometers",
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
