import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

import '../../services/emergency/emergency_service.dart';
import '../reviews/reviews_screen.dart';


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

  late CollectionReference ridesCollection;
  late bool isPickedUp = false;
  late bool isDroppedOff = false;
  bool hasShownDialog = false;
  late double remainingDistance = 0;
  late String eta = "";
  late Timer timer;

  LatLng userPickUpLocation = const LatLng(0.0, 0.0);
  LatLng userDropOffLocation = const LatLng(0.0, 0.0);
  LatLng rideLocation = const LatLng(7.631710245699606, 80.60172363425474);
  List<LatLng> _polylinePoints = [];
  List<Polyline> _polylines = [];

  User? _user;
  String? userFirstName;

  GoogleMapController? mapController;
  BitmapDescriptor driverMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
  BitmapDescriptor userMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);


  FirebaseFirestore firestore = FirebaseFirestore.instance;

  StreamSubscription<DocumentSnapshot>? rideStreamSubscription;

  String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  final client = Client();

  String _getApiKey() {
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'YOUR_DEFAULT_API_KEY';
  }

  @override
  void initState() {
    _getCurrentUser();
    ridesCollection = firestore.collection('rides');
    startTracking(widget.rideId);
    extractPolylinePoints();
    drawPolyline();

    //subscribe to locatin changes
    // Geolocator.getPositionStream(
    //   locationSettings:
    //       LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 10),
    // ).listen((Position position) {
    //   updateCurrentLocation(position);
    // });
    super.initState();
  }

  @override
  void dispose() {
    rideStreamSubscription?.cancel();
    super.dispose();
  }



  Future<void> startTracking(String rideId) async {
    debugPrint("start tracking ride with ride id: $rideId");

    rideStreamSubscription =
        ridesCollection.doc(rideId).snapshots().listen((snapshot) {
          if (snapshot.exists) {
            // var trackingData = snapshot.data();
            Map<String, dynamic>? trackingData =
            snapshot.data() as Map<String, dynamic>?;
            if (trackingData != null) {

              extractRideData(trackingData);

              GeoPoint geoPoint = trackingData['rideLocation'];
              LatLng rideLocation = LatLng(geoPoint.latitude, geoPoint.longitude);
              updateUIWithLocation(rideLocation);
              debugPrint("THISSS THE CURRENT RIDE UPDATE BY STREANNNMMMM LOCATION: $rideLocation");
            } else {
              debugPrint("No tracking data available");
            }
          }
        });
  }

  void extractRideData(Map<String, dynamic> trackingData) {
    debugPrint("THIS IS RIDE DATA: $trackingData");

    // GeoPoint geoPointUserPickUp = widget.rideData["pickupLocation"]["geopoint"]; // ride start
    // GeoPoint geoPointUserDropOff = widget.rideData["dropoffLocation"]["geopoint"]; // ride end

    // Find the index of the current user within the passengers array
    int userIndex = trackingData['passengers'].indexWhere((passenger) => passenger['userId'] == currentUserId);

    // If the user is found in the passengers array
    if (userIndex != -1) {

      // Extract pickupCoordinate and dropoffCoordinate for the user
      GeoPoint pickupGeoPoint = trackingData['passengers'][userIndex]['pickupCoordinate'];
      GeoPoint dropoffGeoPoint = trackingData['passengers'][userIndex]['dropoffCoordinate'];

      // Convert GeoPoint to LatLng
      userPickUpLocation = LatLng(pickupGeoPoint.latitude, pickupGeoPoint.longitude);
      userDropOffLocation = LatLng(dropoffGeoPoint.latitude, dropoffGeoPoint.longitude);

    } else {
      debugPrint('Current user not found in passengers array');
    }



    GeoPoint geoPointRideLocation = trackingData["rideLocation"];

    isPickedUp = trackingData['pickedUpPassengers'].contains(currentUserId);
    isDroppedOff = trackingData['droppedOffPassengers'].contains(currentUserId);
    debugPrint("Is user picked up: $isPickedUp");
    debugPrint("Is user dropped off: $isDroppedOff");

    // Show a dialog if the passenger has been dropped off
    if (isDroppedOff && !hasShownDialog) {
      hasShownDialog = true;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Ride Ended"),
            content: const Text("Your ride has ended. Thank you for using LyftMate!"),
            actions: [
              TextButton(
                child: const Text("OK"),
                // onPressed: () {
                //   Navigator.of(context).pop();
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(builder: (context) => ReviewsScreen(rideId: widget.rideId,)),
                //   );
                // },
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ReviewsScreen(rideId: widget.rideId)),
                  );
                },
              ),
            ],
          );
        },
      );
    }

    // userPickUpLocation = LatLng(geoPointUserPickUp.latitude, geoPointUserPickUp.longitude);
    // userDropOffLocation = LatLng(geoPointUserDropOff.latitude, geoPointUserDropOff.longitude);

    // rideLocation = LatLng(0, 0);
    setState(() {
      rideLocation = LatLng(geoPointRideLocation.latitude, geoPointRideLocation.longitude);
    });


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
      polylineId: const PolylineId('polyline'),
      color: Colors.blue,
      width: 3,
      points: _polylinePoints,
    );

    setState(() {
      _polylines.add(polyline);
    });
  }

  void addCustomMarker() {
    ImageConfiguration configuration = const ImageConfiguration(size: Size(0, 0), devicePixelRatio: 5);

    BitmapDescriptor.fromAssetImage(configuration, 'assets/images/your-image')
        .then((value) {
      setState(() {
        driverMarkerIcon = value;
      });
    });
  }

  void calculateRemainingDistance() {
    double distance = 0.0;

    if (isPickedUp) {
      // If the passenger is picked up, calculate distance from ride location to dropoff location
      distance = Geolocator.distanceBetween(
        rideLocation.latitude,
        rideLocation.longitude,
        userDropOffLocation.latitude,
        userDropOffLocation.longitude,
      );
    } else {
      // If the passenger is not picked up yet, calculate distance from ride location to pickup location
      distance = Geolocator.distanceBetween(
        rideLocation.latitude,
        rideLocation.longitude,
        userPickUpLocation.latitude,
        userPickUpLocation.longitude,
      );
    }

    double distanceInKm = distance / 1000;

    setState(() {
      remainingDistance = distanceInKm;
    });
  }

  Future<void> calculateETA() async {

    String url;
    final apiKey = _getApiKey();

    if (isPickedUp){
      url = "https://maps.googleapis.com/maps/api/directions/json?origin=${rideLocation.latitude},${rideLocation.longitude}&destination=${userDropOffLocation.latitude},${userDropOffLocation.longitude}&key=$apiKey";
    } else {
      url =
      "https://maps.googleapis.com/maps/api/directions/json?origin=${rideLocation.latitude},${rideLocation.longitude}&destination=${userPickUpLocation.latitude},${userPickUpLocation.longitude}&key=$apiKey";
    }

    var response = await client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      String duration = data["routes"][0]["legs"][0]["duration"]["text"];
      setState(() {
        eta = duration;
      });
    } else {
      debugPrint("Error occurred when calculating ETA");
    }
  }


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
          debugPrint('User firstName from Firestore: $userFirstName');
          // Now you can use the firstName as needed
        } else {
          debugPrint('User document does not exist');
        }
      } catch (error) {
        debugPrint('Error fetching user document: $error');
      }
    } else {
      debugPrint('No user logged in');
    }
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
      debugPrint("Error retrieving tracking info: $e");
      return null;
    }
  }

  // void showArrivalPopup() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("Delivery/Ride Arrival"),
  //         content: Text("Your delivery/ride is here!"),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text("OK"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void updateUIWithLocation(LatLng driverLocation) {
    setState(() {
      rideLocation = driverLocation;
    });

    mapController?.animateCamera(CameraUpdate.newLatLng(rideLocation));

    calculateRemainingDistance();
    calculateETA();


    // Check if ride is near user's location
    double distanceToUser = Geolocator.distanceBetween(
        rideLocation.latitude,
        rideLocation.longitude,
        userDropOffLocation.latitude,
        userDropOffLocation.longitude,
    );

    // Assuming a threshold of 100 meters for arrival
    // if (distanceToUser <= 1000) {   // TODO: Arrival popup fix
    //   showArrivalPopup();
    // }
  }


  // void _showEmergencyOptions() {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Padding(
  //         padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 0.0), // Adjust padding as needed
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             ListTile(
  //               leading: const Icon(Icons.bolt, size: 40.0,),
  //               minLeadingWidth: 0,
  //               horizontalTitleGap: 0,
  //               title: const Text('Send SOS'),
  //               onTap: () {
  //                 // Implement SOS functionality
  //                 EmergencyService.sendSOS(userFirstName!);
  //                 Navigator.pop(context);
  //               },
  //               subtitle: const Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text("Send SOS to your emergency contacts"),
  //                 ],
  //               ),
  //             ),
  //             ListTile(
  //               leading: const Icon(Icons.share, size: 35.0,),
  //               minLeadingWidth: 0,
  //               horizontalTitleGap: 10,
  //               title: const Text('Share Ride Details'),
  //               onTap: () {
  //                 // Implement share ride details functionality
  //                 EmergencyService.shareRideDetails(widget.rideId);
  //                 Navigator.pop(context);
  //               },
  //               subtitle: const Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text("Share ride details with your emergency contacts"),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
  void _showEmergencyOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.bolt, size: 40.0,),
                minLeadingWidth: 0,
                horizontalTitleGap: 0,
                title: const Text('Send SOS'),
                onTap: () async {
                  Navigator.pop(context);
                  // Implement SOS functionality
                  bool success = await EmergencyService.sendSOS(userFirstName!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'SOS sent successfully!' : 'Failed to send SOS.'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                },
                subtitle: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Send SOS to your emergency contacts"),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.share, size: 35.0,),
                minLeadingWidth: 0,
                horizontalTitleGap: 10,
                title: const Text('Share Ride Details'),
                onTap: () async {
                  Navigator.pop(context);
                  // Implement share ride details functionality
                  bool success = await EmergencyService.shareRideDetails(widget.rideId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Ride details shared successfully!' : 'Failed to share ride details.'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
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
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Track Ride Location"),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          elevation: 0.5,
          actions: [
            IconButton(
              icon: const Icon(Icons.warning, color: Colors.yellowAccent),
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
                    markerId: const MarkerId('my-destination'),
                    position: userDropOffLocation,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue),
                    infoWindow: const InfoWindow(
                      title: "My Drop-off Location ",
                      // snippet: 'LatLng - $userDropOffLocation',
                    )),
                Marker(
                    markerId: const MarkerId('my-pickup'),
                    position: userPickUpLocation,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue),
                    infoWindow: const InfoWindow(
                      title: "My Pickup Location",
                      // snippet: 'LatLng - $userPickUpLocation',
                    )),
                Marker(
                    markerId: const MarkerId('driver'),
                    position: rideLocation,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueOrange),
                    // icon: markerIcon  to add custom marker
                    infoWindow: const InfoWindow(
                      title: "Driver Location",
                      // snippet: 'LatLng - $rideLocation',
                    )),
              },
              polylines: Set<Polyline>.of(_polylines),
              padding: const EdgeInsets.only(bottom: 180.0),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 180,
                child: Container(
                  // padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 16.0),
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30.0),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Remaining Distance ${isPickedUp ? 'to destination' : 'to pickup'}: ${remainingDistance.toStringAsFixed(2)} km",
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Estimated Time of Arrival: $eta",
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              // top: 580,
              bottom: screenHeight * 0.15,
              right: 10,
              child: Container(
                width: 80,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.navigation_sharp,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
  }
}