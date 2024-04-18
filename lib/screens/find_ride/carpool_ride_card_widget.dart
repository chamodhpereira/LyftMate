import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class CarpoolRideCard extends StatelessWidget {
  final DocumentSnapshot ride;
  // final double pickupDistance;
  final String pickupDistance;
  final String dropoffDistance;
  // final double dropoffDistance;
  final GeoPoint closestCoordinateToPickup;
  final DocumentSnapshot driver;

  CarpoolRideCard({
    required this.ride,
    required this.pickupDistance,
    required this.dropoffDistance,
    required this.closestCoordinateToPickup, required this.driver,
  });



  @override
  Widget build(BuildContext context) {


    print("thisssssssssi the rideeeeeee ${ride["seats"]}");
    return Card(
      margin: EdgeInsets.all(8),
      elevation: 4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top of the card: Starting location, arrow, drop-off location, and price per seat
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${ride.id}"),
                Text('Starting Location'),
                Icon(Icons.arrow_forward, size: 15),
                Text('Drop-off Location'),
                SizedBox(width: 55),
                Text("Price")
                // Text('LKR ${ride.price.toStringAsFixed(2)}'), // Assuming ride.price is the price per seat
              ],
            ),
          ),
          // Below the ride locations: Starting time, available seats
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Text('${ride.startTime} to ${ride.endTime}'),
                Text("9.00 am to 12.00pm"),
                SizedBox(width: 110),
                Text('Available Seats: ${ride["seats"]}'),
              ],
            ),
          ),
          Row(
            children: [
              Icon(Icons.directions_walk, color: Colors.green), // Human walking icon
              // Text('${pickupDistance.toStringAsFixed(1)} km'), // Distance
              Text('${pickupDistance} km'),
              Icon(Icons.arrow_forward_ios, size: 15), // Arrow icon
              Icon(Icons.directions_car),
              Icon(Icons.arrow_forward_ios, size: 15),
              Icon(Icons.directions_walk, color: Colors.red), // Red human walking icon
              // Text('${dropoffDistance.toStringAsFixed(1)} km'), // Distance
              Text('${dropoffDistance} km'),
            ],
          ),
          // Divider
          Divider(),
          // Below the divider: Driver information
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // CircleAvatar with verified badge
                Row(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          child: Icon(
                            Icons.person,
                            size: 20.0,
                          ),
                        ),
                        Icon(Icons.verified_user, color: Colors.green, size: 20),
                      ],
                    ),
                    SizedBox(width: 16),
                    // Driver's name, rating, and reviews
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(ride.driverName),
                        Text(driver["firstName"] + " " + driver["lastName"]),
                        Row(
                          children: [
                            Text(driver['ratings'].toString()),
                            Icon(Icons.star, color: Colors.blueGrey, size: 18),
                            SizedBox(width: 10.0),
                            Text('${driver['reviews'].length} reviews'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    print("nice");
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => RideDetails()),
                    // );
                  },
                  child: Text("Book Ride"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
