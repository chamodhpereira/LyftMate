import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';

class GPXMapScreen extends StatefulWidget {
  final String rideId;
  final LatLng origin;
  final LatLng destination;
  final String encodedPolyline;
  final Map<String, LatLng> passengerStartLocations;
  final Map<String, LatLng> passengerDropLocations;

  const GPXMapScreen({
    Key? key,
    required this.origin,
    required this.destination,
    required this.encodedPolyline,
    required this.passengerStartLocations,
    required this.passengerDropLocations,
    required this.rideId,
  }) : super(key: key);

  @override
  _GPXMapScreenState createState() => _GPXMapScreenState();
}

class _GPXMapScreenState extends State<GPXMapScreen> {
  Location location = Location();
  final client = Client();

  late GoogleMapController mapController;
  Set<Marker> markers = {};
  Set<String> removedMarkerIds = {};
  Set<Polyline> polylines = {};

  bool isRidePaused = false;
  int currentMarkerIndex = 0;
  late LatLng currentRideLocation;
  LatLng? rideRideLocation;
  bool isNearPassenger = false;
  bool markersAdded = false; // Track if markers are added
  Map<String, String> passengerNameCache = {};

  @override
  void initState() {
    currentRideLocation = widget.origin;

    // _setRoute();
    _fetchRideLocation();
    _subscribeToLocationChanges();
    super.initState();
  }

  // void _getCurrentLocation() {
  //   Geolocator.getPositionStream(accuracy: LocationAccuracy.best).listen((Position position) {
  //     setState(() {
  //       currentLocation = LatLng(position.latitude, position.longitude);
  //     });
  //   });
  // }

  double _previousLatitude = 0;
  double _previousLongitude = 0;

  void _subscribeToLocationChanges() {
    // location.onLocationChanged.listen((LocationData currentLocation) {
    //   print("LOCATIONNNNNNNNNNN changed: ${currentLocation}");
    //   // updateOrderLocation(rideIDController.text, currentLocation.latitude ?? 0, currentLocation.longitude ?? 0);
    // });
    // location.enableBackgroundMode(enable: true);

    location.onLocationChanged.listen((LocationData currentLocation) {
      double newLatitude = currentLocation.latitude ?? 0;
      double newLongitude = currentLocation.longitude ?? 0;

      /// later change this
      if (mounted) {
        setState(() {
          currentRideLocation = LatLng(newLatitude, newLongitude);
        });
      }

      // Calculate the distance between the new and previous locations
      /// not workingggggggggggggggggggggggggggggggggg
      double distance = calculateDistance(
          LatLng(_previousLatitude, _previousLongitude),
          LatLng(newLatitude, newLongitude));

      distanceToClosestMarker();

      print("DISTANCEEEEEEIN SUBSSSSCRIPTION: $distance");

      // Update Firestore only if the distance exceeds a certain threshold (e.g., 100 meters)
      if (distance >= 10) {
        print("Location changed: ${currentLocation}");
        // updateRideLocation(rideId, newLatitude, newLongitude);

        // Update previous location data
        _previousLatitude = newLatitude;
        _previousLongitude = newLongitude;
      }
    });

    location.enableBackgroundMode(enable: true);
  }

  // void _subscribeToLocationChanges(String rideId) {
  //
  // }

  double calculateDistance(LatLng origin, LatLng destination) {
    double distance = Geolocator.distanceBetween(
      currentRideLocation.latitude,
      currentRideLocation.longitude,
      destination.latitude,
      destination.longitude,
    );
    double distanceInKm = distance / 1000;
    return distanceInKm;
  }

  // Function to get passenger details from Firestore or cache
  Future<String> getPassengerName(String passengerId) async {
    // Check if passenger name is already cached
    if (passengerNameCache.containsKey(passengerId)) {
      print("Passenger name found in cache.");
      return passengerNameCache[passengerId]!;
    } else {
      print("Passenger name not found in cache. Fetching from Firestore...");
      try {
        DocumentSnapshot passengerSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(passengerId)
            .get();

        if (passengerSnapshot.exists) {
          var passengerData = passengerSnapshot.data() as Map<String, dynamic>;
          if (passengerData != null) {
            // Extract first name and last name
            String firstName = passengerData['firstName'];
            String lastName = passengerData['lastName'];
            // Concatenate first name and last name
            String fullName = '$firstName $lastName';
            // Cache the passenger name
            passengerNameCache[passengerId] = fullName;
            print("Passenger name fetched from Firestore and cached.");
            return fullName;
          }
        }
      } catch (error) {
        print("Error fetching passenger details: $error");
      }
      print(
          "Passenger details not found in Firestore. Returning empty string.");
      return ''; // Return empty string if details not found or error occurs
    }
  }

  bool firstDistanceCheck = true;

  Future<dynamic> distanceToClosestMarker() async {
    double minDistance = double.infinity;
    String closestMarkerId = '';

    // Find the current marker
    Marker? currentMarker;
    for (final marker in markers) {
      // Skip the origin marker
      if (marker.markerId.value == 'origin') {
        continue;
      }

      final LatLng markerLocation = marker.position;
      final double distance =
      calculateDistance(currentRideLocation, markerLocation);
      if (distance < minDistance) {
        minDistance = distance;
        closestMarkerId = marker.markerId.value;
        currentMarker = marker;
      }
    }

    print('Closest Marker ID: $closestMarkerId');
    print("DISTANCE TO MARKER: $minDistance");

    // Check if the current location is within 500m of the closest marker
    if (firstDistanceCheck) {
      if (minDistance <= 0.5) {
        print("INSIDEEEE FIRST DISTCANCEEE CHECK");
        setState(() {
          isNearPassenger = true;
          firstDistanceCheck = false;
        });
        print("CLOSER TO LOCATIONNNNNN");


        // Call the Cloud Function to trigger notification
        // try {
        //   final response = await client.post(
        //     Uri.parse('https://triggernotification-uy4aafhtka-uc.a.run.app'),
        //     body: {
        //       'rideId': 'A1IxPYLCBhR9JUqPbFhD',
        //       'passengerId': '1J9taKGJwSgxroIC72ALVHTjRzG3',
        //     },
        //   );
        //
        //   if (response.statusCode == 200) {
        //     print("RESPONSEEEE: $response");
        //     print('Notification triggered successfully WTTTOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO');
        //   } else {
        //     print('Failed to trigger notification');
        //   }
        // } catch (error) {
        //   print('Error triggering notification: $error');
        // }

      }
    }

    if (closestMarkerId.startsWith('start_')) {
      String passengerId = closestMarkerId
          .split('_')
          .last;
      String passengerName = await getPassengerName(
          passengerId); // firebase call
      // String passengerName = "ALex";
      return {
        'text': 'Pick up $passengerName',
        'distance': minDistance,
        'markerId': closestMarkerId,
      };
    } else if (closestMarkerId.startsWith('drop_')) {
      String passengerId = closestMarkerId
          .split('_')
          .last;
      String passengerName = await getPassengerName(passengerId);
      // String passengerName = "ALex";
      return {
        'text': 'Drop $passengerName',
        'distance': minDistance,
        'markerId': closestMarkerId,
      };
    }

    // Return just the distance if no special condition is met
    return minDistance;
  }

  void removeMarker(String markerId) {
    markers.removeWhere((marker) => marker.markerId.value == markerId);
    removedMarkerIds.add(markerId); // Add the removed marker ID to the set
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _pauseRide() {
    setState(() {
      isRidePaused = true;
    });
  }

  void _resumeRide() {
    setState(() {
      isRidePaused = false;
    });
  }

  Future<void> _setRoute() async {
    // Fetch picked up passengers from Firestore
    List<String> pickedUpPassengers = [];
    try {
      DocumentSnapshot rideSnapshot = await FirebaseFirestore.instance
          .collection('rides')
          .doc(widget.rideId)
          .get();

      if (rideSnapshot.exists) {
        var rideData = rideSnapshot.data() as Map<String, dynamic>;
        if (rideData != null && rideData.containsKey('pickedUpPassengers')) {
          pickedUpPassengers =
          List<String>.from(rideData['pickedUpPassengers']);
        }
      }
      print("PICKEDDD UP PASSSENGERSSSS: $pickedUpPassengers");
    } catch (error) {
      print("Error fetching picked up passengers: $error");
      // Handle error
    }


    // Set the origin and destination markers
    markers.add(Marker(
      markerId: MarkerId('origin'),
      position: widget.origin,
      infoWindow: InfoWindow(title: 'Origin'),
    ));
    markers.add(Marker(
      markerId: MarkerId('destination'),
      position: widget.destination,
      infoWindow: InfoWindow(title: 'Destination'),
    ));

    // markers.add(Marker(
    //   markerId: MarkerId('start_123434325'),
    //   position: LatLng(7.217229661572721, 79.84983189322291),
    //   infoWindow: InfoWindow(title: 'Destination'),
    // ));

    // Add passenger start and drop locations as markers
    // widget.passengerStartLocations.forEach((passengerId, startLocation) {
    //   markers.add(Marker(
    //     markerId: MarkerId('start_$passengerId'),
    //     position: startLocation,
    //     infoWindow: InfoWindow(title: 'Start Location'),
    //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    //   ));
    // });

    widget.passengerStartLocations.forEach((passengerId, startLocation) {
      if (!pickedUpPassengers.contains(passengerId)) {
        markers.add(Marker(
          markerId: MarkerId('start_$passengerId'),
          position: startLocation,
          infoWindow: InfoWindow(title: 'Start Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen),
        ));
      }
    });

    widget.passengerDropLocations.forEach((passengerId, dropLocation) {
      markers.add(Marker(
        markerId: MarkerId('drop_$passengerId'),
        position: dropLocation,
        infoWindow: InfoWindow(title: 'Drop Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    });

    // Set the polyline
    polylines.add(Polyline(
      polylineId: PolylineId('route'),
      visible: true,
      points: _convertToLatLng(_decodePolyline(widget.encodedPolyline)),
      width: 5,
      color: Colors.blue,
    ));
  }

  List<LatLng> _convertToLatLng(List<PointLatLng> points) {
    return points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
  }

  List<PointLatLng> _decodePolyline(String encoded) {
    // Decoding the polyline: Implement or use an existing method
    return PolylinePoints().decodePolyline(encoded);
  }

  void _fetchRideLocation() async {
    try {
      DocumentSnapshot rideSnapshot = await FirebaseFirestore.instance
          .collection('rides')
          .doc(widget.rideId)
          .get();

      if (rideSnapshot.exists) {
        var rideData = rideSnapshot.data() as Map<String, dynamic>;
        if (rideData != null) {
          // Extract ride location
          var geopoint = rideData['rideLocation']['geopoint'];
          double latitude = geopoint.latitude;
          double longitude = geopoint.longitude;
          setState(() {
            rideRideLocation = LatLng(latitude, longitude);
            currentRideLocation = rideRideLocation!;
          });
        }
      }
    } catch (error) {
      print("Error fetching ride location: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!markersAdded) {
      _setRoute(); // Add markers only once when the widget is built
      markersAdded = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Map Route"),
        actions: [
          IconButton(
            icon: Icon(Icons.pause),
            onPressed: isRidePaused ? null : _pauseRide,
          ),
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: isRidePaused ? _resumeRide : null,
          ),
          IconButton(
            icon: Icon(Icons.map),
            onPressed: _openGoogleMaps,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: widget.origin,
              zoom: 14.0,
            ),
            markers: markers,
            polylines: polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onCameraMove: (CameraPosition position) {
              currentRideLocation = position.target;
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 200,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   'Distance to Closest Marker:',
                    //   style: TextStyle(fontWeight: FontWeight.bold),
                    // ),
                    SizedBox(height: 30.0),
                    FutureBuilder<dynamic>(
                      future: distanceToClosestMarker(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          if (snapshot.data is Map<String, dynamic>) {
                            // If the data is a map (which contains both text and distance)
                            final Map<String, dynamic> data =
                            snapshot.data as Map<String, dynamic>;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if(!isNearPassenger) ... [
                                  Text(
                                    '${data['text']}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    '${data['distance'].toStringAsFixed(2)} km',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ] else ... [
                                  Text(
                                    'Waiting for passenger...',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],


                                SizedBox(height: 16.0),
                                Visibility(
                                  visible: isNearPassenger,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceEvenly,
                                    children: [
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              // Handle picking up or dropping the passenger based on marker ID
                                              String markerId = data['markerId'];
                                              if (markerId.startsWith(
                                                  'start_')) {
                                                print(
                                                    "Pickinnnnnnnnnnnnnnnnnnnnng uppppppppp passsaaaa");
                                                // Handle picking up the passenger

                                                String passengerId = markerId
                                                    .split('_')
                                                    .last;
                                                print(
                                                    'Picking up passenger with ID: $passengerId');

                                                // Update the Firestore document
                                                try {
                                                  await FirebaseFirestore.instance.collection('rides').doc(widget.rideId).
                                                  update({'pickedUpPassengers': FieldValue.arrayUnion([passengerId]),});
                                                  print('Passenger ID added to pickedUpPassengers array in Firestore');
                                                } catch (error) {
                                                  print(
                                                      'Error updating Firestore document: $error');
                                                  // Handle error
                                                }
                                              } else if (markerId.startsWith(
                                                  'drop_')) {
                                                // Handle dropping the passenger
                                                print(
                                                    "Droppingggg offfffff passsaaaa");
                                              }


                                              // Remove the current marker from the set of markers
                                              // markers.removeWhere((marker) => marker.markerId.value == markerId);
                                              removeMarker(markerId);
                                              setState(() {
                                                isNearPassenger = false;
                                              });
                                              // Calculate distance to the next closest marker
                                              distanceToClosestMarker();
                                            },
                                            child: Text('Continue'),
                                          ),
                                          SizedBox(width: 50,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Container(
                                                width: 50,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: IconButton(
                                                    icon: Icon(Icons
                                                        .notification_add_outlined,
                                                      color: Colors.black,),
                                                    onPressed: () {
                                                      // Handle call button press
                                                    },
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10,),
                                              Container(
                                                width: 50,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: IconButton(
                                                    icon: Icon(
                                                      Icons.mail_outlined,
                                                      color: Colors.black,),
                                                    onPressed: () {
                                                      // Handle call button press
                                                    },
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10,),
                                              Container(
                                                width: 50,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: IconButton(
                                                    icon: Icon(
                                                      Icons.call_outlined,
                                                      color: Colors.black,),
                                                    onPressed: () {
                                                      // Handle call button press
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          } else {
                            // If the data is just the distance
                            return Text(
                              '${snapshot.data!.toStringAsFixed(2)} km',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            );
                          }
                        }
                      },
                    ),

                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 555, // Adjust this value as needed to position the circle
            right: 10, // Adjust this value as needed to position the circle
            child: Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Center(
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

  void _openGoogleMaps() async {
    // Encode the parameters
    String origin = Uri.encodeComponent(
        '${widget.origin.latitude},${widget.origin.longitude}');
    String destination = Uri.encodeComponent(
        '${widget.destination.latitude},${widget.destination.longitude}');
    List<String> waypoints = widget.passengerStartLocations.values
        .followedBy(widget.passengerDropLocations.values)
        .map((location) =>
        Uri.encodeComponent('${location.latitude},${location.longitude}'))
        .toList();

    // Construct URL
    // String url = 'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&waypoints=${waypoints.join('|')}&travelmode=driving&dir_action=navigate';
    String url =
        'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&waypoints=${waypoints
        .join('|')}&travelmode=driving&dir_action=navigate';

    // Launch URL
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Use Flutter's in-built widgets to show the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Could not launch Google Maps. Please check your connection or app settings.'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }
//
}

class PassengerDetailsWidget extends StatelessWidget {
  final String passengerName;
  final double distance;
  final bool isNearPassenger;

  const PassengerDetailsWidget({
    Key? key,
    required this.passengerName,
    required this.distance,
    required this.isNearPassenger,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              children: [
                Text(
                  'Passenger Name: $passengerName',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.0),
                Text(
                  'Distance to Closest Marker: ${distance.toStringAsFixed(
                      2)} km',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Visibility(
                  visible: isNearPassenger,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Handle picking up or dropping the passenger
                      // based on marker ID
                      // Implement your logic here
                    },
                    child: Text('Continue'),
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.error_outline),
              onPressed: () {
                // Handle alert button press
              },
            ),
            IconButton(
              icon: Icon(Icons.mail),
              onPressed: () {
                // Handle DM button press
              },
            ),
            IconButton(
              icon: Icon(Icons.call),
              onPressed: () {
                // Handle call button press
              },
            ),
          ],
        ),
      ],
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class GPXMapScreen extends StatefulWidget {
//   final LatLng origin;
//   final LatLng destination;
//   final String encodedPolyline;
//   final Map<String, LatLng> passengerStartLocations;
//   final Map<String, LatLng> passengerDropLocations;
//
//   const GPXMapScreen({
//     Key? key,
//     required this.origin,
//     required this.destination,
//     required this.encodedPolyline,
//     required this.passengerStartLocations,
//     required this.passengerDropLocations,
//   }) : super(key: key);
//
//   @override
//   _GPXMapScreenState createState() => _GPXMapScreenState();
// }
//
// class _GPXMapScreenState extends State<GPXMapScreen> {
//   late GoogleMapController mapController;
//   Set<Marker> markers = {};
//   Set<Polyline> polylines = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _setRoute();
//   }
//
//   void _setRoute() {
//     // Set the origin and destination markers
//     markers.add(Marker(
//       markerId: MarkerId('origin'),
//       position: widget.origin,
//       infoWindow: InfoWindow(title: 'Origin'),
//     ));
//     markers.add(Marker(
//       markerId: MarkerId('destination'),
//       position: widget.destination,
//       infoWindow: InfoWindow(title: 'Destination'),
//     ));
//
//     // Add passenger start and drop locations as markers
//     widget.passengerStartLocations.forEach((passengerId, startLocation) {
//       markers.add(Marker(
//         markerId: MarkerId('start_$passengerId'),
//         position: startLocation,
//         infoWindow: InfoWindow(title: 'Start Location'),
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//       ));
//     });
//
//     widget.passengerDropLocations.forEach((passengerId, dropLocation) {
//       markers.add(Marker(
//         markerId: MarkerId('drop_$passengerId'),
//         position: dropLocation,
//         infoWindow: InfoWindow(title: 'Drop Location'),
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//       ));
//     });
//
//     // Set the polyline
//     polylines.add(Polyline(
//       polylineId: PolylineId('route'),
//       visible: true,
//       points: _convertToLatLng(_decodePolyline(widget.encodedPolyline)),
//       width: 5,
//       color: Colors.blue,
//     ));
//   }
//
//   List<LatLng> _convertToLatLng(List<PointLatLng> points) {
//     return points
//         .map((point) => LatLng(point.latitude, point.longitude))
//         .toList();
//   }
//
//   List<PointLatLng> _decodePolyline(String encoded) {
//     // Decoding the polyline: Implement or use an existing method
//     return PolylinePoints().decodePolyline(encoded);
//   }
//
//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//   }
//
//   // void _openGoogleMaps() async {
//   //   // Construct the Google Maps URL with origin, destination, and waypoints
//   //   String origin = '${widget.origin.latitude},${widget.origin.longitude}';
//   //   String destination =
//   //       '${widget.destination.latitude},${widget.destination.longitude}';
//   //   List<String> waypoints = [];
//   //
//   //   widget.passengerStartLocations.forEach((_, startLocation) {
//   //     waypoints.add('${startLocation.latitude},${startLocation.longitude}');
//   //   });
//   //
//   //   widget.passengerDropLocations.forEach((_, dropLocation) {
//   //     waypoints.add('${dropLocation.latitude},${dropLocation.longitude}');
//   //   });
//   //
//   //   String url = 'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&waypoints=${waypoints.join('|')}&travelmode=driving&dir_action=drive';
//   //
//   //   // Launch Google Maps
//   //   if (await canLaunch(url)) {
//   //     await launch(url);
//   //   } else {
//   //     throw 'Could not launch $url';
//   //   }
//   // }
//
//   void _openGoogleMaps() async {
//     // Encode the parameters
//     String origin = Uri.encodeComponent('${widget.origin.latitude},${widget.origin.longitude}');
//     String destination = Uri.encodeComponent('${widget.destination.latitude},${widget.destination.longitude}');
//     List<String> waypoints = widget.passengerStartLocations.values.followedBy(widget.passengerDropLocations.values)
//         .map((location) => Uri.encodeComponent('${location.latitude},${location.longitude}'))
//         .toList();
//
//     // Construct URL
//     // String url = 'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&waypoints=${waypoints.join('|')}&travelmode=driving&dir_action=navigate';
//     String url = 'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&waypoints=${waypoints.join('|')}&travelmode=driving&dir_action=navigate';
//
//     // Launch URL
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       // Use Flutter's in-built widgets to show the error message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Could not launch Google Maps. Please check your connection or app settings.'),
//           duration: Duration(seconds: 5),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Map Route"),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.map),
//             onPressed: _openGoogleMaps,
//           ),
//         ],
//       ),
//       body: GoogleMap(
//         onMapCreated: _onMapCreated,
//         initialCameraPosition: CameraPosition(
//           target: widget.origin,
//           zoom: 14.0,
//         ),
//         markers: markers,
//         polylines: polylines,
//       ),
//     );
//   }
// }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// class GPXMapScreen extends StatefulWidget {
//   final LatLng origin;
//   final LatLng destination;
//   final String encodedPolyline;
//
//   const GPXMapScreen({Key? key, required this.origin, required this.destination, required this.encodedPolyline}) : super(key: key);
//
//   @override
//   _GPXMapScreenState createState() => _GPXMapScreenState();
// }
//
// class _GPXMapScreenState extends State<GPXMapScreen> {
//   late GoogleMapController mapController;
//   Set<Marker> markers = {};
//   Set<Polyline> polylines = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _setRoute();
//   }
//
//   void _setRoute() {
//     // Set the markers
//     markers.add(Marker(
//       markerId: MarkerId('origin'),
//       position: widget.origin,
//       infoWindow: InfoWindow(title: 'Origin'),
//     ));
//     markers.add(Marker(
//       markerId: MarkerId('destination'),
//       position: widget.destination,
//       infoWindow: InfoWindow(title: 'Destination'),
//     ));
//
//     // Set the polyline
//     polylines.add(Polyline(
//       polylineId: PolylineId('route'),
//       visible: true,
//       points: _convertToLatLng(_decodePolyline(widget.encodedPolyline)),
//       width: 5,
//       color: Colors.blue,
//     ));
//   }
//
//   List<LatLng> _convertToLatLng(List<PointLatLng> points) {
//     return points.map((point) => LatLng(point.latitude, point.longitude)).toList();
//   }
//
//   List<PointLatLng> _decodePolyline(String encoded) {
//     // Decoding the polyline: Implement or use an existing method
//     return PolylinePoints().decodePolyline(encoded);
//   }
//
//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     print("Encoded Polyline: ${widget.encodedPolyline}");
//     print("");
//     print("");
//     List<PointLatLng> decodedPOLY = _decodePolyline(widget.encodedPolyline);
//     print("DECODEDDDD $decodedPOLY");
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Map Route"),
//       ),
//       body: GoogleMap(
//         onMapCreated: _onMapCreated,
//         initialCameraPosition: CameraPosition(
//           target: widget.origin,
//           zoom: 14.0,
//         ),
//         markers: markers,
//         polylines: polylines,
//       ),
//     );
//   }
// }
