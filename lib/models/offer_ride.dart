import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OfferRide {
  static final OfferRide _instance = OfferRide._internal();

  factory OfferRide() {
    return _instance;
  }

  OfferRide._internal();

  String? id; // Unique identifier for the ride
  String? userId; // ID of the user offering/requesting the ride
  LatLng? rideLocation;
  LatLng? pickupLocation; // LatLng object representing pickup location
  LatLng? dropoffLocation; // LatLng object representing dropoff location
  String? seats;
  String? vehicle;
  String? rideDistance;
  String? pickupCityName;
  String? pickupLocationName;
  String? dropoffCityName;
  String? dropoffLocationName;
  String? rideDuration;
  String? luggageAllowance;
  String? paymentMode;
  String? rideApproval;
  String? rideNotes;
  DateTime? date; // Date of the ride
  TimeOfDay? time; // Time of the ride
  double? pricePerSeat; // Price per seat for the ride
  List<String> ridePreferences = [];
  List<String> passengers = []; // List of passenger user IDs
  List<LatLng> polylinePoints = []; // List to store polyline points
  String rideStatus = "pending";



  void reset() {
    id = null;
    userId = null;
    rideLocation = null;
    pickupLocation = null;
    dropoffLocation = null;
    seats = null;
    rideDistance = null;
    pickupCityName = null;
    pickupLocationName = null;
    dropoffCityName = null;
    dropoffLocationName = null;
    rideDuration = null;
    rideNotes = null;
    date = null;
    time = null;
    pricePerSeat = null;
    passengers.clear();
    ridePreferences.clear();
    polylinePoints.clear();
  }

  void updateRideDetails(String distance, String duration, List<LatLng> polylinePoints) {
    rideDistance = distance;
    rideDuration = duration;
    this.polylinePoints = polylinePoints;

    print("this is the pickup city: $pickupLocationName");
    print("this is the drop city: $dropoffLocation");

    print("this is ride Distance: $rideDistance");
    print("this is ride Duration: $rideDuration");
    print("this is ploylinesss: $polylinePoints");

    // this.polylinePoints = polylinePoints;
  }

  // Update method to set pickup location details
  void setPickupLocation(double lat, double lng, String locationName, String cityName) {
    pickupLocation = LatLng(lat, lng);
    pickupLocationName = locationName;
    pickupCityName = cityName;
    rideLocation = LatLng(lat, lng);
  }

  // Update method to set dropoff location details
  void setDropoffLocation(double lat, double lng, String locationName, String cityName) {
    dropoffLocation = LatLng(lat, lng);
    dropoffLocationName = locationName;
    dropoffCityName = cityName;
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

  void setPreferences(List<String> preferences) {
    ridePreferences.clear();
    ridePreferences.addAll(preferences);
    print("this is preferences $ridePreferences");
  }

  void setNotes(String notes) {
    rideNotes = notes;
    print("this isss notesss: $rideNotes");
  }

  // Setter method to update price per seat
  void setPricePerSeat(double newPrice) {
    pricePerSeat = newPrice;
    print("PRiceeeeee per seaaat: $pricePerSeat");
  }

  void setLuggageAllowance(String luggageOption) {
    luggageAllowance = luggageOption;
    print("Luggage allowance: $luggageAllowance");
  }

  void setPaymentMode(String paymentOption) {
    paymentMode = paymentOption;
    print("Payment option: $paymentMode");
  }

  void setRideApproval(String approvalOption) {
    rideApproval = approvalOption;
    print("rideee approavaal: $rideApproval");
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
