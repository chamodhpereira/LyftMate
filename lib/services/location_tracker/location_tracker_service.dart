import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationTracker {
  Location location = Location();

  late double _previousLatitude;
  late double _previousLongitude;
  late StreamSubscription<LocationData> _locationSubscription;

  void startLocationTracking({required String rideId, required Function(double latitude, double longitude) onUpdateLocation}) {
    _locationSubscription = location.onLocationChanged.listen((LocationData currentLocation) {
        double newLatitude = currentLocation.latitude ?? 0;
        double newLongitude = currentLocation.longitude ?? 0;

        // Calculate the distance between the new and previous locations
        double distance = _calculateDistance(
          _previousLatitude,
          _previousLongitude,
          newLatitude,
          newLongitude,
        );

        // Update Firestore only if the distance exceeds a certain threshold (e.g., 100 meters)
        if (distance >= 1000) {
          onUpdateLocation(newLatitude, newLongitude);

          // Update previous location data
          _previousLatitude = newLatitude;
          _previousLongitude = newLongitude;
        }
      },
    );

    location.enableBackgroundMode(enable: true);
  }

  void stopLocationTracking() {
    _locationSubscription.cancel();
  }

  // Function to calculate distance between two coordinates (in meters)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Radius of the earth in meters
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  // Function to convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
