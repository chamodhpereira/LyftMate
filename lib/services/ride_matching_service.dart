import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

class RideMatching {
  Future<List<Map<String, dynamic>>> findRidesWithDistances(GeoPoint userPickupLocation, GeoPoint userDropoffLocation) async {
    List<Map<String, dynamic>> ridesWithDistances = [];

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('rides').get();
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
          String rideDropoffGeohash = ride['dropoffLocation']['geohash'].substring(0, 5);
          return rideDropoffGeohash == userDropoffGeohash;
        }).toList();
      }

      print("filtereeeeeeeeeeeeeeeeeeed ridesssssssssssgeooooo: ${filteredRides.length}");

      // Calculate distances for each ride
      for (var ride in filteredRides) {
        List<GeoPoint> polylinePoints = (ride['polylinePoints'] as List).map((point) {
          return GeoPoint(point['latitude'], point['longitude']);
        }).toList();

        GeoPoint closestCoordinate = _findClosestCoordinate(polylinePoints, userPickupLocation);
        double pickupDistance = calculateDistance(
          userPickupLocation.latitude,
          userPickupLocation.longitude,
          closestCoordinate.latitude,
          closestCoordinate.longitude,
        );

        // Calculate dropoff distance (assuming the dropoff point is stored in the ride document)
        GeoPoint dropoffGeoPoint = ride['dropoffLocation']['geopoint'];
        double dropoffDistance = calculateDistance(
          userDropoffLocation.latitude,
          userDropoffLocation.longitude,
          dropoffGeoPoint.latitude,
          dropoffGeoPoint.longitude,
        );

        // Add ride with distances to the list
        ridesWithDistances.add({
          'ride': ride,
          'pickupDistance': pickupDistance,
          'dropoffDistance': dropoffDistance,
          'closestCoordinateToPickup' : closestCoordinate,
        });
      }

      return ridesWithDistances;
    } catch (e) {
      print("Error fetching rides: $e");
      return []; // Return empty list in case of error
    }
  }

  GeoPoint _findClosestCoordinate(List<GeoPoint> coordinates, GeoPoint userPickupLocation) {
    double minDistance = double.infinity;
    GeoPoint closestCoordinate = GeoPoint(0, 0); // Default value
    for (var coord in coordinates) {
      double distance = calculateDistance(
        coord.latitude,
        coord.longitude,
        userPickupLocation.latitude,
        userPickupLocation.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
        closestCoordinate = coord;
      }
    }
    return closestCoordinate;
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