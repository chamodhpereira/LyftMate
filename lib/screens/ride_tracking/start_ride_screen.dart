import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

class StartRideScreen extends StatefulWidget {
  const StartRideScreen({super.key});

  @override
  State<StartRideScreen> createState() => _StartRideScreenState();
}

class _StartRideScreenState extends State<StartRideScreen> {
  Location location = Location();
  TextEditingController rideIDController = TextEditingController();
  String address = "";
  String payment = "";

  String driverName = "";
  String pickupLocationName = "";

  late double customerLatitude;
  late double customerLongitude;
  bool showDeliveryInfo = false;
  bool isDeliveryStarted = false;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // late CollectionReference myridesCollection;
  late CollectionReference myridesTrackingCollection;

  late CollectionReference ridesCollection;

  @override
  void initState() {
    // myridesCollection = firestore.collection('myrides');
    myridesTrackingCollection = firestore.collection('myridesTracking');

    ridesCollection = firestore.collection('rides');
    // _getLocation();
    super.initState();
  }

  Future<DocumentSnapshot?> getRideById(BuildContext context, String rideId) async {
    try {
      if (rideId.isNotEmpty) {
        // Check if rideId is not empty
        DocumentSnapshot documentSnapshot =
        await ridesCollection.doc(rideId).get();
        if (documentSnapshot.exists) {
          print("RIDE WITH RIDE ID $rideId FOUND");
          // Document with given ID found
          return documentSnapshot;
        } else {
          // Handle case where ride with given ID is not found
          print('Ride with rideId $rideId not found');
          return null;
        }
      } else {
        // Handle case where rideId is empty
        print('Empty rideId');
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to fetch ride details: $e'),
      ));
      return null;
    }

  }

  // late Geolocator _geolocator;
  //
  // @override
  // void initState() {
  //   super.initState();
  //   _geolocator = Geolocator();
  // }

  // void _startLocationTracking({required String rideId, required Function(double, double) onUpdateLocation}) {
  //   var locationOptions = LocationOptions(
  //     accuracy: LocationAccuracy.high,
  //     distanceFilter: 10, // Update location every 10 meters
  //   );
  //
  //   _geolocator.getPositionStream(locationOptions).listen((position) {
  //     onUpdateLocation(position.latitude, position.longitude);
  //   });
  // }


  Future<void> _getLocation() async {   // no need if we already got location permission
    try {
      bool serviceEnabled = await location.serviceEnabled();
      if(!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if(!serviceEnabled) {
          return;
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if(permissionGranted == PermissionStatus.denied){
        permissionGranted = await location.requestPermission();
        if(permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      LocationData locationData = await location.getLocation();
      print("current location: $locationData");
    } catch (e) {
      print(e);
    }
  }


  Future<void> addRideTracking(String rideId, double latitude, double longitude) async {
    try {
      await myridesTrackingCollection.doc(rideId).set({
        'rideId': rideId,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': DateTime.now(),
      });
      print('Ride tracking added for rideId $rideId');
    } catch (e) {
      print('Failed to add ride tracking: $e');
    }
  }

  // Future<void> updateOrderLocation(String rideId, double newLatitude, double newLongitude) async{
  //   try{
  //     final DocumentSnapshot rideTrackingDoc = await myridesTrackingCollection.doc(rideId).get();
  //
  //     //check if doc with ride id exists:
  //     if(rideTrackingDoc.exists) {
  //       //update the exising doc
  //       await myridesTrackingCollection.doc(rideId).update({
  //         'latitude': newLatitude,
  //         'longitude': newLongitude,
  //       });
  //     } else {
  //       // create a new one
  //       await addRideTracking(rideId, newLatitude, newLongitude);
  //     }
  //   } catch(e) {
  //     print("error updating in update order loc method $e");
  //   }
  //
  // }

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


// updatessss everytime the user moves -- to0 many write operations
  // void _subscribeToLocationChanges() {
  //   location.onLocationChanged.listen((LocationData currentLocation) {
  //     print("Location changed: ${currentLocation}");
  //     updateRideLocation(rideIDController.text, currentLocation.latitude ?? 0, currentLocation.longitude ?? 0);
  //   });
  //   location.enableBackgroundMode(enable: true);
  // }

  double _previousLatitude = 0;
  double _previousLongitude = 0;

  void _subscribeToLocationChanges() {
    location.onLocationChanged.listen((LocationData currentLocation) {
      double newLatitude = currentLocation.latitude ?? 0;
      double newLongitude = currentLocation.longitude ?? 0;

      // Calculate the distance between the new and previous locations
      double distance = _calculateDistance(_previousLatitude, _previousLongitude, newLatitude, newLongitude);

      // Update Firestore only if the distance exceeds a certain threshold (e.g., 100 meters)
      if (distance >= 1000) {
        print("Location changed: ${currentLocation}");
        updateRideLocation(rideIDController.text, newLatitude, newLongitude);

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

// Function to convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }


  // FUNCTION: START RIDE
  void _startDelivery() {
    setState(() {
      isDeliveryStarted = true;
    });

    if(isDeliveryStarted) {
      _subscribeToLocationChanges();
      // addRideTracking(rideIDController.text, customerLatitude, customerLongitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dboy"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Enter Ride ID:"),
            const SizedBox(
              height: 8,
            ),
            TextField(
              controller: rideIDController,
              decoration: const InputDecoration(
                hintText: "Ride Id",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Visibility(
              visible: !showDeliveryInfo,
              child: ElevatedButton(
                onPressed: () async {
                  DocumentSnapshot? ride =
                  await getRideById(context, rideIDController.text);
                  print(ride);
                  if (ride != null) {
                    Map<String, dynamic>? rideData =
                    ride.data() as Map<String, dynamic>?;
                    setState(() {
                      driverName = rideData?['userId'] ?? "";
                      pickupLocationName = rideData?['pickupLocationName'] ?? "";
                      // address = rideData?['address'] ?? "";
                      // payment = rideData?['payment'] ?? "";
                      // customerLongitude = rideData?['longitude'];
                      // customerLatitude = rideData?['latitude'];

                      showDeliveryInfo = true;
                    });
                  }
                },
                child: Text("Submit"),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Visibility(
              visible: showDeliveryInfo,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("Customer Name: $driverName"),
                  SizedBox(
                    height: 8,
                  ),
                  Text("Pick up location: $pickupLocationName"),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {  // TODO: Fix this google map laucher
                          launchUrl(Uri.parse('https://www.google.com/maps?q=$customerLatitude,$customerLongitude'));
                        },
                        child: Text("Show Location"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _startDelivery();
                        },
                        child: Text("Start Delivery"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
