import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/ride.dart';

// class RideProvider with ChangeNotifier {
//   final Ride _currentRide = Ride();
//
//   Ride get currentRide => _currentRide;
//
//   void updatePickupCoordinates(double pickupLat, double pickupLng) {
//     print("PAREEEEEEEEEcureeeeeeeent rideee: $_currentRide");
//     _currentRide.pickupLat = pickupLat;
//     _currentRide.pickupLng = pickupLng;
//     print("PAGGGOOOOOOOOOR Ride Pickupppppp positin ${_currentRide.pickupLng}");
//     notifyListeners();
//   }
//
//   // // Function to update the dropoff coordinates
//   void updateDropoffCoordinates(double dropoffLat, double dropoffLng) {
//     _currentRide.dropoffLat = dropoffLat;
//     _currentRide.dropoffLng = dropoffLng;
//     notifyListeners();
//   }
//
// // // Function to update the polyline points of the current ride
//   void updatePolylinePoints(List<LatLng> polylinePoints) {
//     _currentRide.polylinePoints = polylinePoints;
//     print("PAGGGOOOOOOOOOR PPOLYYYYYLINESSSSSS ${_currentRide.polylinePoints}");
//     notifyListeners();
//   }
// }

//

//
// // Function to add a passenger to the current ride
// void addPassenger(String passengerId) {
//   if (_currentRide != null) {
//     _currentRide!.addPassenger(passengerId);
//     notifyListeners();
//   }
// }
//
// // Function to remove a passenger from the current ride
// void removePassenger(String passengerId) {
//   if (_currentRide != null) {
//     _currentRide!.removePassenger(passengerId);
//     notifyListeners();
//   }
// }
//
//
