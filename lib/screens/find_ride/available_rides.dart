import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lyft_mate/screens/find_ride/ride_route.dart';
import '../../services/ride_matching_service.dart';

// class RideMatchingScreen extends StatelessWidget {
//   final GeoPoint userPickupLocation;
//   final GeoPoint userDropoffLocation;
//
//   RideMatchingScreen({required this.userPickupLocation, required this.userDropoffLocation});
//
//   @override
//   Widget build(BuildContext context) {
//     RideMatching rideMatching = RideMatching();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Filtered Rides'),
//       ),
//       body: FutureBuilder<List<DocumentSnapshot>>(
//         future: rideMatching.findRides(userPickupLocation, userDropoffLocation),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (snapshot.data == null || snapshot.data!.isEmpty) {
//             return Center(child: Text('No rides found.'));
//           } else {
//             return ListView.builder(
//               itemCount: snapshot.data!.length,
//               itemBuilder: (context, index) {
//                 var ride = snapshot.data![index];
//
//                 // Extract polyline coordinates from Firestore document
//                 List<dynamic> polylineCoordinates = ride['polylinePoints'];
//
//                 GeoPoint dropoffGeoPoint = ride['dropoffLocation']['geopoint'];
//
//                 // Find closest coordinate to user's pickup location
//                 GeoPoint closestCoordinate = _findClosestCoordinate(polylineCoordinates, userPickupLocation);
//
//                 // Calculate distance between closest coordinate and user's pickup location
//                 double pickupDistance = calculateDistance(userPickupLocation.latitude, userPickupLocation.longitude,
//                     closestCoordinate.latitude, closestCoordinate.longitude);
//
//                 double dropoffDistance = calculateDistance(userDropoffLocation.latitude, userDropoffLocation.longitude,
//                     dropoffGeoPoint.latitude, dropoffGeoPoint.longitude);
//
//                 return GestureDetector(
//                   onTap: () {
//                     // Navigate to ride details screen
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => RideDetailsScreen(
//                           ride: ride,
//                           pickupDistance: pickupDistance,
//                           dropoffDistance: dropoffDistance,
//                         ),
//                       ),
//                     );
//                   },
//                   child: ListTile(
//                     title: Text('Ride ID: ${ride.id}'),
//                     subtitle: Text('Seats: ${ride['seats']}, Vehicle: ${ride['vehicle']}, Pickup Distance: $pickupDistance meters, Dropoff Distance: $dropoffDistance meters'),
//                     // Add more details here as needed
//                   ),
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
//
//   GeoPoint _findClosestCoordinate(List<dynamic> coordinates, GeoPoint userPickupLocation) {
//     double minDistance = double.infinity;
//     GeoPoint closestCoordinate = GeoPoint(0, 0); // Default value
//     for (var coord in coordinates) {
//       double lat = coord['latitude'];
//       double lng = coord['longitude'];
//       double distance = calculateDistance(lat, lng, userPickupLocation.latitude, userPickupLocation.longitude);
//       if (distance < minDistance) {
//         minDistance = distance;
//         closestCoordinate = GeoPoint(lat, lng);
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
class RideMatchingScreen extends StatelessWidget {
  final GeoPoint userPickupLocation;
  final GeoPoint userDropoffLocation;

  RideMatchingScreen({required this.userPickupLocation, required this.userDropoffLocation});

  @override
  Widget build(BuildContext context) {
    RideMatching rideMatching = RideMatching();

    return Scaffold(
      appBar: AppBar(
        title: Text('Filtered Rides'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: rideMatching.findRidesWithDistances(userPickupLocation, userDropoffLocation),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text('No rides found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var rideData = snapshot.data![index];
                var ride = rideData['ride'];
                double pickupDistance = rideData['pickupDistance'];
                double dropoffDistance = rideData['dropoffDistance'];
                GeoPoint closestCoordinateToPickup = rideData['closestCoordinateToPickup'];

                return GestureDetector(
                  onTap: () {
                    // Navigate to ride details screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RideDetailsScreen(
                          ride: ride,
                          pickupDistance: pickupDistance,
                          dropoffDistance: dropoffDistance,
                          closestCoordinateToPickup: closestCoordinateToPickup,
                          userLocation: userPickupLocation,
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text('Ride ID: ${ride.id}'),
                    subtitle: Text('Seats: ${ride['seats']}, Vehicle: ${ride['vehicle']}, Pickup Distance: $pickupDistance meters, Dropoff Distance: $dropoffDistance meters'),
                    // Add more details here as needed
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}




class RideDetailsScreen extends StatelessWidget {
  final DocumentSnapshot ride;
  final double pickupDistance;
  final double dropoffDistance;
  final GeoPoint closestCoordinateToPickup;
  final GeoPoint userLocation;

  RideDetailsScreen({required this.ride, required this.pickupDistance, required this.dropoffDistance, required this.closestCoordinateToPickup, required this.userLocation,});

  @override
  Widget build(BuildContext context) {
    // Build UI for ride details screen
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ride ID: ${ride.id}'),
            Text('Seats: ${ride['seats']}'),
            Text('Vehicle: ${ride['vehicle']}'),
            Text('Pickup Distance: $pickupDistance meters'),
            Text('Dropoff Distance: $dropoffDistance meters'),
            // Add more details here as needed
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RideMapScreen(
                      ride: ride,
                      closestCoordinateToPickup: closestCoordinateToPickup,
                      userLocation: userLocation,
                    ),
                  ),
                );
              },
              child: Text('View in Map'),
            )
          ],
        ),
      ),
    );
  }
}
















// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'dart:math' as math;
//
//
// import '../../services/ride_matching_service.dart';
//
// class RideMatchingScreen extends StatelessWidget {
//   final GeoPoint userPickupLocation;
//   final GeoPoint userDropoffLocation;
//
//   RideMatchingScreen({required this.userPickupLocation, required this.userDropoffLocation});
//
//   @override
//
//
//   Widget build(BuildContext context) {
//
//     RideMatching rideMatching = RideMatching();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Filtered Rides'),
//       ),
//       body: FutureBuilder<List<DocumentSnapshot>>(
//         future: rideMatching.findRides(userPickupLocation, userDropoffLocation),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (snapshot.data == null || snapshot.data!.isEmpty) {
//             return Center(child: Text('No rides found.'));
//           } else {
//             return ListView.builder(
//               itemCount: snapshot.data!.length,
//               itemBuilder: (context, index) {
//                 var ride = snapshot.data![index];
//
//                 // Extract polyline coordinates from Firestore document
//                 List<dynamic> polylineCoordinates = ride['polylinePoints'];
//
//                 GeoPoint dropoffGeoPoint = ride['dropoffLocation']['geopoint'];
//
//                 // Find closest coordinate to user's pickup location
//                 GeoPoint closestCoordinate = _findClosestCoordinate(polylineCoordinates, userPickupLocation);
//
//                 // Calculate distance between closest coordinate and user's pickup location
//                 double pickupDistance = calculateDistance(userPickupLocation.latitude, userPickupLocation.longitude,
//                     closestCoordinate.latitude, closestCoordinate.longitude);
//
//                 double dropoffDistance = calculateDistance(userDropoffLocation.latitude, userDropoffLocation.longitude,
//                     dropoffGeoPoint.latitude, dropoffGeoPoint.longitude);
//
//
//                 return ListTile(
//                   title: Text('Ride ID: ${ride.id}'),
//                   subtitle: Text('Seats: ${ride['seats']}, Vehicle: ${ride['vehicle']}, Pickup Distance: $pickupDistance meters, Dropoff Distance: $dropoffDistance meters'),
//                   // Add more details here as needed
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
//
//   GeoPoint _findClosestCoordinate(List<dynamic> coordinates, GeoPoint userPickupLocation) {
//     double minDistance = double.infinity;
//     GeoPoint closestCoordinate = GeoPoint(0, 0); // Default value
//     for (var coord in coordinates) {
//       double lat = coord['latitude'];
//       double lng = coord['longitude'];
//       double distance = calculateDistance(lat, lng, userPickupLocation.latitude, userPickupLocation.longitude);
//       if (distance < minDistance) {
//         minDistance = distance;
//         closestCoordinate = GeoPoint(lat, lng);
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
//
// }