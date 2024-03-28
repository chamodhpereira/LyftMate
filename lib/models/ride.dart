import 'package:google_maps_flutter/google_maps_flutter.dart';

class Ride {

  static final Ride _instance = Ride._internal();

  factory Ride() {
    return _instance;
  }

  Ride._internal();

  String? id; // Unique identifier for the ride
  String? userId; // ID of the user offering/requesting the ride
  double? pickupLat; // Latitude of pickup location
  double? pickupLng; // Longitude of pickup location
  double? dropoffLat; // Latitude of dropoff location
  double? dropoffLng; // Longitude of dropoff location
  List<String> passengers = []; // List of passenger user IDs
  List<LatLng> polylinePoints = []; // List to store polyline points

  void reset() {
    id = null;
    userId = null;
    pickupLat = null;
    pickupLng = null;
    dropoffLat = null;
    dropoffLng = null;
    passengers.clear();
    polylinePoints.clear();
  }

  void updatePickupCoordinates(double newLat, double newLng) {
    pickupLat = newLat;
    pickupLng = newLng;
  }

  void resetPolylinePoints() {
    polylinePoints.clear();
  }
}




// // Method to add a passenger to the ride
// void addPassenger(String passengerId) {
//   passengers.add(passengerId);
// }
//
// // Method to remove a passenger from the ride
// void removePassenger(String passengerId) {
//   passengers.remove(passengerId);
// }