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








// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:lyft_mate/screens/find_ride/ride_details.dart';
//
// import '../../constants/colors.dart';
//
//
// class CarpoolRideCard extends StatelessWidget {
//   final DocumentSnapshot ride;
//   // final double pickupDistance;
//   final String pickupDistance;
//   final String dropoffDistance;
//   // final double dropoffDistance;
//   final GeoPoint closestCoordinateToPickup;
//   final GeoPoint closestCoordinateToDropoff;
//   final GeoPoint userPickupLocation;
//   final GeoPoint userDropoffLocation;
//   final DocumentSnapshot driver;
//
//   CarpoolRideCard({super.key,
//     required this.ride,
//     required this.pickupDistance,
//     required this.dropoffDistance,
//     required this.closestCoordinateToPickup, required this.driver, required this.closestCoordinateToDropoff, required this.userPickupLocation, required this.userDropoffLocation,
//   });
//
//
//   // // Helper function to parse duration string into Duration object
//   // Duration parseDuration(String durationStr) {
//   //   List<String> parts = durationStr.split(' ');
//   //   int hours = int.parse(parts[0]);
//   //   int minutes = int.parse(parts[2]);
//   //   return Duration(hours: hours, minutes: minutes);
//   // }
//
//   Duration parseDuration(String durationStr) {
//     List<String> parts = durationStr.split(' ');
//     int hours = 0;
//     int minutes = 0;
//
//     for (int i = 0; i < parts.length; i += 2) {
//       int value = int.parse(parts[i]);
//       if (parts[i + 1] == 'hours' || parts[i + 1] == 'hour') {
//         hours = value;
//       } else if (parts[i + 1] == 'minutes' || parts[i + 1] == 'minute') {
//         minutes = value;
//       }
//     }
//
//     return Duration(hours: hours, minutes: minutes);
//   }
//
//   // Helper function to format DateTime object as string
//   // String formatTime(DateTime time) {
//   //   return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
//   // }
//   String formatTime(DateTime time) {
//     String period = time.hour < 12 ? 'AM' : 'PM';
//     int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
//     return "${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period";
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     // Parse start time and duration from Firestore document
//     DateTime rideStartTime = (ride['time'] as Timestamp).toDate();
//     Duration duration = parseDuration(ride['rideDuration']);
//
//     // Calculate end time by adding duration to start time
//     DateTime rideEndTime = rideStartTime.add(duration);
//
//     // print("thisssssssssi the rideeeeeee ${ride["seats"]}");
//     return Card(
//       margin: EdgeInsets.all(8),
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Top of the card: Starting location, arrow, drop-off location, and price per seat
//             Padding(
//               padding: EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Text("${ride.id}"),
//                   // Text('Starting Location'),
//                   Row(
//                     children: [
//                       Text("${ride['pickupCityName']} "),
//                       Icon(Icons.arrow_forward, size: 15, ),
//                       Text(" ${ride['dropoffCityName']} "),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Text("Price Per Seat: ${ride['pricePerSeat']}"),
//                     ],
//                   ),
//
//
//                   // SizedBox(width: 105),
//
//                   // Text('LKR ${ride.price.toStringAsFixed(2)}'), // Assuming ride.price is the price per seat
//                 ],
//               ),
//             ),
//             // Below the ride locations: Starting time, available seats
//             Padding(
//               padding: EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Text('${ride.startTime} to ${ride.endTime}'),
//                   // Text('${ride['startTime']}'),
//                   // Text("9.00 am to 12.00pm"),
//                   Text('${formatTime(rideStartTime)} to ${formatTime(rideEndTime)}'),
//                   // SizedBox(width: 110),
//                   Text('Available Seats: ${ride["seats"]}'),
//                 ],
//               ),
//             ),
//             Row(
//               children: [
//                 Icon(Icons.directions_walk, color: Colors.green), // Human walking icon
//                 // Text('${pickupDistance.toStringAsFixed(1)} km'), // Distance
//                 Text('${pickupDistance} '),
//                 Icon(Icons.arrow_forward, size: 14), // Arrow icon
//                 Icon(Icons.directions_car),
//                 Icon(Icons.arrow_forward, size: 14),
//                 Icon(Icons.directions_walk, color: Colors.red), // Red human walking icon
//                 // Text('${dropoffDistance.toStringAsFixed(1)} km'), // Distance
//                 Text('${dropoffDistance}'),
//               ],
//             ),
//             // Divider
//             SizedBox(height: 15,),
//             // Padding(padding: EdgeInsets.symmetric(horizontal: 15),
//             // child: Divider(),),
//             Divider(),
//             // Below the divider: Driver information
//             Padding(
//               padding: EdgeInsets.all(16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // CircleAvatar with verified badge
//                   Row(
//                     children: [
//                       Stack(
//                         alignment: Alignment.bottomRight,
//                         children: [
//                           CircleAvatar(
//                             // radius: 30.0,
//                             backgroundImage: driver != null &&
//                                 driver['profileImageUrl'] != null &&
//                                 driver['profileImageUrl'].isNotEmpty
//                                 ? NetworkImage(driver['profileImageUrl'])
//                                 : null,
//                             child: driver == null ||
//                                 driver['profileImageUrl'] == null ||
//                                 driver['profileImageUrl'].isEmpty
//                                 ? Icon(
//                               Icons.person,
//                               size: 20.0,
//                             )
//                                 : null,
//                           ),
//
//
//                           // CircleAvatar(
//                           //   child: Icon(
//                           //     Icons.person,
//                           //     size: 20.0,
//                           //   ),
//                           // ),
//                           // Icon(Icons.verified_user, color: Colors.green, size: 15),
//                         ],
//                       ),
//                       SizedBox(width: 10),
//                       // Driver's name, rating, and reviews
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Text(ride.driverName),
//                           Text(driver["firstName"] + " " + driver["lastName"], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),),
//                           Row(
//                             children: [
//                               Text(driver['ratings'].toString(), style: TextStyle(fontSize: 12.0),),
//                               SizedBox(width: 2.0),
//                               Icon(Icons.star, color: Colors.blueGrey, size: 12),
//                               SizedBox(width: 8.0),
//                               Text('${driver['reviews'].length} reviews', style: TextStyle(fontSize: 12.0),),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       // shape: const RoundedRectangleBorder(),
//                       foregroundColor: kSecondaryColor,
//                       backgroundColor: Colors.green,
//                       // side: const BorderSide(color: kSecondaryColor),
//                       // padding: const EdgeInsets.symmetric(vertical: 15.0),
//                     ),
//                     onPressed: () {
//                       print("nice");
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => RideDetailsScreen(
//                           ride: ride,
//                           pickupDistance: pickupDistance,
//                           dropoffDistance: dropoffDistance,
//                           closestCoordinateToPickup:
//                           closestCoordinateToPickup,
//                           closestCoordinateToDropoff:
//                           closestCoordinateToDropoff,
//                           userPickupLocation: userPickupLocation,
//                           userDropoffLocation: userDropoffLocation,
//                           driverDetails: driver,
//                           // startTime: rideStartTime,
//                           // endTime: rideEndTime,
//
//                         ),),
//                       );
//                     },
//                     child: Text("Book Ride"),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
