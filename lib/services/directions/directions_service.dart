import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class DirectionsService {
  final client = Client();

  String _getApiKey() {
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'YOUR_DEFAULT_API_KEY';
  }

  // Future<List<Map<String, dynamic>>> getDirections(LatLng pickupLocation, LatLng dropoffLocation) async {
  //   final apiKey = _getApiKey();
  //   String url =
  //       'https://maps.googleapis.com/maps/api/directions/json?origin=${pickupLocation.latitude},${pickupLocation.longitude}&destination=${dropoffLocation.latitude},${dropoffLocation.longitude}&alternatives=true&mode=driving&key=$apiKey';
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
  //   print("RESULLLLLLLLLLLLLTSSSSSSSSSSSSSSSS ${results.length}");
  //   return results;
  // }

  // Future<List<Map<String, dynamic>>> getDirections(
  //     LatLng pickupLocation, LatLng dropoffLocation) async {
  //   final apiKey = _getApiKey();
  //   String url = 'https://routes.googleapis.com/directions/v2:computeRoutes';
  //
  //   Map<String, dynamic> requestBody = {
  //     "origin": {
  //       "location": {
  //         "latLng": {
  //           "latitude": pickupLocation.latitude,
  //           "longitude": pickupLocation.longitude
  //         }
  //       }
  //     },
  //     "destination": {
  //       "location": {
  //         "latLng": {
  //           "latitude": dropoffLocation.latitude,
  //           "longitude": dropoffLocation.longitude
  //         }
  //       }
  //     },
  //     "travelMode": "DRIVE",
  //     "routingPreference": "TRAFFIC_AWARE_OPTIMAL",
  //     // "departureTime": "2024-04-08T15:01:23.045123456Z",
  //     "computeAlternativeRoutes": true,
  //     // "routeModifiers": {
  //     //   "avoidTolls": false,
  //     //   "avoidHighways": false,
  //     //   "avoidFerries": false
  //     // },
  //     "languageCode": "en-US",
  //     "units": "IMPERIAL"
  //   };
  //
  //   var response = await client.post(
  //     Uri.parse(url),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'X-Goog-Api-Key': apiKey,
  //       'X-Goog-FieldMask':
  //       'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline,routes.legs.polyline.encodedPolyline,routes.legs.steps.polyline.encodedPolyline', // Field mask to include specific fields in the response
  //     },
  //     body: jsonEncode(requestBody),
  //   );
  //
  //   var json = jsonDecode(response.body);
  //
  //   print(json);
  //
  //   List<Map<String, dynamic>> results = [];
  //
  //   if (json['routes'] != null) {
  //     for (var route in json['routes']) {
  //       var routeDetails = {
  //         'distance': route['distanceMeters'],
  //         'duration': route['duration'],
  //         'polyline': route['polyline']['encodedPolyline'],
  //       };
  //
  //       if (route['legs'] != null) {
  //         List<String> legPolylines = [];
  //         for (var leg in route['legs']) {
  //           if (leg['polyline'] != null) {
  //             legPolylines.add(leg['polyline']['encodedPolyline']);
  //           }
  //           if (leg['steps'] != null) {
  //             for (var step in leg['steps']) {
  //               if (step['polyline'] != null) {
  //                 legPolylines.add(step['polyline']['encodedPolyline']);
  //               }
  //             }
  //           }
  //         }
  //         routeDetails['legPolylines'] = legPolylines;
  //       }
  //
  //       results.add(routeDetails);
  //     }
  //   }
  //
  //   print("Number of routes found: ${results.length}");
  //   return results;
  // }

  /////////// currentlyyyyy workinggggggggggggggggggggg 4/24/2024
  // Future<List<Map<String, dynamic>>> getDirections(
  //     LatLng pickupLocation, LatLng dropoffLocation) async {
  //   final apiKey = _getApiKey();
  //   String url = 'https://routes.googleapis.com/directions/v2:computeRoutes';
  //
  //   Map<String, dynamic> requestBody = {
  //     "origin": {
  //       "location": {
  //         "latLng": {
  //           "latitude": pickupLocation.latitude,
  //           "longitude": pickupLocation.longitude
  //         }
  //       }
  //     },
  //     "destination": {
  //       "location": {
  //         "latLng": {
  //           "latitude": dropoffLocation.latitude,
  //           "longitude": dropoffLocation.longitude
  //         }
  //       }
  //     },
  //     "travelMode": "DRIVE",
  //     "routingPreference": "TRAFFIC_AWARE_OPTIMAL",
  //     // "departureTime": "2024-04-08T15:01:23.045123456Z",
  //     "computeAlternativeRoutes": true,
  //     // "routeModifiers": {
  //     //   "avoidTolls": false,
  //     //   "avoidHighways": false,
  //     //   "avoidFerries": false
  //     // },
  //     "languageCode": "en-US",
  //     "units": "IMPERIAL"
  //   };
  //
  //   var response = await client.post(
  //     Uri.parse(url),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'X-Goog-Api-Key': apiKey,
  //       'X-Goog-FieldMask':
  //       'routes.duration,routes.description,routes.distanceMeters,routes.polyline.encodedPolyline,routes.legs.polyline.encodedPolyline,routes.legs.steps.polyline.encodedPolyline', // Field mask to include specific fields in the response
  //     },
  //     body: jsonEncode(requestBody),
  //   );
  //
  //   var json = jsonDecode(response.body);
  //
  //   print(json);
  //
  //   List<Map<String, dynamic>> results = [];
  //
  //   if (json['routes'] != null) {
  //     for (var route in json['routes']) {
  //       var routeDetails = {
  //         // 'summary': route['summary'],
  //         'distance': route['distanceMeters'],
  //         'duration': route['duration'],
  //         'polyline': route['polyline']['encodedPolyline'],
  //         'description': route['description'],
  //       };
  //
  //       if (route['legs'] != null) {
  //         List<String> legPolylines = [];
  //         for (var leg in route['legs']) {
  //           if (leg['polyline'] != null) {
  //             legPolylines.add(leg['polyline']['encodedPolyline']);
  //             // print("Leg polyline: ${leg['polyline']['encodedPolyline']}");
  //           }
  //           if (leg['steps'] != null) {
  //             for (var step in leg['steps']) {
  //               if (step['polyline'] != null) {
  //                 legPolylines.add(step['polyline']['encodedPolyline']);
  //                 // print("Step polyline: ${step['polyline']['encodedPolyline']}");
  //               }
  //             }
  //           }
  //         }
  //         routeDetails['legPolylines'] = legPolylines;
  //       }
  //
  //       results.add(routeDetails);
  //     }
  //   }
  //
  //   print("Number of routes found: ${results.length}");
  //   return results;
  // }

  String formatDepartureTime(DateTime dateTime) {
    // Format the DateTime as an ISO 8601 string, adjusted to UTC.
    return DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(dateTime.toUtc());
  }

  DateTime calculateArrivalTime(DateTime departureTime, int durationInSeconds) {
    return departureTime.add(Duration(seconds: durationInSeconds));
  }


////// updated and working route description
  Future<List<Map<String, dynamic>>> getDirections(
      LatLng pickupLocation, LatLng dropoffLocation, List<LatLng>? waypoints, {
        bool avoidHighways = false,
        bool avoidTolls = false,
        bool avoidFerries = false,
      }) async {
    final apiKey = _getApiKey();

    // String formattedDepartureTime = formatDepartureTime(departureTime);
    // debugPrint("DEPPPPP TIMEEEE: $formattedDepartureTime");
    // // "departureTime": "2024-04-08T15:01:23.045123456Z",

    String url = 'https://routes.googleapis.com/directions/v2:computeRoutes';

    // Prepare waypoints if available
    List<Map<String, dynamic>> intermediatePoints = [];
    if (waypoints != null && waypoints.isNotEmpty) {
      intermediatePoints = waypoints.map((point) {
        return {
          "location": {
            "latLng": {
              "latitude": point.latitude,
              "longitude": point.longitude,
            },
          },
        };
      }).toList();
    }

    // Determine the routing preference based on the provided parameters
    String routingPreference = "TRAFFIC_AWARE_OPTIMAL";
    if (avoidHighways || avoidTolls || avoidFerries) {
      routingPreference = "TRAFFIC_AWARE";
    }

    // Additional travel advisories to avoid tolls, highways, ferries
    List<String> travelAdvisories = [];
    if (avoidHighways) travelAdvisories.add("AVOID_HIGHWAYS");
    if (avoidTolls) travelAdvisories.add("AVOID_TOLLS");
    if (avoidFerries) travelAdvisories.add("AVOID_FERRIES");


    Map<String, dynamic> requestBody = {
      "origin": {
        "location": {
          "latLng": {
            "latitude": pickupLocation.latitude,
            "longitude": pickupLocation.longitude
          }
        }
      },
      "destination": {
        "location": {
          "latLng": {
            "latitude": dropoffLocation.latitude,
            "longitude": dropoffLocation.longitude
          }
        }
      },
      "travelMode": "DRIVE",
      // "departureTime": formattedDepartureTime,
      "routingPreference": "TRAFFIC_AWARE_OPTIMAL",
      "computeAlternativeRoutes": true,
      "languageCode": "en-US",
      "units": "IMPERIAL"
    };

    // Add waypoints only if there are any
    if (intermediatePoints.isNotEmpty) {
      requestBody["intermediates"] = intermediatePoints;
    }

    // Add travel advisories if present
    if (travelAdvisories.isNotEmpty) {
      requestBody["routeModifiers"] = {
        "avoidTolls": avoidTolls,
        "avoidHighways": avoidHighways,
        "avoidFerries": avoidFerries,
      };
    }

    var response = await client.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask': 'routes(routeLabels,legs,distanceMeters,duration,staticDuration,polyline,description,warnings,viewport,travelAdvisory,optimizedIntermediateWaypointIndex,localizedValues,routeToken)',
      },
      body: jsonEncode(requestBody),
    );

    // Check response status and log errors
    if (response.statusCode != 200) {
      debugPrint("API Request failed with status: ${response.statusCode}");
      debugPrint("Error response body: ${response.body}");
      return [];
    }

    var json = jsonDecode(response.body);

    List<Map<String, dynamic>> results = [];

    if (json['routes'] != null) {



      for (var route in json['routes']) {
        // int durationSeconds = int.tryParse(route['duration']) ?? 0;
        // DateTime arrivalTime = calculateArrivalTime(departureTime, durationSeconds);
        var routeDetails = {
          'distance': route['distanceMeters'],
          'duration': route['duration'],
          'description': route['description'], // Extracting the description
          'polyline': route['polyline']['encodedPolyline'],
          // 'arrivalTime': arrivalTime.toIso8601String(),
        };

        // Debug print the description of each route
        print("Route Description: ${route['description']}");
        print("Route Arrival Time: ${route['arrivalTime']}");

        if (route['legs'] != null) {
          List<String> legPolylines = [];
          for (var leg in route['legs']) {
            if (leg['polyline'] != null) {
              legPolylines.add(leg['polyline']['encodedPolyline']);
            }
            // Additional steps parsing could be here if needed
          }
          routeDetails['legPolylines'] = legPolylines;
        }

        results.add(routeDetails);
      }
    }

    print("Number of routes found: ${results.length}");
    return results;
  }









  Future<List<Map<String, dynamic>>> getRouteDirections(
      LatLng pickupLocation, LatLng dropoffLocation) async {
    final apiKey = _getApiKey();

    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${pickupLocation.latitude},${pickupLocation.longitude}&destination=${dropoffLocation.latitude},${dropoffLocation.longitude}&mode=driving&alternatives=true&departure_time=now&key=$apiKey');

    var response = await client.get(url);

    // Check response status code
    print('Response Status Code: ${response.statusCode}');

    // Check response body
    print('Response Body: ${response.body}');

    var data = jsonDecode(response.body);
    List<Map<String, dynamic>> results = [];

    // Debug point: Check if routes are present in the response
    if (data['routes'] != null) {
      print('Number of routes returned: ${data['routes'].length}');
      for (var route in data['routes']) {
        var routeDetails = {
          'summary': route['summary'],
          'duration': route['legs'][0]['duration']['text'],
          'distance': route['legs'][0]['distance']['text'],
          'steps': [],
          'polyline': route['overview_polyline']['points']
        };

        for (var step in route['legs'][0]['steps']) {
          var stepDetails = {
            'distance': step['distance']['text'],
            'duration': step['duration']['text'],
            'instruction': step['html_instructions'],
            'travel_mode': step['travel_mode']
          };
          routeDetails['steps'].add(stepDetails);
        }

        // Debug point: Print summary for each route
        print('Route Summary: ${routeDetails['summary']}');
        results.add(routeDetails);
      }
    } else {
      print('No routes found.');
    }

    // Debug point: Print summary of all routes
    print('Summary of all routes:');
    for (var result in results) {
      print('Route Summary: ${result['summary']}');
    }

    return results;
  }



  // Future<Map<String, dynamic>> getTotalDistanceAndDuration(
  //     LatLng pickupLocation, LatLng dropoffLocation) async {
  //   Map<String, dynamic> result = {};
  //   final apiKey = _getApiKey();
  //   String url =
  //       'https://maps.googleapis.com/maps/api/directions/json?origin=${pickupLocation.latitude},${pickupLocation.longitude}&destination=${dropoffLocation.latitude},${dropoffLocation.longitude}&alternatives=true&mode=driving&key=$apiKey';
  //
  //   var response = await client.get(Uri.parse(url));
  //   var json = jsonDecode(response.body);
  //
  //   if (json['status'] == 'OK') {
  //     double totalDistance = 0.0;
  //     int totalDuration = 0;
  //     String summary = "";
  //
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
  //     // Convert duration from seconds to hours and minutes
  //     int hours = totalDuration ~/ 3600;
  //     int minutes = (totalDuration % 3600) ~/ 60;
  //
  //     result['distance'] = totalDistance;
  //     result['duration'] = {'hours': hours, 'minutes': minutes};
  //
  //     // Extract summary of the route
  //     if (json['routes'] != null && json['routes'].isNotEmpty) {
  //       summary = json['routes'][0]['summary'];
  //     }
  //
  //     result['summary'] = summary; // Add summary to the result
  //
  //     print("Total distance: $totalDistance km");
  //     print("Total duration: $hours hours $minutes minutes");
  //     print("Summary: $summary");
  //   } else {
  //     print("Failed to fetch directions: ${json['status']}");
  //   }
  //
  //   return result;
  // }

  // Future<Map<String, dynamic>> getTotalDistanceAndDuration(
  //     LatLng pickupLocation, LatLng dropoffLocation) async {
  //   Map<String, dynamic> result = {};
  //   final apiKey = _getApiKey();
  //   String url =
  //       'https://maps.googleapis.com/maps/api/directions/json?origin=${pickupLocation.latitude},${pickupLocation.longitude}&destination=${dropoffLocation.latitude},${dropoffLocation.longitude}&alternatives=true&mode=driving&key=$apiKey';
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
  //     // Convert duration from seconds to hours and minutes
  //     int hours = totalDuration ~/ 3600;
  //     int minutes = (totalDuration % 3600) ~/ 60;
  //
  //     result['distance'] = totalDistance;
  //     result['duration'] = {'hours': hours, 'minutes': minutes};
  //
  //     print("Totlaaaaaaa:LLLLLLLL disatance: $totalDistance");
  //     print(
  //         "TOOOOOOOOOOOOOOTAAAAAAAAAAAAAAAAL DURATTTTTIOM TIMEEEEEE: $result['duration']");
  //   } else {
  //     print("Failed to fetch directions: ${json['status']}");
  //   }
  //
  //   return result;
  // }

  Future<List<LatLng>> getPolylinePoints(
      LatLng pickupLocation, LatLng dropoffLocation) async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      _getApiKey(),
      PointLatLng(pickupLocation.latitude, pickupLocation.longitude),
      PointLatLng(dropoffLocation.latitude, dropoffLocation.longitude),
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

// for mu;tiple routes?

// Future<void> _fetchDirectionsAndPolylines() async {
//   List<Map<String, dynamic>> results = await getDirections();
//   for (var i = 0; i < results.length; i++) {
//     List<LatLng> polylineCoordinates = decodePolyline(results[i]['polyline']);
//     generatePolylineFromPoints(polylineCoordinates, i.toString());
//   }
// }

// List<LatLng> decodePolyline(String encoded) {
//   List<LatLng> polyline = [];
//   List<PointLatLng> decoded = PolylinePoints().decodePolyline(encoded);
//   for (var point in decoded) {
//     polyline.add(LatLng(point.latitude, point.longitude));
//   }
//   return polyline;
// }
}
