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

  // Future<void> _navigateToEditRoute() async {
  //   // Navigate to the Edit Route page and await the waypoints result
  //   final List<LatLng>? updatedWaypoints = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => EditRoutePage(
  //         initialPickupLocation: _kPickupLocation,
  //         initialDropoffLocation: _kDropLocation,
  //       ),
  //     ),
  //   );
  //
  //   // If new waypoints are selected, update and fetch new directions
  //   if (updatedWaypoints != null) {
  //     setState(() {
  //       waypoints = updatedWaypoints;
  //     });
  //     _fetchDirectionsAndPolylines();
  //   }
  // }

  // Future<void> _navigateToEditRoute() async {
  //   // Navigate to the Edit Route page and await the route options result
  //   final Map<String, dynamic>? routeOptions = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => EditRoutePage(
  //         initialPickupLocation: _kPickupLocation,
  //         initialDropoffLocation: _kDropLocation,
  //       ),
  //     ),
  //   );
  //
  //   // If route options are selected, update and fetch new directions
  //   if (routeOptions != null) {
  //     final List<LatLng>? updatedWaypoints = routeOptions['waypoints'];
  //     final bool avoidHighways = routeOptions['avoidHighways'];
  //     final bool avoidTolls = routeOptions['avoidTolls'];
  //     final bool avoidFerries = routeOptions['avoidFerries'];
  //
  //     setState(() {
  //       waypoints = updatedWaypoints ?? [];
  //       this.avoidHighways = avoidHighways;
  //       this.avoidTolls = avoidTolls;
  //       this.avoidFerries = avoidFerries;
  //     });
  //
  //     _fetchDirectionsAndPolylines();
  //   }
  // }

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

    // List<Map<String, dynamic>> results = await DirectionsService().getRouteDirections(
    //   _kPickupLocation,
    //   _kDropLocation,
    // );

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
              Text(
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




// import 'dart:async';
// import 'dart:convert';
// import 'package:crypto/crypto.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart'; // TODO - use Dio package
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
//
// import '../../../models/offer_ride.dart';
// import '../../../services/directions/directions_service.dart';
// import '../../ride/ride_options_screen.dart';
//
// class RouteInfo {
//   final String distance;
//   final String duration;
//   final List<LatLng> polylineCoordinates;
//
//   RouteInfo({
//     required this.distance,
//     required this.duration,
//     required this.polylineCoordinates,
//   });
// }
//
// class NewMapsRoute extends StatefulWidget {
//   final LatLng? pickupLocation;
//   final LatLng? dropoffLocation;
//
//   const NewMapsRoute({Key? key, required this.pickupLocation, required this.dropoffLocation})
//       : super(key: key);
//
//   @override
//   State<NewMapsRoute> createState() => _NewMapsRouteState();
// }
//
// class _NewMapsRouteState extends State<NewMapsRoute> {
//   OfferRide ride = OfferRide();
//   Location _locationController = Location();
//
//   final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
//   late LatLng _kPickupLocation;
//   late LatLng _kDropLocation;
//   LatLng? _currentP;
//
//   Map<PolylineId, Polyline> polylines = {};
//   Map<PolylineId, RouteInfo> routeInfo = {}; // Holds route information
//   PolylineId? _selectedPolylineId;
//
//   @override
//   void initState() {
//     super.initState();
//     _kPickupLocation = widget.pickupLocation!;
//     _kDropLocation = widget.dropoffLocation!;
//     _fetchDirectionsAndPolylines();
//   }
//
//   @override
//   void dispose() {
//     ride.resetPolylinePoints();
//     super.dispose();
//   }
//
//   Future<void> _fetchDirectionsAndPolylines() async {
//     List<Map<String, dynamic>> results = await DirectionsService().getDirections(
//       _kPickupLocation,
//       _kDropLocation,
//     );
//
//     for (var i = 0; i < results.length; i++) {
//       List<LatLng> polylineCoordinates = decodePolyline(results[i]['polyline']);
//       String distance = results[i]['distance'].toString(); // Convert int to String
//       String duration = results[i]['duration'].toString(); // Convert int to String
//       generatePolylineFromPoints(
//         polylineCoordinates,
//         i.toString(),
//         distance,
//         duration,
//       );
//     }
//   }
//
//   // Future<void> _fetchDirectionsAndPolylines() async {
//   //   List<Map<String, dynamic>> results = await DirectionsService().getDirections(
//   //     _kPickupLocation,
//   //     _kDropLocation,
//   //   );
//   //
//   //   for (var i = 0; i < results.length; i++) {
//   //     List<LatLng> polylineCoordinates = decodePolyline(results[i]['polyline']);
//   //     String distance = results[i]['distance'].toString(); // Convert int to String
//   //     String duration = results[i]['duration'].toString(); // Convert int to String
//   //
//   //     // Generate a unique identifier for each route
//   //     String uniqueId = generateUniqueId(results[i]); // You need to implement this method
//   //
//   //     generatePolylineFromPoints(
//   //       polylineCoordinates,
//   //       uniqueId,
//   //       distance,
//   //       duration,
//   //     );
//   //   }
//   // }
//   //
//   // String generateUniqueId(Map<String, dynamic> routeData) {
//   //   // Serialize the route data into a JSON string
//   //   String jsonData = json.encode(routeData);
//   //
//   //   // Compute a SHA-256 hash of the JSON string
//   //   var bytes = utf8.encode(jsonData);
//   //   var digest = sha256.convert(bytes);
//   //
//   //   // Convert the hash into a hexadecimal string
//   //   String uniqueId = digest.toString();
//   //
//   //   return uniqueId;
//   // }
//
//
//
//   List<LatLng> decodePolyline(String encoded) {
//     List<LatLng> polyline = [];
//     List<PointLatLng> decoded = PolylinePoints().decodePolyline(encoded);
//     for (var point in decoded) {
//       polyline.add(LatLng(point.latitude, point.longitude));
//     }
//     return polyline;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Confirm Route"),
//       ),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             GoogleMap(
//               onMapCreated: ((GoogleMapController controller) => _mapController.complete(controller)),
//               initialCameraPosition: CameraPosition(
//                 target: _kPickupLocation,
//                 zoom: 10.8,
//               ),
//               markers: {
//                 Marker(
//                   markerId: const MarkerId("_pickupLocation"),
//                   icon: BitmapDescriptor.defaultMarker,
//                   position: _kPickupLocation,
//                 ),
//                 Marker(
//                   markerId: MarkerId("_dropLocation"),
//                   icon: BitmapDescriptor.defaultMarker,
//                   position: _kDropLocation,
//                 ),
//               },
//               polylines: Set<Polyline>.of(polylines.values),
//               gestureRecognizers: Set()..add(Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())),
//               onTap: (LatLng point) {
//                 // Iterate through polylines to find the tapped polyline
//                 polylines.forEach((polylineId, polyline) {
//                   if (isPointOnPolyline(point, polyline.points)) {
//                     // Set the tapped polyline as selected and change its color
//                     setState(() {
//                       _selectedPolylineId = polylineId;
//                       _changePolylineColor();
//
//                       // Show route information for the selected polyline
//                       _showRouteInfo(polylineId);
//                     });
//                   }
//                 });
//               },
//             ),
//             Positioned(
//               top: 10,
//               left: 10,
//               child: SizedBox(
//                 width: 200, // Adjust the width as needed
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Select Route:',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 10),
//                     ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: polylines.length,
//                       itemBuilder: (context, index) {
//                         PolylineId polylineId = polylines.keys.elementAt(index);
//                         bool isSelected = polylineId == _selectedPolylineId;
//                         return GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               _selectedPolylineId = polylineId;
//                               _changePolylineColor();
//                             });
//                           },
//                           child: Container(
//                             padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                             margin: EdgeInsets.only(bottom: 8),
//                             decoration: BoxDecoration(
//                               color: isSelected ? Colors.green.withOpacity(0.5) : Colors.transparent,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               'Route ${index + 1}',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                                 color: isSelected ? Colors.white : Colors.black,
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showRouteInfo(PolylineId polylineId) {
//     RouteInfo selectedRoute = routeInfo[polylineId]!;
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Route Information"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Distance: ${selectedRoute.distance}"),
//               Text("Duration: ${selectedRoute.duration}"),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text("Close"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   bool isPointOnPolyline(LatLng point, List<LatLng> polylinePoints) {
//     if (polylinePoints.length < 2) {
//       return false;
//     }
//
//     double tolerance = 0.0001; // Adjust the tolerance as needed
//
//     for (int i = 0; i < polylinePoints.length - 1; i++) {
//       LatLng p1 = polylinePoints[i];
//       LatLng p2 = polylinePoints[i + 1];
//
//       // Calculate the distance from the point to the segment (p1, p2)
//       double distance = _distanceToSegment(point, p1, p2);
//
//       if (distance < tolerance) {
//         return true;
//       }
//     }
//
//     return false;
//   }
//
//   double _distanceToSegment(LatLng point, LatLng p1, LatLng p2) {
//     double x = point.longitude;
//     double y = point.latitude;
//     double x1 = p1.longitude;
//     double y1 = p1.latitude;
//     double x2 = p2.longitude;
//     double y2 = p2.latitude;
//
//     double A = x - x1;
//     double B = y - y1;
//     double C = x2 - x1;
//     double D = y2 - y1;
//
//     double dot = A * C + B * D;
//     double len_sq = C * C + D * D;
//     double param = dot / len_sq;
//
//     double xx, yy;
//
//     if (param < 0) {
//       xx = x1;
//       yy = y1;
//     } else if (param > 1) {
//       xx = x2;
//       yy = y2;
//     } else {
//       xx = x1 + param * C;
//       yy = y1 + param * D;
//     }
//
//     double dx = x - xx;
//     double dy = y - yy;
//     return dx * dx + dy * dy;
//   }
//
//   void _changePolylineColor() {
//     polylines.forEach((polylineId, polyline) {
//       if (polylineId == _selectedPolylineId) {
//         // If the current polyline is selected, set its color to blue
//         polylines[polylineId] = polyline.copyWith(colorParam: Colors.blue);
//       } else {
//         // If the current polyline is not selected, set its color back to its original color
//         polylines[polylineId] = polyline.copyWith(colorParam: Colors.grey.shade500);
//       }
//     });
//     setState(() {});
//   }
//
//   void generatePolylineFromPoints(
//       List<LatLng> polylineCoordinates, String idSuffix, String distance, String duration) async {
//     PolylineId polylineId = PolylineId("route_$idSuffix");
//     Polyline polyline = Polyline(
//       polylineId: polylineId,
//       color: Colors.black,
//       points: polylineCoordinates,
//       width: 8,
//     );
//     setState(() {
//       polylines[polylineId] = polyline;
//       routeInfo[polylineId] = RouteInfo(
//         distance: distance,
//         duration: duration,
//         polylineCoordinates: polylineCoordinates,
//       );
//     });
//   }
// }




///// -------- working with tap to slect route
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart'; // TODO - use Dio package
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
//
// import '../../../models/offer_ride.dart';
// import '../../../services/directions/directions_service.dart';
// import '../../ride/ride_options_screen.dart';
//
// class NewMapsRoute extends StatefulWidget {
//   final LatLng? pickupLocation;
//   final LatLng? dropoffLocation;
//
//   const NewMapsRoute({Key? key, required this.pickupLocation, required this.dropoffLocation})
//       : super(key: key);
//
//   @override
//   State<NewMapsRoute> createState() => _NewMapsRouteState();
// }
//
// class _NewMapsRouteState extends State<NewMapsRoute> {
//   OfferRide ride = OfferRide();
//   Location _locationController = Location();
//
//   final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
//   late LatLng _kPickupLocation;
//   late LatLng _kDropLocation;
//   LatLng? _currentP;
//
//   Map<PolylineId, Polyline> polylines = {};
//   PolylineId? _selectedPolylineId;
//
//   @override
//   void initState() {
//     super.initState();
//     _kPickupLocation = widget.pickupLocation!;
//     _kDropLocation = widget.dropoffLocation!;
//     _fetchDirectionsAndPolylines();
//   }
//
//   @override
//   void dispose() {
//     ride.resetPolylinePoints();
//     super.dispose();
//   }
//
//   Future<void> _fetchDirectionsAndPolylines() async {
//     List<Map<String, dynamic>> results = await DirectionsService().getDirections(
//       _kPickupLocation,
//       _kDropLocation,
//     );
//
//     for (var i = 0; i < results.length; i++) {
//       List<LatLng> polylineCoordinates = decodePolyline(results[i]['polyline']);
//       generatePolylineFromPoints(polylineCoordinates, i.toString());
//     }
//   }
//
//   List<LatLng> decodePolyline(String encoded) {
//     List<LatLng> polyline = [];
//     List<PointLatLng> decoded = PolylinePoints().decodePolyline(encoded);
//     for (var point in decoded) {
//       polyline.add(LatLng(point.latitude, point.longitude));
//     }
//     return polyline;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Confirm Route"),
//       ),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             GoogleMap(
//               onMapCreated: ((GoogleMapController controller) => _mapController.complete(controller)),
//               initialCameraPosition: CameraPosition(
//                 target: _kPickupLocation,
//                 zoom: 10.8,
//               ),
//               markers: {
//                 Marker(
//                   markerId: const MarkerId("_pickupLocation"),
//                   icon: BitmapDescriptor.defaultMarker,
//                   position: _kPickupLocation,
//                 ),
//                 Marker(
//                   markerId: MarkerId("_dropLocation"),
//                   icon: BitmapDescriptor.defaultMarker,
//                   position: _kDropLocation,
//                 ),
//               },
//               // polylines: Set<Polyline>.of(polylines.values),
//               polylines: Set<Polyline>.of(polylines.values),
//               gestureRecognizers: Set()..add(Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())),
//               onTap: (LatLng point) {
//                 // Iterate through polylines to find the tapped polyline
//                 polylines.forEach((polylineId, polyline) {
//                   if (isPointOnPolyline(point, polyline.points)) {
//                     // Set the tapped polyline as selected and change its color
//                     setState(() {
//                       _selectedPolylineId = polylineId;
//                       _changePolylineColor();
//                     });
//                   }
//                 });
//               },
//             ),
//             Positioned(
//               top: 10,
//               left: 10,
//               child: SizedBox(
//                 width: 200, // Adjust the width as needed
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Select Route:',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 10),
//                     ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: polylines.length,
//                       itemBuilder: (context, index) {
//                         PolylineId polylineId = polylines.keys.elementAt(index);
//                         bool isSelected = polylineId == _selectedPolylineId;
//                         return GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               _selectedPolylineId = polylineId;
//                               _changePolylineColor();
//                             });
//                           },
//                           child: Container(
//                             padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                             margin: EdgeInsets.only(bottom: 8),
//                             decoration: BoxDecoration(
//                               color: isSelected ? Colors.green.withOpacity(0.5) : Colors.transparent,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               'Route ${index + 1}',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                                 color: isSelected ? Colors.white : Colors.black,
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   bool isPointOnPolyline(LatLng point, List<LatLng> polylinePoints) {
//     if (polylinePoints.length < 2) {
//       return false;
//     }
//
//     double tolerance = 0.0001; // Adjust the tolerance as needed
//
//     for (int i = 0; i < polylinePoints.length - 1; i++) {
//       LatLng p1 = polylinePoints[i];
//       LatLng p2 = polylinePoints[i + 1];
//
//       // Calculate the distance from the point to the segment (p1, p2)
//       double distance = _distanceToSegment(point, p1, p2);
//
//       if (distance < tolerance) {
//         return true;
//       }
//     }
//
//     return false;
//   }
//
// // Helper function to calculate the distance from a point to a segment
//   double _distanceToSegment(LatLng point, LatLng p1, LatLng p2) {
//     double x = point.longitude;
//     double y = point.latitude;
//     double x1 = p1.longitude;
//     double y1 = p1.latitude;
//     double x2 = p2.longitude;
//     double y2 = p2.latitude;
//
//     double A = x - x1;
//     double B = y - y1;
//     double C = x2 - x1;
//     double D = y2 - y1;
//
//     double dot = A * C + B * D;
//     double len_sq = C * C + D * D;
//     double param = dot / len_sq;
//
//     double xx, yy;
//
//     if (param < 0) {
//       xx = x1;
//       yy = y1;
//     } else if (param > 1) {
//       xx = x2;
//       yy = y2;
//     } else {
//       xx = x1 + param * C;
//       yy = y1 + param * D;
//     }
//
//     double dx = x - xx;
//     double dy = y - yy;
//     return dx * dx + dy * dy;
//   }
//   // void _changePolylineColor() {
//   //   polylines.forEach((polylineId, polyline) {
//   //     Color color = polylineId == _selectedPolylineId ? Colors.blue : Colors.black;
//   //     polylines[polylineId] = polyline.copyWith(colorParam: color);
//   //   });
//   //   setState(() {});
//   // }
//
//
//   void _changePolylineColor() {
//     polylines.forEach((polylineId, polyline) {
//       if (polylineId == _selectedPolylineId) {
//         // If the current polyline is selected, set its color to blue
//         polylines[polylineId] = polyline.copyWith(colorParam: Colors.blue);
//       } else {
//         // If the current polyline is not selected, set its color back to its original color
//         polylines[polylineId] = polyline.copyWith(colorParam: Colors.grey.shade500);
//       }
//     });
//     setState(() {});
//   }
//
//   void generatePolylineFromPoints(List<LatLng> polylineCoordinates, String idSuffix) async {
//     PolylineId polylineId = PolylineId("route_$idSuffix");
//     Polyline polyline = Polyline(
//       polylineId: polylineId,
//       color: Colors.black,
//       points: polylineCoordinates,
//       width: 8,
//     );
//     setState(() {
//       polylines[polylineId] = polyline;
//     });
//   }
// }





// ----------------- working shows multiple routes ------------------
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart'; // TODO - use Dio package
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
//
// import '../../../models/offer_ride.dart';
//
// import '../../../services/directions/directions_service.dart';
// import '../../ride/ride_options_screen.dart';
//
// class NewMapsRoute extends StatefulWidget {
//   final LatLng? pickupLocation;
//   final LatLng? dropoffLocation;
//
//   const NewMapsRoute(
//       {super.key, required this.pickupLocation, required this.dropoffLocation});
//
//   @override
//   State<NewMapsRoute> createState() => _NewMapsRouteState();
// }
//
// class _NewMapsRouteState extends State<NewMapsRoute> {
//   OfferRide ride = OfferRide();
//
//   final client = Client();
//
//   Location _locationController = new Location();
//
//   final Completer<GoogleMapController> _mapController =
//   Completer<GoogleMapController>();
//
//   late LatLng _kPickupLocation;
//   late LatLng _kDropLocation;
//   LatLng? _currentP = null;
//
//   Map<PolylineId, Polyline> polylines = {};
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     // RideProvider rideProvider = Provider.of<RideProvider>(context, listen: false);
//     _kPickupLocation = widget.pickupLocation!;
//     _kDropLocation = widget.dropoffLocation!;
//
//     // getTotalDistanceAndDuration();
//
//     // TODO - try to use traffic api??
//
//     // _initializeRideDistance();
//
//     _fetchDirectionsAndPolylines();
//
//
//     // getDirections();
//     // _fetchDirectionsAndPolylines();
//     print("INSIDEEEEE Singleton CONFIRMMMM ROUTEEEEEEE${ride.pickupLocation}");
//
//     // getPolylinePoints().then((coordinates) {
//     //   // rideProvider.updatePolylinePoints(coordinates);
//     //   ride.polylinePoints = coordinates;
//     //   generatePolylineFromPoints(coordinates);
//     // });
//   }
//
//   // void _initializeRideDistance() async {
//   //   print("INITIAAAAAAAAAAAAAAAALIZEEE METHOD CALLEDdd");
//   //   Map<String, dynamic> result = await getTotalDistanceAndDuration();
//   //   double distance =
//   //   result['distance']; // Assuming 'distance' is the key in the map
//   //   ride.rideDistance = distance;
//   //
//   //   // Get duration without converting
//   //   Map<String, int> duration = result['duration'];
//   //   int? hours = duration['hours'];
//   //   int? minutes = duration['minutes'];
//   //
//   //   ride.rideDuration = "${hours.toString()} ${minutes.toString()}";
//   //
//   //   print("ride from distance in ride: ${ride.rideDistance}");
//   //   print("ride from DURATION in ride: $hours hours and $minutes minutes");
//   // }
//
//   @override
//   void dispose() {
//     // Remove polyline points when the user goes back without confirming
//     ride.resetPolylinePoints();
//
//     super.dispose();
//   }
//
//   // Future<void> _fetchDirectionsAndPolylines() async {
//   //   List<Map<String, dynamic>> results = await getDirections();
//   //   for (var i = 0; i < results.length; i++) {
//   //     List<LatLng> polylineCoordinates = decodePolyline(results[i]['polyline']);
//   //     generatePolylineFromPoints(polylineCoordinates, i.toString());
//   //   }
//   // }
//   //
//   // List<LatLng> decodePolyline(String encoded) {
//   //   List<LatLng> polyline = [];
//   //   List<PointLatLng> decoded = PolylinePoints().decodePolyline(encoded);
//   //   for (var point in decoded) {
//   //     polyline.add(LatLng(point.latitude, point.longitude));
//   //   }
//   //   return polyline;
//   // }
//
//   Future<void> _fetchDirectionsAndPolylines() async {
//     // Call the getDirections method from DirectionsService
//     List<Map<String, dynamic>> results = await DirectionsService().getDirections(
//       _kPickupLocation,
//       _kDropLocation,
//     );
//
//     // Process the results to extract polyline coordinates and generate polylines
//     for (var i = 0; i < results.length; i++) {
//       List<LatLng> polylineCoordinates = decodePolyline(results[i]['polyline']);
//       generatePolylineFromPoints(polylineCoordinates, i.toString());
//     }
//   }
//
//   List<LatLng> decodePolyline(String encoded) {
//     List<LatLng> polyline = [];
//     List<PointLatLng> decoded = PolylinePoints().decodePolyline(encoded);
//     for (var point in decoded) {
//       polyline.add(LatLng(point.latitude, point.longitude));
//     }
//     return polyline;
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//         elevation: 0.5,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios), // Back button icon
//           onPressed: () {
//             Navigator.pop(context); // Handle back navigation
//           },
//         ),
//         title: Text("Confirm Route"),
//       ),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             GoogleMap(
//               onMapCreated: ((GoogleMapController controller) =>
//                   _mapController.complete(controller)),
//               initialCameraPosition: CameraPosition(
//                 target: _kPickupLocation,
//                 zoom: 10.8,
//               ),
//               markers: {
//                 Marker(
//                   markerId: const MarkerId("_pickupLocation"),
//                   icon: BitmapDescriptor.defaultMarker,
//                   position: _kPickupLocation,
//                 ),
//                 Marker(
//                   markerId: MarkerId("_dropLocation"),
//                   icon: BitmapDescriptor.defaultMarker,
//                   position: _kDropLocation,
//                 ),
//               },
//               polylines: Set<Polyline>.of(polylines.values),
//             ),
//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: 0,
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Container(
//                   height: 50.0,
//                   color: Colors.transparent,
//                   child: ElevatedButton(
//                     style: ButtonStyle(
//                       foregroundColor:
//                       MaterialStateProperty.all<Color>(Colors.white),
//                       backgroundColor:
//                       MaterialStateProperty.all<Color>(Colors.green),
//                     ),
//                     onPressed: () {
//                       // _confirmPickupLocation(pickedLatitude, pickedLongitude  , _textController.text);
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => RideOptions(),
//                         ),
//                       );
//                     },
//                     child: Text("Confirm Route",
//                         style: TextStyle(
//                             fontSize: 14.0, fontWeight: FontWeight.bold)),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   String _getApiKey() {
//     return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'YOUR_DEFAULT_API_KEY';
//   }
//
//   Future<List<LatLng>> getPolylinePoints() async {
//     List<LatLng> polylineCoordinates = [];
//     PolylinePoints polylinePoints = PolylinePoints();
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       _getApiKey(),
//       PointLatLng(_kPickupLocation.latitude, _kPickupLocation.longitude),
//       PointLatLng(_kDropLocation.latitude, _kDropLocation.longitude),
//       travelMode: TravelMode.driving,
//     );
//     if (result.points.isNotEmpty) {
//       result.points.forEach((PointLatLng point) {
//         polylineCoordinates.add(
//           LatLng(point.latitude, point.longitude),
//         );
//       });
//     } else {
//       print(result.errorMessage);
//     }
//     return polylineCoordinates;
//   }
//
//   // void generatePolylineFromPoints(List<LatLng> polylineCoordinates) async {
//   //   PolylineId id = const PolylineId("poly");
//   //   Polyline polyline = Polyline(
//   //     polylineId: id,
//   //     color: Colors.black,
//   //     points: polylineCoordinates,
//   //     width: 8,
//   //   );
//   //   setState(() {
//   //     polylines[id] = polyline;
//   //   });
//   // }
//
//   void generatePolylineFromPoints(List<LatLng> polylineCoordinates, String id) async {
//     PolylineId polylineId = PolylineId(id); // Unique PolylineId for each polyline
//     Polyline polyline = Polyline(
//       polylineId: polylineId,
//       color: Colors.black,
//       points: polylineCoordinates,
//       width: 8,
//     );
//     setState(() {
//       polylines[polylineId] = polyline; // Use polylineId instead of const PolylineId("poly")
//     });
//   }
//
//   // Future<Map<String, dynamic>> getTotalDistanceAndDuration() async {
//   //   Map<String, dynamic> result = {};
//   //   final apiKey = _getApiKey();
//   //   String url =
//   //       'https://maps.googleapis.com/maps/api/directions/json?origin=${_kPickupLocation.latitude},${_kPickupLocation.longitude}&destination=${_kDropLocation.latitude},${_kDropLocation.longitude}&alternatives=true&key=$apiKey';
//   //
//   //   var response = await client.get(Uri.parse(url));
//   //   var json = jsonDecode(response.body);
//   //
//   //   if (json['status'] == 'OK') {
//   //     double totalDistance = 0.0;
//   //     int totalDuration = 0;
//   //     for (var route in json['routes']) {
//   //       for (var leg in route['legs']) {
//   //         totalDistance += double.parse(leg['distance']['value'].toString());
//   //         totalDuration += int.parse(leg['duration']['value'].toString());
//   //       }
//   //     }
//   //
//   //     // Convert distance from meters to kilometers
//   //     totalDistance /= 1000;
//   //
//   //     result['distance'] = totalDistance;
//   //     result['duration'] = totalDuration;
//   //
//   //     print("Totlaaaaaaa:LLLLLLLL disatance: $totalDistance");
//   //     print("TOOOOOOOOOOOOOOTAAAAAAAAAAAAAAAAL DURATTTTTIOM TIMEEEEEE: $totalDuration");
//   //   } else {
//   //     print("Failed to fetch directions: ${json['status']}");
//   //   }
//   //
//   //   return result;
//   // }
//
//   Future<Map<String, dynamic>> getTotalDistanceAndDuration() async {
//     Map<String, dynamic> result = {};
//     final apiKey = _getApiKey();
//     String url =
//         'https://maps.googleapis.com/maps/api/directions/json?origin=${_kPickupLocation.latitude},${_kPickupLocation.longitude}&destination=${_kDropLocation.latitude},${_kDropLocation.longitude}&alternatives=true&mode=driving&key=$apiKey';
//
//     var response = await client.get(Uri.parse(url));
//     var json = jsonDecode(response.body);
//
//     if (json['status'] == 'OK') {
//       double totalDistance = 0.0;
//       int totalDuration = 0;
//       for (var route in json['routes']) {
//         for (var leg in route['legs']) {
//           totalDistance += double.parse(leg['distance']['value'].toString());
//           totalDuration += int.parse(leg['duration']['value'].toString());
//         }
//       }
//
//       // Convert distance from meters to kilometers
//       totalDistance /= 1000;
//
//       // Convert duration from seconds to hours and minutes
//       int hours = totalDuration ~/ 3600;
//       int minutes = (totalDuration % 3600) ~/ 60;
//
//       result['distance'] = totalDistance;
//       result['duration'] = {'hours': hours, 'minutes': minutes};
//
//       print("Totlaaaaaaa:LLLLLLLL disatance: $totalDistance");
//       print(
//           "TOOOOOOOOOOOOOOTAAAAAAAAAAAAAAAAL DURATTTTTIOM TIMEEEEEE: $result['duration']");
//     } else {
//       print("Failed to fetch directions: ${json['status']}");
//     }
//
//     return result;
//   }
//
// // Future<double> getTotalDistance() async {
// //   double totalDistance = 0.0;
// //   final apiKey = _getApiKey();
// //   String url =
// //       'https://maps.googleapis.com/maps/api/directions/json?origin=${_kPickupLocation.latitude},${_kPickupLocation.longitude}&destination=${_kDropLocation.latitude},${_kDropLocation.longitude}&alternatives=true&key=$apiKey';
// //
// //   var response = await client.get(Uri.parse(url));
// //   var json = jsonDecode(response.body);
// //
// //   if (json['status'] == 'OK') {
// //     for (var route in json['routes']) {
// //       for (var leg in route['legs']) {
// //         totalDistance += double.parse(leg['distance']['value'].toString());
// //       }
// //     }
// //   } else {
// //     print("Failed to fetch directions: ${json['status']}");
// //   }
// //
// //   // Convert distance from meters to kilometers
// //   totalDistance /= 1000;
// //
// //   print("totaaaaaaaaaaaal distanceeeeee FRRRRROMMMMMMMMMMMM JOTUNRY: $totalDistance");
// //
// //   return totalDistance;
// // }
//
// // Future<List<Map<String, dynamic>>> getDirections() async {
// //   // final client = Client();
// //   final apiKey = _getApiKey();
// //   String url =
// //       'https://maps.googleapis.com/maps/api/directions/json?origin=7.412487,79.859083&destination=7.2000,79.8737&alternatives=true&key=$apiKey';
// //
// //   var response = await client.get(Uri.parse(url));
// //   var json = jsonDecode(response.body);
// //
// //   List<Map<String, dynamic>> results = [];
// //
// //   if (json['status'] == 'OK') {
// //     for (var route in json['routes']) {
// //       var routeDetails = {
// //         'bounds_ne': route['bounds']['northeast'],
// //         'bounds_sw': route['bounds']['southwest'],
// //         'start_location': route['legs'][0]['start_location'],
// //         'end_location': route['legs'][0]['end_location'],
// //         'polyline': route['overview_polyline']['points'],
// //       };
// //
// //       results.add(routeDetails);
// //     }
// //   }
// //
// //   print("RESULLLLLLLLLLLLLTSSSSSSSSSSSSSSSS -${results.length}");
// //   return results;
// // }
//
// // Future<Map<String, dynamic>> getDirections() async{
// //   final client = Client();
// //
// //   const String url =
// //       'https://maps.googleapis.com/maps/api/directions/json?origin=7.412487,79.859083&destination=7.2000,79.8737&alternatives=true&key=$GOOGLE_MAPS_API_KEY';
// //
// //   var response = await client.get(Uri.parse(url));
// //   var json = jsonDecode(response.body);
// //
// //   var results = {
// //     'bounds_ne' : json['routes'][0]['bounds']['northeast'],
// //     'bounds_sw' : json['routes'][0]['bounds']['southwest'],
// //     'start_location' : json['routes'][0]['legs'][0]['start_location'],
// //     'end_location' : json['routes'][0]['legs'][0]['end_location'],
// //     'polyline' : json['routes'][0]['overview_polyline']['points'],
// //   };
// //
// //   print(results);
// //   return results;
// // }
// }
