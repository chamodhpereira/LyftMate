import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'available_rides.dart';

class FindRides extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Example user pickup and dropoff locations
    GeoPoint userPickupLocation = GeoPoint(6.933086200454551, 79.8626836197483);
    GeoPoint userDropoffLocation = GeoPoint(7.200685034738829, 79.87483156978818);

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RideMatchingScreen(
                  userPickupLocation: userPickupLocation,
                  userDropoffLocation: userDropoffLocation,
                ),
              ),
            );
          },
          child: Text('View Filtered Rides'),
        ),
      ),
    );
  }
}