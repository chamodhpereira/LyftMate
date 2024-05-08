import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideMatching {

  final client = Client();

  String _getApiKey() {
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'YOUR_DEFAULT_API_KEY';
  }

  Future<List<Map<String, dynamic>>> findRidesWithDistances(
      LatLng userPickupLocation, LatLng userDropoffLocation,) async {
    List<Map<String, dynamic>> ridesWithDistances = [];

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('rides')
          .get();
      List<DocumentSnapshot> rides = snapshot.docs;

      // Filter rides based on drop-off location matching the user's drop-off location
      List<DocumentSnapshot> filteredRides = rides.where((ride) {
        GeoPoint dropoffLocation = ride['dropoffLocation']['geopoint'];

        return dropoffLocation.latitude == userDropoffLocation.latitude &&
            dropoffLocation.longitude == userDropoffLocation.longitude;
      }).toList();

      if (filteredRides.isEmpty) {
        final GeoFirePoint geoPoint =
        GeoFirePoint(userDropoffLocation.latitude, userDropoffLocation.longitude);
        String userDropoffGeohash = geoPoint.hash;
        userDropoffGeohash = userDropoffGeohash.substring(0, 5);

        filteredRides = rides.where((ride) {
          String rideDropoffGeohash =
          ride['dropoffLocation']['geohash'].substring(0, 5);
          return rideDropoffGeohash == userDropoffGeohash;
        }).toList();
      }

      print("FILETERRRRRREEEEEEEEEED DRIDESSSSSSSS: ${filteredRides.length}");

      const double distanceThreshold = 1000;

      for (var ride in filteredRides) {
        List<LatLng> polylineCoordinates = (ride['polylinePoints'] as List).map((point) {
          return LatLng(point['latitude'], point['longitude']);
        }).toList();

        List<LatLng> snappedPickupCoordinates = await callNearbySearchAPI(userPickupLocation);
        List<LatLng> snappedDropoffCoordinates = await callNearbySearchAPI(userDropoffLocation);

        double minPickupDistance = double.infinity;
        LatLng closestSnappedPickupCoordinate = LatLng(0, 0);
        LatLng closestSnappedDropoffCoordinate = LatLng(0, 0);

        for (LatLng snappedCoordinate in snappedPickupCoordinates) {
          for (LatLng polylineCoordinate in polylineCoordinates) {
            double distance = calculateDistance(
              snappedCoordinate.latitude,
              snappedCoordinate.longitude,
              polylineCoordinate.latitude,
              polylineCoordinate.longitude,
            );

            if (distance < minPickupDistance) {
              minPickupDistance = distance;
              // closestSnappedPickupCoordinate = snappedCoordinate;
              closestSnappedPickupCoordinate = polylineCoordinate;
            }
          }
        }

        double minDropoffDistance = double.infinity;

        for (LatLng snappedCoordinate in snappedDropoffCoordinates) {
          for (LatLng polylineCoordinate in polylineCoordinates) {
            double distance = calculateDistance(
              snappedCoordinate.latitude,
              snappedCoordinate.longitude,
              polylineCoordinate.latitude,
              polylineCoordinate.longitude,
            );

            if (distance < minDropoffDistance) {
              minDropoffDistance = distance;
              // closestSnappedDropoffCoordinate = snappedCoordinate;
              closestSnappedDropoffCoordinate = polylineCoordinate;
            }
          }
        }

        String pickupDistanceText = '${(minPickupDistance / 1000).toStringAsFixed(2)} km';
        print("PDT: $pickupDistanceText");
        String dropoffDistanceText = '${(minDropoffDistance / 1000).toStringAsFixed(2)} km';
        print("DDDDDDDDDDDDT: $dropoffDistanceText");

        print("MIN PICCCCK DIST: ${minPickupDistance}");
        print("DIST Threshold: ${distanceThreshold}");
        print("MIN DropDIST: ${minDropoffDistance}");
        print("DIST Threshold: ${distanceThreshold}");

        if (minPickupDistance < distanceThreshold && minDropoffDistance < distanceThreshold) {
          print("CHECKINGGG TRUEEEE");
          ridesWithDistances.add({
            'ride': ride,
            'pickupDistance': minPickupDistance,
            'dropoffDistance': minDropoffDistance,
            'pickupDistanceText': pickupDistanceText,
            'dropoffDistanceText': dropoffDistanceText,
            'closestSnappedPickupCoordinate': closestSnappedPickupCoordinate,
            'closestSnappedDropoffCoordinate': closestSnappedDropoffCoordinate,
          });
        }
      }

      return ridesWithDistances;

    } catch (e) {
      print("Error fetching rides: $e");
      return [];
    }
  }

  Future<List<LatLng>> callNearbySearchAPI(LatLng coordinate) async {
    final apiKey = _getApiKey();
    final String baseUrl = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

    // Construct the URL for the Nearby Search API request
    final String url = '$baseUrl?location=${coordinate.latitude},${coordinate.longitude}&radius=500&type=route&key=$apiKey';

    // Make the HTTP request
    final response = await client.get(Uri.parse(url));

    // Check if the response is successful
    if (response.statusCode == 200) {
      // Parse the JSON response
      final Map<String, dynamic> data = json.decode(response.body);

      // Extract route coordinates from the response
      List<LatLng> routeCoordinates = _extractRouteCoordinates(data);

      return routeCoordinates;
    } else {
      // If the request was not successful, throw an exception or handle the error accordingly
      throw Exception('Failed to load route coordinates');
    }
  }

// Helper method to extract route coordinates from the Nearby Search API response
  List<LatLng> _extractRouteCoordinates(Map<String, dynamic> data) {
    List<LatLng> routeCoordinates = [];

    // Extract the results array from the response
    List<dynamic> results = data['results'];

    // Iterate through the results array
    for (var result in results) {
      // Extract the location object from each result
      Map<String, dynamic> location = result['geometry']['location'];
      // Extract the latitude and longitude from the location object
      double latitude = location['lat'];
      double longitude = location['lng'];
      // Create a LatLng object and add it to the routeCoordinates list
      routeCoordinates.add(LatLng(latitude, longitude));
    }

    return routeCoordinates;
  }



  Future<List<LatLng>> snapToRoads(LatLng coordinate) async {
    final apiKey = _getApiKey();
    final String baseUrl = 'https://roads.googleapis.com/v1/snapToRoads';

    final String url =
        '$baseUrl?path=${coordinate.latitude},${coordinate.longitude}&key=$apiKey';

    final response = await client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> snappedPoints = data['snappedPoints'];

      // Check if there are snapped points returned
      if (snappedPoints.isNotEmpty) {
        // Extract latitude and longitude of each snapped point and create LatLng objects
        List<LatLng> snappedCoordinates = snappedPoints.map((point) {
          double latitude = point['location']['latitude'];
          double longitude = point['location']['longitude'];
          print('Snapped PPPPPPPoint: Latitude: $latitude, Longitude: $longitude');
          return LatLng(latitude, longitude);
        }).toList();

        return snappedCoordinates;
      }
    }

    // Return an empty list if snapping fails or no snapped points are returned
    return [];
  }

  double calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    const int earthRadius = 6371000; // in meters
    double lat1Rad = radians(startLatitude);
    double lon1Rad = radians(startLongitude);
    double lat2Rad = radians(endLatitude);
    double lon2Rad = radians(endLongitude);

    double deltaLat = lat2Rad - lat1Rad;
    double deltaLon = lon2Rad - lon1Rad;

    double a = math.pow(math.sin(deltaLat / 2), 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.pow(math.sin(deltaLon / 2), 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double radians(double degrees) {
    return degrees * (math.pi / 180);
  }
}

//  ------------------------------------------------ workingggggg but lines through buildings -------------------
// class RideMatching {
//   Future<List<Map<String, dynamic>>> findRidesWithDistances(GeoPoint userPickupLocation, GeoPoint userDropoffLocation) async {
//     List<Map<String, dynamic>> ridesWithDistances = [];
//
//     try {
//       QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('rides').get();
//       List<DocumentSnapshot> rides = snapshot.docs;
//
//       // Filter rides based on drop-off location matching the user's drop-off location
//       List<DocumentSnapshot> filteredRides = rides.where((ride) {
//         GeoPoint dropoffLocation = ride['dropoffLocation']['geopoint'];
//
//         return dropoffLocation.latitude == userDropoffLocation.latitude &&
//             dropoffLocation.longitude == userDropoffLocation.longitude;
//       }).toList();
//
//       if (filteredRides.isEmpty) {
//         final GeoFirePoint geoPoint =
//         GeoFirePoint(userDropoffLocation.latitude, userDropoffLocation.longitude);
//         String userDropoffGeohash = geoPoint.hash;
//         userDropoffGeohash = userDropoffGeohash.substring(0, 5);
//
//         filteredRides = rides.where((ride) {
//           String rideDropoffGeohash = ride['dropoffLocation']['geohash'].substring(0, 5);
//           return rideDropoffGeohash == userDropoffGeohash;
//         }).toList();
//       }
//
//       print("filtereeeeeeeeeeeeeeeeeeed ridesssssssssssgeooooo: ${filteredRides.length}");
//       // Adjust the threshold distance according to your preference
//       const double distanceThreshold = 1000; // meters
//
//       // Filter rides where the minimum distance of polyline route from the pickup location is within the threshold
//       // ---- working but no drop distance
//       // for (var ride in filteredRides) {
//       //   List<GeoPoint> polylinePoints = (ride['polylinePoints'] as List).map((point) {
//       //     return GeoPoint(point['latitude'], point['longitude']);
//       //   }).toList();
//       //
//       //   double minDistance = double.infinity;
//       //   GeoPoint nearestCoordinate = GeoPoint(0, 0);
//       //   String distanceText = 'N/A';
//       //
//       //   for (var point in polylinePoints) {
//       //     double distance = calculateDistance(
//       //       userPickupLocation.latitude,
//       //       userPickupLocation.longitude,
//       //       point.latitude,
//       //       point.longitude,
//       //     );
//       //
//       //     if (distance < minDistance) {
//       //       minDistance = distance;
//       //       nearestCoordinate = point;
//       //       distanceText = '${(minDistance / 1000).toStringAsFixed(2)} km';
//       //     }
//       //   }
//       //
//       //   if (minDistance < distanceThreshold) {
//       //     // Add ride with distances to the list
//       //     ridesWithDistances.add({
//       //       'ride': ride,
//       //       'pickupDistance': minDistance ,
//       //       'dropoffDistance': calculateDistance(
//       //         userDropoffLocation.latitude,
//       //         userDropoffLocation.longitude,
//       //         ride['dropoffLocation']['geopoint'].latitude,
//       //         ride['dropoffLocation']['geopoint'].longitude,
//       //       ),
//       //       'closestCoordinateToPickup' : nearestCoordinate,
//       //       'distanceText': distanceText,
//       //     });
//       //   }
//       // }
//
//       for (var ride in filteredRides) {
//         List<GeoPoint> polylinePoints = (ride['polylinePoints'] as List).map((point) {
//           return GeoPoint(point['latitude'], point['longitude']);
//         }).toList();
//
//         double minPickupDistance = double.infinity;
//         double minDropoffDistance = double.infinity;
//         GeoPoint nearestPickupCoordinate = GeoPoint(0, 0);
//         GeoPoint nearestDropoffCoordinate = GeoPoint(0, 0);
//         String pickupDistanceText = 'N/A';
//         String dropoffDistanceText = 'N/A';
//
//         for (var point in polylinePoints) {
//           double pickupDistance = calculateDistance(
//             userPickupLocation.latitude,
//             userPickupLocation.longitude,
//             point.latitude,
//             point.longitude,
//           );
//
//           if (pickupDistance < minPickupDistance) {
//             minPickupDistance = pickupDistance;
//             nearestPickupCoordinate = point;
//             pickupDistanceText = '${(minPickupDistance / 1000).toStringAsFixed(2)} km';
//           }
//
//           double dropoffDistance = calculateDistance(
//             userDropoffLocation.latitude,
//             userDropoffLocation.longitude,
//             point.latitude,
//             point.longitude,
//           );
//
//           if (dropoffDistance < minDropoffDistance) {
//             minDropoffDistance = dropoffDistance;
//             nearestDropoffCoordinate = point;
//             dropoffDistanceText = '${(minDropoffDistance / 1000).toStringAsFixed(2)} km';
//           }
//         }
//
//         if (minPickupDistance < distanceThreshold) {
//           // Add ride with distances to the list
//           ridesWithDistances.add({
//             'ride': ride,
//             'pickupDistance': minPickupDistance,
//             'dropoffDistance': minDropoffDistance,
//             'closestCoordinateToPickup': nearestPickupCoordinate,
//             'closestCoordinateToDropoff': nearestDropoffCoordinate,
//             'pickupDistanceText': pickupDistanceText,
//             'dropoffDistanceText': dropoffDistanceText,
//           });
//         }
//       }
//
//
//       return ridesWithDistances;
//
//       // // Calculate distances for each ride
//       // for (var ride in filteredRides) {
//       //   List<GeoPoint> polylinePoints = (ride['polylinePoints'] as List).map((point) {
//       //     return GeoPoint(point['latitude'], point['longitude']);
//       //   }).toList();
//       //
//       //   GeoPoint closestCoordinate = _findClosestCoordinate(polylinePoints, userPickupLocation);
//       //   double pickupDistance = calculateDistance(
//       //     userPickupLocation.latitude,
//       //     userPickupLocation.longitude,
//       //     closestCoordinate.latitude,
//       //     closestCoordinate.longitude,
//       //   );
//       //
//       //   // Calculate dropoff distance (assuming the dropoff point is stored in the ride document)
//       //   GeoPoint dropoffGeoPoint = ride['dropoffLocation']['geopoint'];
//       //   double dropoffDistance = calculateDistance(
//       //     userDropoffLocation.latitude,
//       //     userDropoffLocation.longitude,
//       //     dropoffGeoPoint.latitude,
//       //     dropoffGeoPoint.longitude,
//       //   );
//       //
//       //   // Add ride with distances to the list
//       //   ridesWithDistances.add({
//       //     'ride': ride,
//       //     'pickupDistance': pickupDistance,
//       //     'dropoffDistance': dropoffDistance,
//       //     'closestCoordinateToPickup' : closestCoordinate,
//       //   });
//       // }
//       //
//       // return ridesWithDistances;
//     } catch (e) {
//       print("Error fetching rides: $e");
//       return []; // Return empty list in case of error
//     }
//   }
//
//   Future<LatLng> snapToRoads(LatLng coordinate) async {
//     final String apiKey = 'YOUR_GOOGLE_MAPS_API_KEY'; // Replace with your Google Maps API key
//     final String baseUrl = 'https://roads.googleapis.com/v1/snapToRoads';
//
//     try {
//       // Construct the URL for the Snap to Roads API call
//       final String url =
//           '$baseUrl?path=${coordinate.latitude},${coordinate.longitude}&key=$apiKey';
//
//       // Send a GET request to the API
//       final response = await http.get(Uri.parse(url));
//
//       // Check if the response is successful (status code 200)
//       if (response.statusCode == 200) {
//         // Parse the response body (which contains the snapped points)
//         final Map<String, dynamic> data = json.decode(response.body);
//         final List<dynamic> snappedPoints = data['snappedPoints'];
//
//         // Check if there are snapped points returned
//         if (snappedPoints.isNotEmpty) {
//           // Extract the latitude and longitude of the first snapped point
//           final Map<String, dynamic> snappedPoint = snappedPoints[0];
//           final double latitude = snappedPoint['location']['latitude'];
//           final double longitude = snappedPoint['location']['longitude'];
//
//           // Return the snapped LatLng coordinate
//           return LatLng(latitude, longitude);
//         }
//       }
//
//       // Return the original coordinate if snapping fails or no snapped points are returned
//       return coordinate;
//     } catch (e) {
//       // Handle any errors that occur during the API call
//       print('Error occurred while snapping to roads: $e');
//       return coordinate; // Return the original coordinate in case of error
//     }
//   }
//
//   GeoPoint _findClosestCoordinate(List<GeoPoint> coordinates, GeoPoint userPickupLocation) {
//     double minDistance = double.infinity;
//     GeoPoint closestCoordinate = GeoPoint(0, 0); // Default value
//     for (var coord in coordinates) {
//       double distance = calculateDistance(
//         coord.latitude,
//         coord.longitude,
//         userPickupLocation.latitude,
//         userPickupLocation.longitude,
//       );
//       if (distance < minDistance && distance <= 1000) {
//         minDistance = distance;
//         closestCoordinate = coord;
//       }
//     }
//     return closestCoordinate;
//   }
//
//   double calculateDistance(double startLatitude, double startLongitude,
//       double endLatitude, double endLongitude) {
//     const int earthRadius = 6371000; // in meters
//     double lat1Rad = radians(startLatitude);
//     double lon1Rad = radians(startLongitude);
//     double lat2Rad = radians(endLatitude);
//     double lon2Rad = radians(endLongitude);
//
//     double deltaLat = lat2Rad - lat1Rad;
//     double deltaLon = lon2Rad - lon1Rad;
//
//     double a = math.pow(math.sin(deltaLat / 2), 2) +
//         math.cos(lat1Rad) *
//             math.cos(lat2Rad) *
//             math.pow(math.sin(deltaLon / 2), 2);
//     double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
//
//     return earthRadius * c;
//   }
//
//   double radians(double degrees) {
//     return degrees * (math.pi / 180);
//   }
// }











// ---------------------------------------------------------------------------------------

//
// class RideMatching {
//
//   num? distanceThreshold;
//
//   RideMatching(this.distanceThreshold);
//
//   Future<List<DocumentSnapshot>> findRides(GeoPoint userPickupLocation, GeoPoint userDropoffLocation) async {
//
//     List<DocumentSnapshot> rides = [];
//
//     try{
//       QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('rides').get();
//       rides = snapshot.docs;
//
//       print("snapsotttttt rides: $rides");
//       print("Functiooooon calleddddddddddddddd");
//       print("user ploc lat: ${userPickupLocation.latitude}");
//
//       // Filter rides based on drop-off location matching the user's drop-off location
//       List<DocumentSnapshot> filteredRides = rides.where((ride) {
//         GeoPoint dropoffLocation = ride['dropoffLocation']['geopoint'];
//
//         return dropoffLocation.latitude == userDropoffLocation.latitude &&
//             dropoffLocation.longitude == userDropoffLocation.longitude;
//       }).toList();
//
//       print("filtered rides: $rides");
//
//       if (filteredRides.isEmpty) {
//         final GeoFirePoint geoPoint =
//         GeoFirePoint(userDropoffLocation.latitude, userDropoffLocation.longitude);
//         String userDropoffGeohash = geoPoint.hash;
//         userDropoffGeohash = userDropoffGeohash.substring(0, 6);
//
//         print("useeeeeer dropoffff GEOOOHASH $userDropoffGeohash");
//
//         filteredRides = rides.where((ride) {
//           print("geohash method calleddd");
//           String rideDropoffGeohash = ride['dropoffLocation']['geohash'].substring(0, 6);
//           print("RIDEEEEEE dropoffff GEOOOHASH $rideDropoffGeohash");
//           return rideDropoffGeohash == userDropoffGeohash;
//         }).toList();
//       }
//
//       GeoPoint? nearestCoordinate;
//
//       String distanceText = 'N/A';
//
//       List<DocumentSnapshot> closestRides = [];
//       for (var ride in filteredRides) {
//         List<GeoPoint> polylinePoints = (ride['polylinePoints'] as List).map((point) {
//           return GeoPoint(point['latitude'], point['longitude']);
//         }).toList();
//
//         double minDistance = double.infinity;
//         for (var point in polylinePoints) {
//           double distance = calculateDistance(userPickupLocation.latitude, userPickupLocation.longitude, point.latitude, point.longitude,);
//           if (distance < minDistance) {
//             minDistance = distance;
//             nearestCoordinate = point;
//             // distanceText = nearestCoordinate != null
//             //     ? '${(minDistance / 1000).toStringAsFixed(2)} km'
//             //     : 'N/A';
//           }
//         }
//
//         if (minDistance < (distanceThreshold ?? 1000)) {
//           closestRides.add(ride);
//         }
//       }
//
//       filteredRides = closestRides;
//       return filteredRides;
//
//
//     } catch (e){
//       print("Error fetching rides: $e");
//       return []; // Return empty list in case of error
//
//     }
//
//
//
//   }
//
//
//   double calculateDistance(double startLatitude, double startLongitude,
//       double endLatitude, double endLongitude) {
//     const int earthRadius = 6371000; // in meters
//     double lat1Rad = radians(startLatitude);
//     double lon1Rad = radians(startLongitude);
//     double lat2Rad = radians(endLatitude);
//     double lon2Rad = radians(endLongitude);
//
//     double deltaLat = lat2Rad - lat1Rad;
//     double deltaLon = lon2Rad - lon1Rad;
//
//     double a = math.pow(math.sin(deltaLat / 2), 2) +
//         math.cos(lat1Rad) *
//             math.cos(lat2Rad) *
//             math.pow(math.sin(deltaLon / 2), 2);
//     double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
//
//     return earthRadius * c;
//   }
//
//   double radians(double degrees) {
//     return degrees * (math.pi / 180);
//   }
// }


// Future<List<Map<String, dynamic>>> fetchRidesWithDistances(List<dynamic> filteredRides, LatLng userPickupLocation, LatLng userDropoffLocation, double distanceThreshold) async {
//   try {
//     List<Map<String, dynamic>> ridesWithDistances = [];
//
//     for (var ride in filteredRides) {
//       List<LatLng> polylineCoordinates = (ride['polylinePoints'] as List).map((point) {
//         return LatLng(point['latitude'], point['longitude']);
//       }).toList();
//
//       // Call the snapToRoads function to obtain snapped coordinates for pickup location
//       List<LatLng> snappedPickupCoordinates = await snapToRoads(userPickupLocation);
//
//       // Call the snapToRoads function to obtain snapped coordinates for dropoff location
//       List<LatLng> snappedDropoffCoordinates = await snapToRoads(userDropoffLocation);
//
//       // Iterate through each snapped pickup coordinate to obtain the snapped point
//       List<LatLng> finalSnappedPickupCoordinates = [];
//       for (LatLng snappedCoordinate in snappedPickupCoordinates) {
//         List<LatLng> snappedPoint = await snapToRoads(snappedCoordinate);
//         finalSnappedPickupCoordinates.addAll(snappedPoint);
//       }
//
//       // Iterate through each snapped dropoff coordinate to obtain the snapped point
//       List<LatLng> finalSnappedDropoffCoordinates = [];
//       for (LatLng snappedCoordinate in snappedDropoffCoordinates) {
//         List<LatLng> snappedPoint = await snapToRoads(snappedCoordinate);
//         finalSnappedDropoffCoordinates.addAll(snappedPoint);
//       }
//
//       // Calculate distance from each snapped coordinate to polyline coordinates for pickup
//       double minPickupDistance = double.infinity;
//       LatLng closestSnappedPickupCoordinate = LatLng(0, 0);
//
//       for (LatLng snappedCoordinate in finalSnappedPickupCoordinates) {
//         for (LatLng polylineCoordinate in polylineCoordinates) {
//           double distance = calculateDistance(
//             snappedCoordinate.latitude,
//             snappedCoordinate.longitude,
//             polylineCoordinate.latitude,
//             polylineCoordinate.longitude,
//           );
//
//           // Update minimum pickup distance and closest snapped pickup coordinate if needed
//           if (distance < minPickupDistance) {
//             minPickupDistance = distance;
//             closestSnappedPickupCoordinate = snappedCoordinate;
//           }
//         }
//       }
//
//       // Calculate distance from each snapped coordinate to polyline coordinates for dropoff
//       double minDropoffDistance = double.infinity;
//       LatLng closestSnappedDropoffCoordinate = LatLng(0, 0);
//
//       for (LatLng snappedCoordinate in finalSnappedDropoffCoordinates) {
//         for (LatLng polylineCoordinate in polylineCoordinates) {
//           double distance = calculateDistance(
//             snappedCoordinate.latitude,
//             snappedCoordinate.longitude,
//             polylineCoordinate.latitude,
//             polylineCoordinate.longitude,
//           );
//
//           // Update minimum dropoff distance and closest snapped dropoff coordinate if needed
//           if (distance < minDropoffDistance) {
//             minDropoffDistance = distance;
//             closestSnappedDropoffCoordinate = snappedCoordinate;
//           }
//         }
//       }
//
//       // Calculate distance texts for pickup and dropoff distances
//       String pickupDistanceText = '${(minPickupDistance / 1000).toStringAsFixed(2)} km';
//       String dropoffDistanceText = '${(minDropoffDistance / 1000).toStringAsFixed(2)} km';
//
//       // If the minimum distances are within the threshold, add ride with distances to the list
//       if (minPickupDistance < distanceThreshold && minDropoffDistance < distanceThreshold) {
//         ridesWithDistances.add({
//           'ride': ride,
//           'pickupDistance': minPickupDistance,
//           'dropoffDistance': minDropoffDistance,
//           'pickupDistanceText': pickupDistanceText,
//           'dropoffDistanceText': dropoffDistanceText,
//           'closestSnappedPickupCoordinate': closestSnappedPickupCoordinate,
//           'closestSnappedDropoffCoordinate': closestSnappedDropoffCoordinate,
//         });
//       }
//     }
//
//     return ridesWithDistances;
//   } catch (e) {
//     print("Error fetching rides: $e");
//     return []; // Return empty list in case of error
//   }
// }

// Future<List<Map<String, dynamic>>> findRidesWithDistances(
//     LatLng userPickupLocation, LatLng userDropoffLocation) async {
//   List<Map<String, dynamic>> ridesWithDistances = [];
//
//   try {
//     QuerySnapshot snapshot = await FirebaseFirestore.instance
//         .collection('rides')
//         .get();
//     List<DocumentSnapshot> rides = snapshot.docs;
//
//     // Filter rides based on drop-off location matching the user's drop-off location
//     List<DocumentSnapshot> filteredRides = rides.where((ride) {
//       GeoPoint dropoffLocation = ride['dropoffLocation']['geopoint'];
//
//       return dropoffLocation.latitude == userDropoffLocation.latitude &&
//           dropoffLocation.longitude == userDropoffLocation.longitude;
//     }).toList();
//
//     if (filteredRides.isEmpty) {
//       final GeoFirePoint geoPoint =
//       GeoFirePoint(userDropoffLocation.latitude, userDropoffLocation.longitude);
//       String userDropoffGeohash = geoPoint.hash;
//       userDropoffGeohash = userDropoffGeohash.substring(0, 5);
//
//       filteredRides = rides.where((ride) {
//         String rideDropoffGeohash =
//         ride['dropoffLocation']['geohash'].substring(0, 5);
//         return rideDropoffGeohash == userDropoffGeohash;
//       }).toList();
//     }
//
//     // Adjust the threshold distance according to your preference
//     const double distanceThreshold = 1000; // meters
//
//     // Call fetchRidesWithDistances function to get rides with distances
//     // ridesWithDistances = await fetchRidesWithDistances(
//     //     filteredRides, userPickupLocation, userDropoffLocation, distanceThreshold);
//
//     for (var ride in filteredRides) {
//       List<LatLng> polylineCoordinates = (ride['polylinePoints'] as List).map((point) {
//         return LatLng(point['latitude'], point['longitude']);
//       }).toList();
//
//       // Call the snapToRoads function to obtain snapped coordinates for pickup location
//       List<LatLng> snappedPickupCoordinates = await snapToRoads(userPickupLocation);
//
//       // Call the snapToRoads function to obtain snapped coordinates for dropoff location
//       List<LatLng> snappedDropoffCoordinates = await snapToRoads(userDropoffLocation);
//
//       // Calculate distance from each snapped coordinate to polyline coordinates for pickup
//       double minPickupDistance = double.infinity;
//       // Initialize variables for closest snapped coordinates
//       LatLng closestSnappedPickupCoordinate = LatLng(0, 0);
//       LatLng closestSnappedDropoffCoordinate = LatLng(0, 0);
//
//       for (LatLng snappedCoordinate in snappedPickupCoordinates) {
//         for (LatLng polylineCoordinate in polylineCoordinates) {
//           double distance = calculateDistance(
//             snappedCoordinate.latitude,
//             snappedCoordinate.longitude,
//             polylineCoordinate.latitude,
//             polylineCoordinate.longitude,
//           );
//
//           // Update minimum pickup distance and closest snapped pickup coordinate if needed
//           if (distance < minPickupDistance) {
//             minPickupDistance = distance;
//             closestSnappedPickupCoordinate = snappedCoordinate;
//           }
//         }
//       }
//
//       // Calculate distance from each snapped coordinate to polyline coordinates for dropoff
//       double minDropoffDistance = double.infinity;
//       // LatLng closestSnappedDropoffCoordinate;
//
//       for (LatLng snappedCoordinate in snappedDropoffCoordinates) {
//         for (LatLng polylineCoordinate in polylineCoordinates) {
//           double distance = calculateDistance(
//             snappedCoordinate.latitude,
//             snappedCoordinate.longitude,
//             polylineCoordinate.latitude,
//             polylineCoordinate.longitude,
//           );
//
//           // Update minimum dropoff distance and closest snapped dropoff coordinate if needed
//           if (distance < minDropoffDistance) {
//             minDropoffDistance = distance;
//             closestSnappedDropoffCoordinate = snappedCoordinate;
//           }
//         }
//       }
//
//       // Calculate distance texts for pickup and dropoff distances
//       String pickupDistanceText = '${(minPickupDistance / 1000).toStringAsFixed(2)} km';
//       String dropoffDistanceText = '${(minDropoffDistance / 1000).toStringAsFixed(2)} km';
//
//       // If the minimum distances are within the threshold, add ride with distances to the list
//       if (minPickupDistance < distanceThreshold && minDropoffDistance < distanceThreshold) {
//         ridesWithDistances.add({
//           'ride': ride,
//           'pickupDistance': minPickupDistance,
//           'dropoffDistance': minDropoffDistance,
//           'pickupDistanceText': pickupDistanceText,
//           'dropoffDistanceText': dropoffDistanceText,
//           'closestSnappedPickupCoordinate': closestSnappedPickupCoordinate,
//           'closestSnappedDropoffCoordinate': closestSnappedDropoffCoordinate,
//         });
//       }
//     }
//
//     return ridesWithDistances;
//
//   } catch (e) {
//     print("Error fetching rides: $e");
//     return []; // Return empty list in case of error
//   }
// }