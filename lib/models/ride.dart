import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Ride {
  static final Ride _instance = Ride._internal();

  factory Ride() {
    return _instance;
  }

  Ride._internal();

  String? id; // Unique identifier for the ride
  String? userId; // ID of the user offering/requesting the ride
  LatLng? pickupLocation; // LatLng object representing pickup location
  LatLng? dropoffLocation; // LatLng object representing dropoff location
  String? seats;
  String? vehicle;
  double? rideDistance;
  String? pickupCityName;
  String? pickupLocationName;
  String? dropoffCityName;
  String? dropoffLocationName;
  String? rideDuration;
  String? luggageAllowance;
  String? paymentMode;
  String? rideApproval;
  DateTime? date; // Date of the ride
  TimeOfDay? time; // Time of the ride
  double? pricePerSeat; // Price per seat for the ride
  List<String> passengers = []; // List of passenger user IDs
  List<LatLng> polylinePoints = []; // List to store polyline points



  void reset() {
    id = null;
    userId = null;
    pickupLocation = null;
    dropoffLocation = null;
    seats = null;
    rideDistance = null;
    pickupCityName = null;
    pickupLocationName = null;
    dropoffCityName = null;
    dropoffLocationName = null;
    rideDuration = null;
    date = null;
    time = null;
    pricePerSeat = null;
    passengers.clear();
    polylinePoints.clear();
  }

  void updatePickupCoordinates(double newLat, double newLng) {
    pickupLocation = LatLng(newLat, newLng);
  }

  void updateDropoffCoordinates(double newLat, double newLng) {
    dropoffLocation = LatLng(newLat, newLng);
  }

  void resetPolylinePoints() {
    polylinePoints.clear();
  }

  // Setter method to update date
  void setDate(DateTime newDate) {
    date = newDate;
    print("dateeee wtooo dateee: $date");
  }

  // Setter method to update time
  void setTime(TimeOfDay newTime) {
    time = newTime;
    print("timeeee wtooo timeee: $time");
  }

  void setVehicle(String rideVehicle) {
    vehicle = rideVehicle;
    print("vehiceleeeee: $vehicle");
  }

  // Setter method to update seats
  void setSeats(String newSeats) {
    seats = newSeats;
    print("seatssss: $seats");
  }

  // Setter method to update price per seat
  void setPricePerSeat(double newPrice) {
    pricePerSeat = newPrice;
  }

  // Method to add a passenger to the ride
  void addPassenger(String passengerId) {
    passengers.add(passengerId);
  }

  // Method to remove a passenger from the ride
  void removePassenger(String passengerId) {
    passengers.remove(passengerId);
  }
}
