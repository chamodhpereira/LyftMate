class Ride {
  final String id; // Unique identifier for the ride
  final String userId; // ID of the user offering/requesting the ride
  final double pickupLat; // Latitude of pickup location
  final double pickupLng; // Longitude of pickup location
  final double dropoffLat; // Latitude of dropoff location
  final double dropoffLng; // Longitude of dropoff location
  final bool isOfferingRide; // Indicates whether the ride is being offered or requested
  List<String> passengers; // List of passenger user IDs

  Ride({
    required this.id,
    required this.userId,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.isOfferingRide,
    List<String>? passengers, // Optional list of passengers
  }) : passengers = passengers ?? []; // If passengers is null, initialize it as an empty list

  // Method to add a passenger to the ride
  void addPassenger(String passengerId) {
    passengers.add(passengerId);
  }

  // Method to remove a passenger from the ride
  void removePassenger(String passengerId) {
    passengers.remove(passengerId);
  }
}