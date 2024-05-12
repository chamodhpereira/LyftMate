import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lyft_mate/screens/find_ride/ride_details.dart';
import '../../constants/colors.dart';

class CarpoolRideCard extends StatelessWidget {
  final DocumentSnapshot ride;
  final String pickupDistance;
  final String dropoffDistance;
  final GeoPoint closestCoordinateToPickup;
  final GeoPoint closestCoordinateToDropoff;
  final GeoPoint userPickupLocation;
  final GeoPoint userDropoffLocation;
  final DocumentSnapshot driver;

  CarpoolRideCard({
    super.key,
    required this.ride,
    required this.pickupDistance,
    required this.dropoffDistance,
    required this.closestCoordinateToPickup,
    required this.driver,
    required this.closestCoordinateToDropoff,
    required this.userPickupLocation,
    required this.userDropoffLocation,
  });

  Duration parseDuration(String durationStr) {
    List<String> parts = durationStr.split(' ');
    int hours = 0;
    int minutes = 0;
    for (int i = 0; i < parts.length; i += 2) {
      int value = int.parse(parts[i]);
      if (parts[i + 1] == 'hours' || parts[i + 1] == 'hour') {
        hours = value;
      } else if (parts[i + 1] == 'minutes' || parts[i + 1] == 'minute') {
        minutes = value;
      }
    }
    return Duration(hours: hours, minutes: minutes);
  }

  String formatTime(DateTime time) {
    String period = time.hour < 12 ? 'AM' : 'PM';
    int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    return "${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period";
  }

  @override
  Widget build(BuildContext context) {
    DateTime rideStartTime = (ride['time'] as Timestamp).toDate();
    Duration duration = parseDuration(ride['rideDuration']);
    DateTime rideEndTime = rideStartTime.add(duration);

    // Determine the button text based on the rideApproval value
    final String buttonText = (ride['rideApproval'] == 'Request') ? 'Request Ride' : 'Book Ride';

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text("${ride['pickupCityName']} "),
                      const Icon(Icons.arrow_forward, size: 15),
                      Text(" ${ride['dropoffCityName']} "),
                    ],
                  ),
                  Row(
                    children: [
                      Text("Price Per Seat: ${ride['pricePerSeat']}"),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${formatTime(rideStartTime)} to ${formatTime(rideEndTime)}'),
                  Text('Available Seats: ${ride["seats"]}'),
                ],
              ),
            ),
            Row(
              children: [
                const Icon(Icons.directions_walk, color: Colors.green),
                Text('${pickupDistance} '),
                const Icon(Icons.arrow_forward, size: 14),
                const Icon(Icons.directions_car),
                const Icon(Icons.arrow_forward, size: 14),
                const Icon(Icons.directions_walk, color: Colors.red),
                Text('${dropoffDistance}'),
              ],
            ),
            const SizedBox(height: 15),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            backgroundImage: driver['profileImageUrl'] != null &&
                                driver['profileImageUrl'].isNotEmpty
                                ? NetworkImage(driver['profileImageUrl'])
                                : null,
                            child: driver['profileImageUrl'] == null ||
                                driver['profileImageUrl'].isEmpty
                                ? const Icon(Icons.person, size: 20.0)
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${driver["firstName"]} ${driver["lastName"]}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)),
                          Row(
                            children: [
                              Text(driver['ratings'].toString(), style: const TextStyle(fontSize: 12.0)),
                              const SizedBox(width: 2.0),
                              const Icon(Icons.star, color: Colors.blueGrey, size: 12),
                              const SizedBox(width: 8.0),
                              Text('${driver['reviews'].length} reviews', style: const TextStyle(fontSize: 12.0)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: kSecondaryColor,
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RideDetailsScreen(
                            ride: ride,
                            pickupDistance: pickupDistance,
                            dropoffDistance: dropoffDistance,
                            closestCoordinateToPickup: closestCoordinateToPickup,
                            closestCoordinateToDropoff: closestCoordinateToDropoff,
                            userPickupLocation: userPickupLocation,
                            userDropoffLocation: userDropoffLocation,
                            driverDetails: driver,
                          ),
                        ),
                      );
                    },
                    child: Text(buttonText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


