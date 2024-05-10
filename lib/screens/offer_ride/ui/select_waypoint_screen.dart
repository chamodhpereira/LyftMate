import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../../../services/map/place_service.dart';
import '../../map/places_search_screen.dart';

class SelectWaypointsScreen extends StatefulWidget {
  final String waypointLabel;

  const SelectWaypointsScreen({Key? key, required this.waypointLabel}) : super(key: key);

  @override
  _SelectWaypointsScreenState createState() => _SelectWaypointsScreenState();
}

class _SelectWaypointsScreenState extends State<SelectWaypointsScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  final TextEditingController _searchController = TextEditingController();
  Set<Marker> _markers = {};
  LatLng? selectedWaypoint;
  String? selectedWaypointDescription;
  final String sessionToken = const Uuid().v4();
  LocationData? _currentLocation;

  @override
  void initState() {
    super.initState();
    _getInitialMapLocation();
    _getUserLocationAndMove();
  }

  /// Set the initial location to Sri Lanka
  Future<void> _getInitialMapLocation() async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      const CameraPosition(
        target: LatLng(7.8731, 80.7718), // Center point of Sri Lanka
        zoom: 6,
      ),
    ));
  }

  /// Fetch and move to the user's current location
  Future<void> _getUserLocationAndMove() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location service is enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    // Check location permission
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    // Get the current location
    LocationData locationData = await location.getLocation();
    _currentLocation = locationData;

    // Move the map to the user's current location
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(locationData.latitude ?? 0.0, locationData.longitude ?? 0.0),
        zoom: 14,
      ),
    ));

    // Optionally, you can set a marker at the user's location
    _setMarker(LatLng(locationData.latitude ?? 0.0, locationData.longitude ?? 0.0));
  }

  Future<String?> _getPlaceNameFromCoordinates(double latitude, double longitude) async {
    final client = Client();
    final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'YOUR_DEFAULT_API_KEY';
    final String requestUrl = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';
    final response = await client.get(Uri.parse(requestUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = jsonDecode(response.body);
      if (result['status'] == 'OK' && result['results'].isNotEmpty) {
        return result['results'][0]['formatted_address'];
      } else {
        print('Reverse Geocoding Error: ${result['status']}');
      }
    } else {
      print('Failed to fetch place name: ${response.statusCode}');
    }
    return null;
  }

  void _setMarker(LatLng point) async {
    setState(() {
      _markers.clear();
      _markers.add(Marker(
        markerId: const MarkerId('selectedWaypoint'),
        position: point,
      ));
      selectedWaypoint = point;
    });

    String? placeName = await _getPlaceNameFromCoordinates(point.latitude, point.longitude);
    if (placeName != null) {
      setState(() {
        _searchController.text = placeName;
        selectedWaypointDescription = placeName;
      });
    } else {
      print('Unable to find place name for tapped coordinates.');
    }
  }

  Future<void> _goToPlace(Map<String, dynamic> place, String description) async {
    if (place.containsKey('latitude') && place.containsKey('longitude')) {
      final double lat = place['latitude'];
      final double lng = place['longitude'];

      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, lng),
          zoom: 14,
        ),
      ));

      _setMarker(LatLng(lat, lng));
      setState(() {
        selectedWaypointDescription = description;
        _searchController.text = description;
      });

      print('Selected Location: Latitude = $lat, Longitude = $lng');
    }
  }

  Future<void> _handleSearchTap(BuildContext context) async {
    final Suggestion? result = await showSearch(
      context: context,
      delegate: AddressSearch(sessionToken),
    );

    if (result != null) {
      var placeDetails = await PlaceApiProvider(sessionToken).getPlaceDetailFromId(result.placeId);
      _goToPlace(placeDetails, result.description);
    }
  }

  Future<void> _confirmWaypoint() async {
    if (selectedWaypoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location.')),
      );
    } else {
      Navigator.pop(context, {
        'latLng': selectedWaypoint,
        'description': selectedWaypointDescription,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Waypoint"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.check),
        //     tooltip: 'Confirm',
        //     onPressed: _confirmWaypoint,
        //   ),
        // ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) => _mapController.complete(controller),
            initialCameraPosition: const CameraPosition(target: LatLng(7.8731, 80.7718), zoom: 6),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onTap: (LatLng tappedPoint) {
              _setMarker(tappedPoint);
            },
            padding: EdgeInsets.symmetric(vertical: 60.0),
          ),
          Positioned(
            top: 8.0,
            left: 8.0,
            right: 8.0,
            child: Container(
              color: Colors.white.withOpacity(0.9),
              child: TextField(
                controller: _searchController,
                readOnly: true,
                onTap: () => _handleSearchTap(context),
                decoration: const InputDecoration(
                  hintText: 'Search for a location',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50.0,
                color: Colors.transparent,
                child:
                ElevatedButton(
                  onPressed: _confirmWaypoint,
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                  ),
                  child: Text(
                      "Confirm Waypoint Location",
                      style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)
                  ),
                ),

              ),
            ),
          ),
        ],
      ),
    );
  }
}










// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:uuid/uuid.dart';
// import 'package:http/http.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
// import '../../../services/map/place_service.dart';
// import '../../map/places_search_screen.dart';
// import 'package:http/http.dart';
// // import '../../services/map/place_service.dart';
// // import 'places_search_screen.dart';
//
// class SelectWaypointsScreen extends StatefulWidget {
//   final String waypointLabel;
//
//   const SelectWaypointsScreen({Key? key, required this.waypointLabel}) : super(key: key);
//
//   @override
//   _SelectWaypointsScreenState createState() => _SelectWaypointsScreenState();
// }
//
// class _SelectWaypointsScreenState extends State<SelectWaypointsScreen> {
//   final Completer<GoogleMapController> _mapController = Completer();
//   final TextEditingController _searchController = TextEditingController();
//   Set<Marker> _markers = {};
//   LatLng? selectedWaypoint;
//   String? selectedWaypointDescription;
//   final String sessionToken = const Uuid().v4();
//
//   @override
//   void initState() {
//     super.initState();
//     _getInitialMapLocation();
//   }
//
//   Future<void> _getInitialMapLocation() async {
//     final GoogleMapController controller = await _mapController.future;
//     controller.animateCamera(CameraUpdate.newCameraPosition(const CameraPosition(
//       target: LatLng(0, 0), // Adjust this to your default location or center
//       zoom: 2,
//     )));
//   }
//
//   Future<String?> _getPlaceNameFromCoordinates(double latitude, double longitude) async {
//
//     final client = Client();
//
//     final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'YOUR_DEFAULT_API_KEY';
//     final String requestUrl = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';
//     final response = await client.get(Uri.parse(requestUrl));
//
//     if (response.statusCode == 200) {
//       final Map<String, dynamic> result = jsonDecode(response.body);
//       if (result['status'] == 'OK' && result['results'].isNotEmpty) {
//         return result['results'][0]['formatted_address'];
//       } else {
//         print('Reverse Geocoding Error: ${result['status']}');
//       }
//     } else {
//       print('Failed to fetch place name: ${response.statusCode}');
//     }
//     return null;
//   }
//
//   void _setMarker(LatLng point) async {
//     setState(() {
//       _markers.clear();
//       _markers.add(Marker(
//         markerId: const MarkerId('selectedWaypoint'),
//         position: point,
//       ));
//       selectedWaypoint = point;
//     });
//
//     // Retrieve and update the place name
//     String? placeName = await _getPlaceNameFromCoordinates(point.latitude, point.longitude);
//     if (placeName != null) {
//       setState(() {
//         _searchController.text = placeName;
//         selectedWaypointDescription = placeName;
//       });
//     } else {
//       print('Unable to find place name for tapped coordinates.');
//     }
//
//     // Print the tapped coordinates for verification
//     print('Tapped Location: Latitude = ${point.latitude}, Longitude = ${point.longitude}');
//   }
//
//   Future<void> _goToPlace(Map<String, dynamic> place, String description) async {
//     if (place.containsKey('latitude') && place.containsKey('longitude')) {
//       final double lat = place['latitude'];
//       final double lng = place['longitude'];
//
//       final GoogleMapController controller = await _mapController.future;
//       controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
//         target: LatLng(lat, lng),
//         zoom: 14,
//       )));
//
//       _setMarker(LatLng(lat, lng));
//       setState(() {
//         selectedWaypointDescription = description;
//         _searchController.text = description;
//       });
//
//       // Print the selected coordinates for verification
//       print('Selected Location: Latitude = $lat, Longitude = $lng');
//     }
//   }
//
//   Future<void> _handleSearchTap(BuildContext context) async {
//     final Suggestion? result = await showSearch(
//       context: context,
//       delegate: AddressSearch(sessionToken),
//     );
//
//     if (result != null) {
//       var placeDetails = await PlaceApiProvider(sessionToken).getPlaceDetailFromId(result.placeId);
//       _goToPlace(placeDetails, result.description);
//     }
//   }
//
//   Future<void> _confirmWaypoint() async {
//     if (selectedWaypoint == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a location.')),
//       );
//     } else {
//       Navigator.pop(context, {
//         'latLng': selectedWaypoint,
//         'description': selectedWaypointDescription,
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Select Waypoint"),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//         elevation: 0.5,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.check),
//             tooltip: 'Confirm',
//             onPressed: _confirmWaypoint,
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             onMapCreated: (GoogleMapController controller) => _mapController.complete(controller),
//             initialCameraPosition: const CameraPosition(target: LatLng(0, 0), zoom: 2),
//             markers: _markers,
//             myLocationEnabled: true,
//             myLocationButtonEnabled: true,
//             onTap: (LatLng tappedPoint) {
//               // Update the selected waypoint using a tap on the map
//               _setMarker(tappedPoint);
//             },
//           ),
//           Positioned(
//             top: 8.0,
//             left: 8.0,
//             right: 8.0,
//             child: Container(
//               color: Colors.white.withOpacity(0.9),
//               child: TextField(
//                 controller: _searchController,
//                 readOnly: true,
//                 onTap: () => _handleSearchTap(context),
//                 decoration: const InputDecoration(
//                   hintText: 'Search for a location',
//                   prefixIcon: Icon(Icons.search),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
