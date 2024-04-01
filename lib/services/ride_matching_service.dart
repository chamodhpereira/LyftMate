import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';


class RideMatching {

  Future<List<DocumentSnapshot>> findRides(GeoPoint userPickupLocation, GeoPoint userDropoffLocation) async {

    List<DocumentSnapshot> rides = [];

    try{
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('rides').get();
      rides = snapshot.docs;

      print("snapsotttttt rides: $rides");
      print("Functiooooon calleddddddddddddddd");
      print("user ploc lat: ${userPickupLocation.latitude}");

      // Filter rides based on drop-off location matching the user's drop-off location
      List<DocumentSnapshot> filteredRides = rides.where((ride) {
        GeoPoint dropoffLocation = ride['dropoffLocation']['geopoint'];

        return dropoffLocation.latitude == userDropoffLocation.latitude &&
            dropoffLocation.longitude == userDropoffLocation.longitude;
      }).toList();

      print("filtered rides: $rides");

      if (filteredRides.isEmpty) {
        final GeoFirePoint geoPoint =
        GeoFirePoint(userDropoffLocation.latitude, userDropoffLocation.longitude);
        String userDropoffGeohash = geoPoint.hash;
        userDropoffGeohash = userDropoffGeohash.substring(0, 6);

        print("useeeeeer dropoffff GEOOOHASH $userDropoffGeohash");

        filteredRides = rides.where((ride) {
          print("geohash method calleddd");
          String rideDropoffGeohash = ride['dropoffLocation']['geohash'].substring(0, 6);
          print("RIDEEEEEE dropoffff GEOOOHASH $rideDropoffGeohash");
          return rideDropoffGeohash == userDropoffGeohash;
        }).toList();
      }




    } catch (e){
      print("Error fetching rides: $e");

    }

    return rides;

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