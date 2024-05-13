import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart'; // TODO - use Dio package
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import '../../../constants/colors.dart';
import '../../../models/offer_ride.dart';
import '../../../services/directions/directions_service.dart';
import '../../ride/ride_options_screen.dart';
import 'edit_route_screen.dart';

class RouteInfo {
  final String distance;
  final String duration;
  final String description;
  // final String summary;
  // final String encodedPolyline;
  final List<LatLng> polylineCoordinates;

  RouteInfo({
    // required this.summary,
    required this.description,
    required this.distance,
    required this.duration,
    required this.polylineCoordinates,
    // required this.encodedPolyline,
  });
}

class NewMapsRoute extends StatefulWidget {
  final LatLng? pickupLocation;
  final LatLng? dropoffLocation;

  const NewMapsRoute({Key? key, required this.pickupLocation, required this.dropoffLocation})
      : super(key: key);

  @override
  State<NewMapsRoute> createState() => _NewMapsRouteState();
}

class _NewMapsRouteState extends State<NewMapsRoute> {
  OfferRide ride = OfferRide();
  Location _locationController = Location();

  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  late LatLng _kPickupLocation;
  late LatLng _kDropLocation;
  LatLng? _currentP;

  List<LatLng> waypoints = []; // List of waypoints for the route

  Map<PolylineId, Polyline> polylines = {};
  Map<PolylineId, RouteInfo> routeInfo = {}; // Holds route information
  PolylineId? _selectedPolylineId;


  // Route options
  bool avoidHighways = false;
  bool avoidTolls = false;
  bool avoidFerries = false;

  @override
  void initState() {
    super.initState();
    _kPickupLocation = widget.pickupLocation!;
    _kDropLocation = widget.dropoffLocation!;
    _fetchDirectionsAndPolylines();
  }

  @override
  void dispose() {
    ride.resetPolylinePoints();
    super.dispose();
  }

  Future<void> _navigateToEditRoute() async {
    // Pass the initial checkbox states to EditRoutePage
    final Map<String, dynamic>? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRoutePage(
          initialPickupLocation: _kPickupLocation,
          initialDropoffLocation: _kDropLocation,
          initialAvoidHighways: avoidHighways,
          initialAvoidTolls: avoidTolls,
          initialAvoidFerries: avoidFerries,
        ),
      ),
    );

    // Receive the updated route options and waypoints
    if (result != null) {
      setState(() {
        waypoints = result['waypoints'] ?? [];
        avoidHighways = result['avoidHighways'];
        avoidTolls = result['avoidTolls'];
        avoidFerries = result['avoidFerries'];
      });

      // Fetch and apply the new directions using the updated options
      _fetchDirectionsAndPolylines();
    }
  }


  Future<void> _fetchDirectionsAndPolylines() async {

    final bool avoidHighways = this.avoidHighways;
    final bool avoidTolls = this.avoidTolls;
    final bool avoidFerries = this.avoidFerries;

    List<Map<String, dynamic>> results = await DirectionsService().getDirections(
      _kPickupLocation,
      _kDropLocation,
      waypoints,
      avoidHighways: avoidHighways,
      avoidTolls: avoidTolls,
      avoidFerries: avoidFerries,
    );

    for (var i = 0; i < results.length; i++) {
      List<LatLng> polylineCoordinates = decodePolyline(results[i]['polyline']);
      String encodedPolyline = results[i]['polyline']; // Get the encoded polyline
      String distance = results[i]['distance'].toString();
      String duration = results[i]['duration'].toString();
      String description = results[i]['description']; // Make sure description is being fetched
      generatePolylineFromPoints(
        polylineCoordinates,
        i.toString(),
        distance,
        duration,
        description,
        // encodedPolyline,
      );

      // // Store both encoded and decoded polylines in routeInfo map
      // routeInfo[PolylineId(i.toString())] = RouteInfo(
      //   distance: distance,
      //   duration: duration,
      //   polylineCoordinates: polylineCoordinates,
      //   encodedPolyline: encodedPolyline,
      // );

      print("Start coordinate of Polyline $i: ${polylineCoordinates.first}");
      print("End coordinate of Polyline $i: ${polylineCoordinates.last}");
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    List<PointLatLng> decoded = PolylinePoints().decodePolyline(encoded);
    for (var point in decoded) {
      polyline.add(LatLng(point.latitude, point.longitude));
    }
    return polyline;
  }

  double _convertMetersToKilometers(String metersString) {
    int meters = int.tryParse(metersString) ?? 0;
    return meters / 1000; // 1 km = 1000 meters
  }

  String _formatDuration(String secondsString) {
    // Remove the trailing "s" from the string
    secondsString = secondsString.replaceAll('s', '');

    // Parse the modified string as an integer
    int seconds = int.tryParse(secondsString) ?? 0;

    if (seconds < 60) {
      return '$seconds seconds';
    } else if (seconds < 3600) {
      return '${(seconds / 60).floor()} minutes';
    } else {
      int hours = (seconds / 3600).floor();
      int remainingMinutes = ((seconds % 3600) / 60).floor();
      return '$hours hours ${remainingMinutes} minutes';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Route"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            // icon: const Icon(Icons.edit),
            tooltip: 'Edit Route',
            onPressed: _navigateToEditRoute,
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: ((GoogleMapController controller) => _mapController.complete(controller)),
              initialCameraPosition: CameraPosition(
                target: _kPickupLocation,
                zoom: 11.8,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("_pickupLocation"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _kPickupLocation,
                ),
                Marker(
                  markerId: MarkerId("_dropLocation"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _kDropLocation,
                ),
              },
              polylines: Set<Polyline>.of(polylines.values),
              gestureRecognizers: Set()..add(Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())),
              padding: EdgeInsets.symmetric(vertical: 275.0),
            ),
          ],
        ),
      ),
      bottomSheet: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.32), // Set maximum height of bottom sheet
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Route:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: polylines.length,
                  itemBuilder: (context, index) {
                    PolylineId polylineId = polylines.keys.elementAt(index);
                    bool isSelected = polylineId == _selectedPolylineId;
                    RouteInfo route = routeInfo[polylineId]!;
                    return ListTile(
                      onTap: () {
                        setState(() {
                          _selectedPolylineId = polylineId;
                          _changePolylineColor();
                        });
                        // _showRouteInfo(polylineId); // Show route information
                      },
                      title: Text(
                        'Route: ${route.description}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.green : Colors.black,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Distance: ${_convertMetersToKilometers(route.distance).toStringAsFixed(2)} km"),
                          Text("Duration: ${_formatDuration(route.duration)}"),
                        ],
                      ),
                      selected: isSelected,
                      selectedTileColor: Colors.green.withOpacity(0.5),
                    );
                  },
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // shape: const RoundedRectangleBorder(),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  // side: const BorderSide(color: kSecondaryColor),
                  // padding: const EdgeInsets.symmetric(vertical: 15.0),
                ),
                // onPressed: () {
                //   // Handle proceed action here
                //   // Get the selected route's details
                //   PolylineId? selectedPolylineId = _selectedPolylineId; // Assuming you already have this value
                //   print("SELECTEEEED ROUTE POLYLINE ID: $selectedPolylineId");
                //   RouteInfo selectedRoute = routeInfo[selectedPolylineId]!; // Assuming you have a map of route info
                //
                //   // print("ENCODEDDD POLY LINEEEEEE: ${selectedRoute.encodedPolyline}");
                //
                //   // Format distance and duration
                //   String formattedDistance = _convertMetersToKilometers(selectedRoute.distance).toStringAsFixed(2);
                //   String formattedDuration = _formatDuration(selectedRoute.duration);
                //
                //   // Update the ride details in OfferRide class
                //   OfferRide().updateRideDetails(formattedDistance, formattedDuration, polylines[selectedPolylineId]!.points);
                //   // OfferRide().updateRideDetails(formattedDistance, formattedDuration, polylines[selectedPolylineId]!.points, selectedRoute.encodedPolyline);
                //
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(builder: (context) => const RideOptions()), // Replace RideOptions with your screen widget
                //   );
                // },
                onPressed: () {
                  // Check if a route is selected
                  if (_selectedPolylineId == null) {
                    // Display a message prompting the user to select a route
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please choose a route to proceed.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return; // Exit early if no route is selected
                  }

                  // Proceed if a route is selected
                  RouteInfo selectedRoute = routeInfo[_selectedPolylineId]!; // Assuming you have a map of route info

                  // Format distance and duration
                  String formattedDistance = _convertMetersToKilometers(selectedRoute.distance).toStringAsFixed(2);
                  String formattedDuration = _formatDuration(selectedRoute.duration);

                  // Update the ride details in OfferRide class
                  OfferRide().updateRideDetails(
                    formattedDistance,
                    formattedDuration,
                    polylines[_selectedPolylineId]!.points,
                  );

                  // Navigate to the next screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RideOptions()),
                  );
                },

                child: Text("Proceed"),
              ),
            ],
          ),
        ),
      ),

      // floatingActionButton:  FloatingActionButton(
      //   onPressed: () {
      //     // This could open a dialog or use the current map center as a new waypoint
      //     // _addWaypoint(_currentMapCenter);
      //   },
      //   tooltip: 'Add Waypoint',
      //   child: Icon(Icons.add_location),
      // ),
    );

  }

  void _showRouteInfo(PolylineId polylineId) {
    RouteInfo selectedRoute = routeInfo[polylineId]!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Route Information"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Distance: ${selectedRoute.distance}"),
              Text("Duration: ${selectedRoute.duration}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _changePolylineColor() {
    polylines.forEach((polylineId, polyline) {
      if (polylineId == _selectedPolylineId) {
        // If the current polyline is selected, set its color to blue and increase the z-index
        polylines[polylineId] = polyline.copyWith(colorParam: Colors.blue, zIndexParam: 10);
      } else {
        // If the current polyline is not selected, set its color back to its original color and reset the z-index
        polylines[polylineId] = polyline.copyWith(colorParam: Colors.grey.shade500, zIndexParam: 0);
      }
    });
    setState(() {});
  }

  void selectPolyline(PolylineId polylineId) {
    setState(() {
      _selectedPolylineId = polylineId;
    });
  }

  void generatePolylineFromPoints(
      List<LatLng> polylineCoordinates, String idSuffix, String distance, String duration, String description) async {
    PolylineId polylineId = PolylineId("route_$idSuffix");
    Polyline polyline = Polyline(
      polylineId: polylineId,
      color: Colors.black,
      points: polylineCoordinates,
      width: 8,
    );
    setState(() {
      polylines[polylineId] = polyline;
      routeInfo[polylineId] = RouteInfo(
        // summary: summary,
        description: description,
        distance: distance,
        duration: duration,
        polylineCoordinates: polylineCoordinates,
        // encodedPolyline: encodedPolyline,
      );
    });
  }
}

