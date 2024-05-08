import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart'; // TODO - use Dio package
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import '../../../models/offer_ride.dart';

import '../../ride/ride_options_screen.dart';

class ConfirmRoute extends StatefulWidget {
  final LatLng? pickupLocation;
  final LatLng? dropoffLocation;

  const ConfirmRoute(
      {super.key, required this.pickupLocation, required this.dropoffLocation});

  @override
  State<ConfirmRoute> createState() => _ConfirmRouteState();
}

class _ConfirmRouteState extends State<ConfirmRoute> {
  OfferRide ride = OfferRide();

  final client = Client();

  Location _locationController = new Location();

  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  late LatLng _kPickupLocation;
  late LatLng _kDropLocation;
  LatLng? _currentP = null;

  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // RideProvider rideProvider = Provider.of<RideProvider>(context, listen: false);
    _kPickupLocation = widget.pickupLocation!;
    _kDropLocation = widget.dropoffLocation!;

    // getTotalDistanceAndDuration();

    // TODO - try to use traffic api??

    _initializeRideDistance();


    // getDirections();
    // _fetchDirectionsAndPolylines();
    print("INSIDEEEEE Singleton CONFIRMMMM ROUTEEEEEEE${ride.pickupLocation}");

    getPolylinePoints().then((coordinates) {
      // rideProvider.updatePolylinePoints(coordinates);
      ride.polylinePoints = coordinates;
      generatePolylineFromPoints(coordinates);
    });
  }

  void _initializeRideDistance() async {
    print("INITIAAAAAAAAAAAAAAAALIZEEE METHOD CALLEDdd");
    Map<String, dynamic> result = await getTotalDistanceAndDuration();
    double distance =
        result['distance']; // Assuming 'distance' is the key in the map
    // ride.rideDistance = distance;

    // Get duration without converting
    Map<String, int> duration = result['duration'];
    int? hours = duration['hours'];
    int? minutes = duration['minutes'];

    ride.rideDuration = "${hours.toString()} ${minutes.toString()}";

    print("ride from distance in ride: ${ride.rideDistance}");
    print("ride from DURATION in ride: $hours hours and $minutes minutes");
  }

  @override
  void dispose() {
    // Remove polyline points when the user goes back without confirming
    ride.resetPolylinePoints();

    super.dispose();
  }

  // Future<void> _fetchDirectionsAndPolylines() async {
  //   List<Map<String, dynamic>> results = await getDirections();
  //   for (var i = 0; i < results.length; i++) {
  //     List<LatLng> polylineCoordinates = decodePolyline(results[i]['polyline']);
  //     generatePolylineFromPoints(polylineCoordinates, i.toString());
  //   }
  // }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    List<PointLatLng> decoded = PolylinePoints().decodePolyline(encoded);
    for (var point in decoded) {
      polyline.add(LatLng(point.latitude, point.longitude));
    }
    return polyline;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Back button icon
          onPressed: () {
            Navigator.pop(context); // Handle back navigation
          },
        ),
        title: Text("Confirm Route"),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: ((GoogleMapController controller) =>
                  _mapController.complete(controller)),
              initialCameraPosition: CameraPosition(
                target: _kPickupLocation,
                zoom: 10.8,
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
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 50.0,
                  color: Colors.transparent,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.green),
                    ),
                    onPressed: () {
                      // _confirmPickupLocation(pickedLatitude, pickedLongitude  , _textController.text);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RideOptions(),
                        ),
                      );
                    },
                    child: Text("Confirm Route",
                        style: TextStyle(
                            fontSize: 14.0, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getApiKey() {
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'YOUR_DEFAULT_API_KEY';
  }

  Future<List<LatLng>> getPolylinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      _getApiKey(),
      PointLatLng(_kPickupLocation.latitude, _kPickupLocation.longitude),
      PointLatLng(_kDropLocation.latitude, _kDropLocation.longitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );
      });
    } else {
      print(result.errorMessage);
    }
    return polylineCoordinates;
  }

  void generatePolylineFromPoints(List<LatLng> polylineCoordinates) async {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.black,
      points: polylineCoordinates,
      width: 8,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  // void generatePolylineFromPoints(List<LatLng> polylineCoordinates, String id) async {
  //   PolylineId polylineId = PolylineId(id); // Unique PolylineId for each polyline
  //   Polyline polyline = Polyline(
  //     polylineId: polylineId,
  //     color: Colors.black,
  //     points: polylineCoordinates,
  //     width: 8,
  //   );
  //   setState(() {
  //     polylines[polylineId] = polyline; // Use polylineId instead of const PolylineId("poly")
  //   });
  // }

  // Future<Map<String, dynamic>> getTotalDistanceAndDuration() async {
  //   Map<String, dynamic> result = {};
  //   final apiKey = _getApiKey();
  //   String url =
  //       'https://maps.googleapis.com/maps/api/directions/json?origin=${_kPickupLocation.latitude},${_kPickupLocation.longitude}&destination=${_kDropLocation.latitude},${_kDropLocation.longitude}&alternatives=true&key=$apiKey';
  //
  //   var response = await client.get(Uri.parse(url));
  //   var json = jsonDecode(response.body);
  //
  //   if (json['status'] == 'OK') {
  //     double totalDistance = 0.0;
  //     int totalDuration = 0;
  //     for (var route in json['routes']) {
  //       for (var leg in route['legs']) {
  //         totalDistance += double.parse(leg['distance']['value'].toString());
  //         totalDuration += int.parse(leg['duration']['value'].toString());
  //       }
  //     }
  //
  //     // Convert distance from meters to kilometers
  //     totalDistance /= 1000;
  //
  //     result['distance'] = totalDistance;
  //     result['duration'] = totalDuration;
  //
  //     print("Totlaaaaaaa:LLLLLLLL disatance: $totalDistance");
  //     print("TOOOOOOOOOOOOOOTAAAAAAAAAAAAAAAAL DURATTTTTIOM TIMEEEEEE: $totalDuration");
  //   } else {
  //     print("Failed to fetch directions: ${json['status']}");
  //   }
  //
  //   return result;
  // }

  Future<Map<String, dynamic>> getTotalDistanceAndDuration() async {
    Map<String, dynamic> result = {};
    final apiKey = _getApiKey();
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_kPickupLocation.latitude},${_kPickupLocation.longitude}&destination=${_kDropLocation.latitude},${_kDropLocation.longitude}&alternatives=true&mode=driving&key=$apiKey';

    var response = await client.get(Uri.parse(url));
    var json = jsonDecode(response.body);

    if (json['status'] == 'OK') {
      double totalDistance = 0.0;
      int totalDuration = 0;
      for (var route in json['routes']) {
        for (var leg in route['legs']) {
          totalDistance += double.parse(leg['distance']['value'].toString());
          totalDuration += int.parse(leg['duration']['value'].toString());
        }
      }

      // Convert distance from meters to kilometers
      totalDistance /= 1000;

      // Convert duration from seconds to hours and minutes
      int hours = totalDuration ~/ 3600;
      int minutes = (totalDuration % 3600) ~/ 60;

      result['distance'] = totalDistance;
      result['duration'] = {'hours': hours, 'minutes': minutes};

      print("Totlaaaaaaa:LLLLLLLL disatance: $totalDistance");
      print(
          "TOOOOOOOOOOOOOOTAAAAAAAAAAAAAAAAL DURATTTTTIOM TIMEEEEEE: $result['duration']");
    } else {
      print("Failed to fetch directions: ${json['status']}");
    }

    return result;
  }

  // Future<double> getTotalDistance() async {
  //   double totalDistance = 0.0;
  //   final apiKey = _getApiKey();
  //   String url =
  //       'https://maps.googleapis.com/maps/api/directions/json?origin=${_kPickupLocation.latitude},${_kPickupLocation.longitude}&destination=${_kDropLocation.latitude},${_kDropLocation.longitude}&alternatives=true&key=$apiKey';
  //
  //   var response = await client.get(Uri.parse(url));
  //   var json = jsonDecode(response.body);
  //
  //   if (json['status'] == 'OK') {
  //     for (var route in json['routes']) {
  //       for (var leg in route['legs']) {
  //         totalDistance += double.parse(leg['distance']['value'].toString());
  //       }
  //     }
  //   } else {
  //     print("Failed to fetch directions: ${json['status']}");
  //   }
  //
  //   // Convert distance from meters to kilometers
  //   totalDistance /= 1000;
  //
  //   print("totaaaaaaaaaaaal distanceeeeee FRRRRROMMMMMMMMMMMM JOTUNRY: $totalDistance");
  //
  //   return totalDistance;
  // }

  // Future<List<Map<String, dynamic>>> getDirections() async {
  //   // final client = Client();
  //   final apiKey = _getApiKey();
  //   String url =
  //       'https://maps.googleapis.com/maps/api/directions/json?origin=7.412487,79.859083&destination=7.2000,79.8737&alternatives=true&key=$apiKey';
  //
  //   var response = await client.get(Uri.parse(url));
  //   var json = jsonDecode(response.body);
  //
  //   List<Map<String, dynamic>> results = [];
  //
  //   if (json['status'] == 'OK') {
  //     for (var route in json['routes']) {
  //       var routeDetails = {
  //         'bounds_ne': route['bounds']['northeast'],
  //         'bounds_sw': route['bounds']['southwest'],
  //         'start_location': route['legs'][0]['start_location'],
  //         'end_location': route['legs'][0]['end_location'],
  //         'polyline': route['overview_polyline']['points'],
  //       };
  //
  //       results.add(routeDetails);
  //     }
  //   }
  //
  //   print("RESULLLLLLLLLLLLLTSSSSSSSSSSSSSSSS -${results.length}");
  //   return results;
  // }

// Future<Map<String, dynamic>> getDirections() async{
//   final client = Client();
//
//   const String url =
//       'https://maps.googleapis.com/maps/api/directions/json?origin=7.412487,79.859083&destination=7.2000,79.8737&alternatives=true&key=$GOOGLE_MAPS_API_KEY';
//
//   var response = await client.get(Uri.parse(url));
//   var json = jsonDecode(response.body);
//
//   var results = {
//     'bounds_ne' : json['routes'][0]['bounds']['northeast'],
//     'bounds_sw' : json['routes'][0]['bounds']['southwest'],
//     'start_location' : json['routes'][0]['legs'][0]['start_location'],
//     'end_location' : json['routes'][0]['legs'][0]['end_location'],
//     'polyline' : json['routes'][0]['overview_polyline']['points'],
//   };
//
//   print(results);
//   return results;
// }
}
