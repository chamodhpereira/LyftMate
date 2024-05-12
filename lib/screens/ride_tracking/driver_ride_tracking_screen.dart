import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:collection/collection.dart';

import '../chat/dash_chatpage.dart';
import '../reviews/passenger_review_screen.dart';
import '../reviews/reviews_screen.dart';

class DriverRideTrackingScreen extends StatefulWidget {
  final String rideId;
  final LatLng origin;
  final LatLng destination;
  final String encodedPolyline;
  final Map<String, LatLng> passengerStartLocations;
  final Map<String, LatLng> passengerDropLocations;

  const DriverRideTrackingScreen({
    Key? key,
    required this.origin,
    required this.destination,
    required this.encodedPolyline,
    required this.passengerStartLocations,
    required this.passengerDropLocations,
    required this.rideId,
  }) : super(key: key);

  @override
  DriverRideTrackingScreenState createState() => DriverRideTrackingScreenState();
}

class DriverRideTrackingScreenState extends State<DriverRideTrackingScreen> {

  final client = Client();
  Location location = Location();

  late StreamSubscription<LocationData>? _locationSubscription;
  late CollectionReference ridesCollection;
  LatLng currentRideLocation = LatLng(7.6208296949485055, 80.72228593307872);

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Set<Marker> markers = {};
  Set<String> removedMarkerIds = {};
  Set<Polyline> polylines = {};
  Set<String> notifiedPassengers = {};

  GoogleMapController? mapController; // Make nullable to handle initialization
  bool mapControllerInitialized = false; // Track if the map controller is initialized

  Map<String, String> passengerNameCache = {};
  Map<String, Map<String, String>> passengerDetailsCache = {};

  LatLng? rideRideLocation;

  bool isRidePaused = false;
  bool nearPassengerLocation = false;
  bool firstDistanceCheck = true;
  bool isNearPassengerPickup = false;
  bool isNearPassengerDropoff = false;
  bool markersAdded = false; // Track if markers are added
  bool isDataReady = false;

  int currentMarkerIndex = 0;
  double _previousLatitude = 0;
  double _previousLongitude = 0;


  @override
  void initState() {
    // currentRideLocation = widget.origin;
    ridesCollection = firestore.collection('rides');
    // debugPrint("CURRENT RIDE LOC IN INIT STATE: $currentRideLocation");

    // _previousLatitude = currentRideLocation.latitude;
    // _previousLongitude = currentRideLocation.longitude;

    // _setRoute();
    _fetchRideLocation();
    _subscribeToLocationChanges();
    super.initState();
  }

  @override
  void dispose() {
    _cancelLocationSubscription();
    super.dispose();
  }



  void _subscribeToLocationChanges() {
    _locationSubscription =
        location.onLocationChanged.listen((LocationData currentLocation) {
      double newLatitude = currentLocation.latitude ?? 0;
      double newLongitude = currentLocation.longitude ?? 0;

      // Calculate the distance between the new and previous locations
      double distance = calculateDistance(
          LatLng(_previousLatitude, _previousLongitude),
          LatLng(newLatitude, newLongitude));

      if(distance >= 0.2) {
        if (mounted) {
          setState(() {
            currentRideLocation = LatLng(newLatitude, newLongitude);
            debugPrint("CUREEEENT RIDE LOC IN STATEEEEEE: $currentRideLocation");
            markers.removeWhere((marker) => marker.markerId.value == 'current');
            markers.add(Marker(
              markerId: const MarkerId('current'),
              position: currentRideLocation,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              infoWindow: const InfoWindow(title: 'Current Location'),
            ));
            debugPrint("***********************************************************");
            debugPrint("Caaaaalinnnnnggg distance to marker when distance >= 0.2");
            distanceToClosestMarker();
          });

          // Move the camera to the current location only if the map controller is initialized
          mapController?.animateCamera(CameraUpdate.newLatLng(currentRideLocation));
        }
      }
      debugPrint("DISTANCEEEEEEIN SUBSSSSCRIPTION: $distance");

      // Update Firestore only if the distance exceeds a certain threshold (200 meters)
      if (distance >= 0.2) {
        debugPrint("Location change triggered: $currentLocation");

        updateRideLocation(widget.rideId, newLatitude, newLongitude);

        // Update previous location data
        _previousLatitude = newLatitude;
        _previousLongitude = newLongitude;
      }
    });

    location.enableBackgroundMode(enable: true);
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapControllerInitialized = true; // Set the flag to true
  }


  void _cancelLocationSubscription() {
    if (_locationSubscription != null) {
      _locationSubscription?.cancel();
      _locationSubscription = null;
    }
  }

  Future<void> updateRideLocation(
      String rideId, double newLatitude, double newLongitude) async {
    try {
      final DocumentSnapshot ride = await ridesCollection.doc(rideId).get();

      // Check if doc with ride id exists:
      if (ride.exists) {
        // Update the existing doc
        await ridesCollection.doc(rideId).update({
          'rideLocation': GeoPoint(newLatitude, newLongitude),
        });

        debugPrint("Updated ride location in ride Document $rideId");
      } else {
        // Create a new one
        debugPrint("NOOOOOOOOOOOO DOCSSSSSSS FOUNF WITH ID $rideId");
        // await addRideTracking(rideId, newLatitude, newLongitude);
      }
    } catch (e) {
      debugPrint("Error updating in update order loc method: $e");
    }
  }

  double calculateDistance(LatLng origin, LatLng destination) {
    double distance = Geolocator.distanceBetween(
      origin.latitude,
      origin.longitude,
      destination.latitude,
      destination.longitude,
    );
    double distanceInKm = distance / 1000;
    return distanceInKm;
  }



  Future<String> getPassengerDetails(String passengerId, String dataType) async {
    // Check if passenger details are already cached
    if (passengerDetailsCache.containsKey(passengerId)) {
      debugPrint("Passenger details found in cache.");
      return passengerDetailsCache[passengerId]![dataType] ?? '';
    } else {
      debugPrint("Passenger details not found in cache. Fetching from Firestore...");
      try {
        DocumentSnapshot passengerSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(passengerId)
            .get();

        if (passengerSnapshot.exists) {
          var passengerData = passengerSnapshot.data() as Map<String, dynamic>;
          if (passengerData != null) {
            // Extract required data based on dataType
            String result = '';
            switch (dataType) {
              case 'name':
                String firstName = passengerData['firstName'] ?? '';
                String lastName = passengerData['lastName'] ?? '';
                result = '$firstName $lastName';
                break;
              case 'email':
                result = passengerData['email'] ?? '';
                break;
            }
            // Cache the passenger details
            passengerDetailsCache[passengerId] = {
              'name': result,
              'email': passengerData['email'] ?? '',
            };
            debugPrint("Passenger details fetched from Firestore and cached.");
            return result;
          }
        }
      } catch (error) {
        debugPrint("Error fetching passenger details: $error");
      }
      debugPrint("Passenger details not found in Firestore. Returning empty string.");
      return ''; // Return empty string if details not found or error occurs
    }
  }

  bool allPassengersDroppedOff() {
    // Check if all drop-off actions are completed, by checking a list of active drop-offs
    return !markers.any((m) =>
        m.markerId.value.startsWith('drop_') &&
        !removedMarkerIds.contains(m.markerId.value));
  }

  Future<dynamic> distanceToClosestMarker() async {
    double minDistance = double.infinity;
    String closestMarkerId = '';
    Marker? currentMarker;

    // Iterate through all markers to find the closest actionable marker
    for (final marker in markers) {
      if (marker.markerId.value == 'origin') {
        continue; // Skip the origin marker
      }

      final LatLng markerLocation = marker.position;
      final double distance = calculateDistance(currentRideLocation, markerLocation);

      // Check if the marker is actionable and closer than any previously considered markers
      if ((marker.markerId.value.startsWith('drop_') || marker.markerId.value.startsWith('start_')) && distance < minDistance && !removedMarkerIds.contains(marker.markerId.value)) {
        minDistance = distance;
        closestMarkerId = marker.markerId.value;
        currentMarker = marker;
      }
    }

    debugPrint("Currrreeeeeeeeeeeeeeent rideeee locationnnnnn in distancetomarker method: $currentRideLocation");

    // If no actionable markers are closer or all passengers are dropped off, consider the destination
    if (closestMarkerId.isEmpty || allPassengersDroppedOff()) {
      Marker? destinationMarker = markers.firstWhereOrNull((m) => m.markerId.value == 'destination');
      if (destinationMarker != null) {
        final double distance = calculateDistance(currentRideLocation, destinationMarker.position);
        if (distance < minDistance) {
          minDistance = distance;
          closestMarkerId = destinationMarker.markerId.value;
          currentMarker = destinationMarker;
        }
      }
    }

    // Prepare the response based on the closest marker and distance
    if (closestMarkerId.isEmpty) {
      return {'text': 'No marker nearby', 'distance': double.infinity};
    } else {
      // Check if the current location is within 1 km of the closest marker
      if (minDistance <= 1) {
        // Determine if the subtext should be included
        String? subtext;
        if (minDistance <= 0.5) {
          // Provide specific subtext if within 0.5 km
          switch (closestMarkerId.split('_').first) {
            case 'start':
              subtext = 'Confirm passenger boarding.';
              break;
            case 'drop':
              subtext = 'Confirm passenger departure.';
              break;
          }
        }

        // Determine marker type
        String markerType = closestMarkerId.split('_').first;
        String passengerId = closestMarkerId.split('_').last;
        String passengerName = await getPassengerDetails(passengerId, 'name');
        String passengerEmail = await getPassengerDetails(passengerId, 'email');

        // Trigger notification for relevant markers if within a certain distance
        if (markerType == 'start'  && minDistance <= 1 && !notifiedPassengers.contains(passengerId)) {
          await triggerNotification(passengerId);
          notifiedPassengers.add(passengerId); // Ensure the notification is not sent repeatedly
        }

        switch (markerType) {
          case 'start':
            return {
              'text': 'Arriving at $passengerName\'s pickup location.',
              'subtext': subtext,
              'distance': minDistance,
              'markerId': closestMarkerId,
              'passengerId': passengerId,
              'passengerEmail': passengerEmail,
            };
          case 'drop':
            return {
              'text': 'Arriving at $passengerName\'s drop-off location.',
              'subtext': subtext,
              'distance': minDistance,
              'markerId': closestMarkerId,
              'passengerId': passengerId,
              'passengerEmail': passengerEmail,
            };
          case 'destination':
            return {
              'text': 'End Trip',
              'distance': minDistance,
              'markerId': closestMarkerId,
            };
          default:
            return {
              'text': 'En Route',
              'distance': minDistance,
              'markerId': closestMarkerId,
            };
        }
      } else {
        // Return text and distance for the closest marker if not within 1 km
        return prepareResponseForMarker(currentMarker, minDistance);
      }
    }
  }




  Future<void> triggerNotification(String passengerId) async {
    if (!notifiedPassengers.contains(passengerId)) {
      debugPrint("Triggering notification for $passengerId");

      // Mark the passenger as notified to prevent multiple triggers.
      notifiedPassengers.add(passengerId);

      try {
        final response = await client.post(
            Uri.parse('https://triggernotification-uy4aafhtka-uc.a.run.app'),
            body: {
              'rideId': widget.rideId,
              'passengerId': passengerId,
            },
        );
        if (response.statusCode == 200) {
          debugPrint('Notification triggered successfully');
          notifiedPassengers.add(passengerId);
        } else {
          debugPrint('Failed to trigger notification: ${response.body}');
          notifiedPassengers.remove(passengerId);
        }
      } catch (error) {
        debugPrint('Error triggering notification: $error');
        notifiedPassengers.remove(passengerId);
      }
    } else {
      debugPrint("Notification already sent for $passengerId");
    }
  }

  Future<Map<String, dynamic>> prepareResponseForMarker(
      Marker? marker, double distance) async {
    // Prepare response for any marker not within immediate proximity
    if (marker == null) {
      return {'text': 'No marker nearby', 'distance': distance};
    }

    String markerType = marker.markerId.value.split('_').first;
    String passengerId = marker.markerId.value.split('_').last;
    String passengerName = await getPassengerDetails(passengerId, 'name');
    String passengerEmail = await getPassengerDetails(passengerId, 'email');

    switch (markerType) {
      case 'drop':
        return {
          'text': 'Drop off $passengerName',
          'distance': distance,
          'markerId': marker.markerId.value
        };
      case 'start':
        return {
          'text': 'Pick up $passengerName',
          'distance': distance,
          'markerId': marker.markerId.value
        };
      case 'destination':
        return {
          'text': 'En route to destination',
          'distance': distance,
          'markerId': marker.markerId.value
        };
      default:
        return {
          // 'text': '',
          'text': 'En route',
          'distance': distance,
          'markerId': marker.markerId.value
        };
    }
  }

  void removeMarker(String markerId) {
    markers.removeWhere((marker) => marker.markerId.value == markerId);
    removedMarkerIds.add(markerId); // Add the removed marker ID to the set
  }

  // void _onMapCreated(GoogleMapController controller) {
  //   mapController = controller;
  // }

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
    // Fetch picked up and dropped off passengers from Firestore
    List<String> pickedUpPassengers = [];
    List<String> droppedOffPassengers = [];
    try {
      DocumentSnapshot rideSnapshot = await FirebaseFirestore.instance
          .collection('rides')
          .doc(widget.rideId)
          .get();

      if (rideSnapshot.exists) {
        var rideData = rideSnapshot.data() as Map<String, dynamic>;
        if (rideData != null && rideData.containsKey('pickedUpPassengers')) {
          pickedUpPassengers = List<String>.from(rideData['pickedUpPassengers']);
        }
        if (rideData != null && rideData.containsKey('droppedOffPassengers')) {
          droppedOffPassengers = List<String>.from(rideData['droppedOffPassengers']);
        }
      }
      debugPrint("PICKEDDD UP PASSSENGERSSSS: $pickedUpPassengers");
    } catch (error) {
      debugPrint("Error fetching picked up passengers: $error");
    }

    // Set the origin and destination markers
    markers.add(Marker(
      markerId: const MarkerId('origin'),
      position: widget.origin,
      infoWindow: const InfoWindow(title: 'Origin'),
    ));
    markers.add(Marker(
      markerId: const MarkerId('destination'),
      position: widget.destination,
      infoWindow: const InfoWindow(title: 'Destination'),
    ));


    widget.passengerStartLocations.forEach((passengerId, startLocation) {
      if (!pickedUpPassengers.contains(passengerId)) {
        markers.add(Marker(
          markerId: MarkerId('start_$passengerId'),
          position: startLocation,
          infoWindow: const InfoWindow(title: 'Pickup Location'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ));
      }
    });

    widget.passengerDropLocations.forEach((passengerId, dropLocation) {
      if (!droppedOffPassengers.contains(passengerId)) {
        markers.add(Marker(
          markerId: MarkerId('drop_$passengerId'),
          position: dropLocation,
          infoWindow: const InfoWindow(title: 'Drop Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ));
      }
    });

    // Set the polyline
    polylines.add(Polyline(
      polylineId: const PolylineId('route'),
      visible: true,
      points: _convertToLatLng(_decodePolyline(widget.encodedPolyline)),
      width: 5,
      color: Colors.blue,
    ));

    if (markers.isNotEmpty) {
      // await distanceToClosestMarker();  // Make sure this updates something or checks distance
      setState(() {
        isDataReady = true;  // Indicate that data is ready
      });
    }
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

  // void _fetchRideLocation() async {
  //   try {
  //     DocumentSnapshot rideSnapshot = await FirebaseFirestore.instance
  //         .collection('rides')
  //         .doc(widget.rideId)
  //         .get();
  //
  //     if (rideSnapshot.exists) {
  //       var rideData = rideSnapshot.data() as Map<String, dynamic>;
  //       if (rideData != null) {
  //         // Extract ride location
  //         var geopoint = rideData['rideLocation']['geopoint'];
  //         double latitude = geopoint.latitude;
  //         double longitude = geopoint.longitude;
  //         setState(() {
  //           rideRideLocation = LatLng(latitude, longitude);
  //           currentRideLocation = rideRideLocation!;
  //         });
  //         debugPrint("CUREEENT RIDE LOC IN DEBUG: $currentRideLocation");
  //       }
  //     }
  //   } catch (error) {
  //     debugPrint("Error fetching ride location: $error");
  //   }
  // }


  void _fetchRideLocation() async {
    try {
      DocumentSnapshot rideSnapshot = await FirebaseFirestore.instance
          .collection('rides')
          .doc(widget.rideId)
          .get();

      if (rideSnapshot.exists) {
        var rideData = rideSnapshot.data() as Map<String, dynamic>;
        GeoPoint geopoint = rideData['rideLocation']; // Retrieve the GeoPoint directly
        double latitude = geopoint.latitude;
        double longitude = geopoint.longitude;
        setState(() {
          rideRideLocation = LatLng(latitude, longitude);
          currentRideLocation = rideRideLocation!;
        });
        debugPrint("Current Ride Location: $currentRideLocation");
      }
    } catch (error) {
      debugPrint("Error fetching ride location: $error");
    }
  }

  void handlePassengerPickup(String markerId) {
    String passengerId = markerId.split('_').last;
    debugPrint('Picking up passenger with ID: $passengerId');
    try {
      FirebaseFirestore.instance.collection('rides').doc(widget.rideId).update({
        'pickedUpPassengers': FieldValue.arrayUnion([passengerId])
      });
      debugPrint('Passenger ID added to pickedUpPassengers array in Firestore');
    } catch (error) {
      debugPrint('Error updating Firestore document: $error');
    }
  }

  void handlePassengerDropoff(String markerId) {
    String passengerId = markerId.split('_').last;
    debugPrint('Dropping off passenger with ID: $passengerId');
    try {
      FirebaseFirestore.instance.collection('rides').doc(widget.rideId).update({
        'droppedOffPassengers': FieldValue.arrayUnion([passengerId])
      });
      debugPrint('Passenger ID added to droppedOffPassengers array in Firestore');
    } catch (error) {
      debugPrint('Error updating Firestore document: $error');
    }
  }

  void updateNearPassengerLocation(bool value) {
    setState(() {
      nearPassengerLocation = value;
      firstDistanceCheck = false;
    });
  }


  Future<void> updateRideStatus(String rideId, String newStatus) async {
    try {
      // Reference to the ride document
      DocumentReference rideRef = FirebaseFirestore.instance.collection('rides').doc(rideId);

      // Update the ride status
      await rideRef.update({'rideStatus': newStatus});
    } catch (e) {
      debugPrint('Error updating ride status: $e');
      rethrow; // Rethrow the error to handle it in the UI
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
        title: const Text("Trip Route"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.pause),
          //   onPressed: isRidePaused ? null : _pauseRide,
          // ),
          // IconButton(
          //   icon: const Icon(Icons.play_arrow),
          //   onPressed: isRidePaused ? _resumeRide : null,
          // ),
          IconButton(
            icon: const Icon(Icons.map),
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
            // myLocationEnabled: true,
            myLocationButtonEnabled: true,
            // onCameraMove: (CameraPosition position) {
            //   currentRideLocation = position.target;
            // },
            padding: EdgeInsets.only(top: 10.0 ,bottom: nearPassengerLocation ? 260.0 : 180.0),
            // padding: EdgeInsets.only(bottom: 250.0),
          ),
          if(isDataReady) Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              // height: 200,   ------------- original height
              // height: 180,
              height: nearPassengerLocation ? 265 : 180,
              // height: 250,
              child: Container(
                // padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 16.0),
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                color: Colors.white,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   'Distance to Closest Marker:',
                      //   style: TextStyle(fontWeight: FontWeight.bold),
                      // ),
                      const SizedBox(height: 30.0),
                      FutureBuilder<dynamic>(
                        future: distanceToClosestMarker(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            if (snapshot.data is Map<String, dynamic>) {
                              final Map<String, dynamic> data = snapshot.data as Map<String, dynamic>;
                              // final bool isNearPassenger = data['distance'] < 0.5 && data['markerId'] != null && (data['markerId'].startsWith('start_') || data['markerId'].startsWith('drop_') || data['markerId'].startsWith('destination') );

                              final bool isNearPassenger = (data['distance'] < 0.5 && data['markerId'] != null &&
                                  (data['markerId'].startsWith('start_') ||
                                      data['markerId'].startsWith('drop_'))) ||
                                  (data['markerId'] == 'destination');

                              if (isNearPassenger) {
                                debugPrint("MARKEERRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR ${data['markerId']}");
                                debugPrint("MARKEERRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR ${data['distance']}");
                                if(firstDistanceCheck) {
                                  // Update the state if near passenger
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    updateNearPassengerLocation(true);
                                  });
                                }
                              }
                              // else {
                              //   // Update the state if not near passenger
                              //   WidgetsBinding.instance!.addPostFrameCallback((_) {
                              //     updateNearPassengerLocation(false);
                              //   });
                              // }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${data['text']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0),
                                  ),
                                  SizedBox(height: isNearPassenger ? 3 : 12,),
                                  if (data['subtext'] != null) ...[
                                    Text(
                                      '${data['subtext']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0),
                                    ),
                                  ],
                                  SizedBox(height: isNearPassenger ? 3 : 12,),
                                  // Text(
                                  //   'Distance to ${data['markerId'] != null && data['markerId'].startsWith('start_') ? 'pickup' : 'dropoff'}: ${data['distance'].toStringAsFixed(2)} km',
                                  //   // 'Distance to pickup: ${data['distance'].toStringAsFixed(2)} km',
                                  //   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  // ),
                                  Text(
                                    'Distance to ${data['markerId'] != null
                                        ? (data['markerId'].startsWith('start_')
                                        ? 'pickup'
                                        : (data['markerId'].startsWith('drop_')
                                        ? 'dropoff'
                                        : (data['markerId'] == 'destination' ? 'destination' : 'unknown')))
                                        : 'unknown'}: ${data['distance'].toStringAsFixed(2)} km',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),

                                  // Buttons are visibile when distance to either drop or pick < 500m or when marker == destination
                                  if (data['distance'] < 0.5 || data['markerId'] == "destination") ...[
                                    const SizedBox(height: 20.0),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                            MaterialStateProperty.all<Color>(Colors.green),
                                            foregroundColor:
                                            MaterialStateProperty.all<Color>(Colors.white),
                                          ),
                                          onPressed: () async {
                                            String markerId = data['markerId'];
                                            if (markerId.startsWith('start_')) {
                                              handlePassengerPickup(markerId);
                                              removeMarker(markerId);
                                            } else if (markerId
                                                .startsWith('drop_')) {
                                              handlePassengerDropoff(markerId);
                                              removeMarker(markerId);
                                            }
                                            else if (markerId == "destination") {
                                              _cancelLocationSubscription();
                                              await updateRideStatus(widget.rideId, "Completed");
                                              if(context.mounted) {
                                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PassengerReviewsScreen(rideId: widget.rideId)));
                                              }

                                            }
                                            // removeMarker(markerId);
                                            setState(() {
                                              isNearPassengerPickup = false;
                                              isNearPassengerDropoff = false;
                                              nearPassengerLocation = false;
                                              firstDistanceCheck = true;
                                            });
                                            distanceToClosestMarker();
                                          },
                                          child: Text(data['markerId'] == "destination" ? "End Ride" : "Continue"),
                                        ),
                                        const SizedBox(
                                          width: 50,
                                        ),
                                        Visibility(
                                          visible: data['markerId'].startsWith('start_') || data['markerId'].startsWith('drop_'),
                                          child: Row(
                                            children: [
                                              // Other widgets...
                                              IgnorePointer(
                                                ignoring: data['markerId'].startsWith('drop_'),
                                                child: Opacity(
                                                  opacity: data['markerId'].startsWith('drop_') ? 0.5 : 1.0,
                                                  child: Container(
                                                    width: 50,
                                                    height: 80,
                                                    decoration: const BoxDecoration(
                                                      color: Colors.green,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: IconButton(
                                                        icon: const Icon(
                                                          Icons.notification_add_outlined,
                                                          color: Colors.black,
                                                        ),
                                                        onPressed: () {
                                                          // Handle call button press
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              IgnorePointer(
                                                ignoring: data['markerId'].startsWith('drop_'),
                                                child: Opacity(
                                                  opacity: data['markerId'].startsWith('drop_') ? 0.5 : 1.0,
                                                  child: Container(
                                                    width: 50,
                                                    height: 80,
                                                    decoration: const BoxDecoration(
                                                      color: Colors.green,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: IconButton(
                                                        icon: const Icon(
                                                          Icons.mail_outlined,
                                                          color: Colors.black,
                                                        ),
                                                        onPressed: () {
                                                          // Handle mail button press
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => DashChatPage(
                                                                receiverUserEmail: data['passengerEmail'] ?? "",
                                                                receiverUserID: data['passengerId'],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              IgnorePointer(
                                                ignoring: data['markerId'].startsWith('drop_'),
                                                child: Opacity(
                                                  opacity: data['markerId'].startsWith('drop_') ? 0.5 : 1.0,
                                                  child: Container(
                                                    width: 50,
                                                    height: 80,
                                                    decoration: const BoxDecoration(
                                                      color: Colors.green,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: IconButton(
                                                        icon: const Icon(
                                                          Icons.call_outlined,
                                                          color: Colors.black,
                                                        ),
                                                        onPressed: () {
                                                          // Handle call button press
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ]
                                ],
                              );
                            } else {
                              // If the data is just the distance or no valid data
                              return Column(
                                children: [
                                  Text(
                                    snapshot.data.toString(),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
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
          ),
          Positioned(
            top: nearPassengerLocation ? 490 : 570, // Adjust this value to position the circle
            // top: 500, // Adjust this value to position the circle
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
        'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&waypoints=${waypoints.join('|')}&travelmode=driving&dir_action=navigate';

    // Launch URL
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Use Flutter's in-built widgets to show the error message
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Could not launch Google Maps. Please check your connection or app settings.'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }
}


