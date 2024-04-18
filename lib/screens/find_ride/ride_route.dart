import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideMapScreen extends StatelessWidget {
  final DocumentSnapshot ride;
  final GeoPoint closestCoordinateToPickup;
  final GeoPoint closestCoordinateToDropoff;
  final GeoPoint userPickupLocation;
  final GeoPoint userDropoffLocation;

  RideMapScreen(
      {required this.ride,
      required this.closestCoordinateToPickup,
      required this.userPickupLocation, required this.closestCoordinateToDropoff, required this.userDropoffLocation});

  @override
  Widget build(BuildContext context) {
    LatLng closestToPickupPosition = LatLng(
      closestCoordinateToPickup.latitude,
      closestCoordinateToPickup.longitude,
    );

    LatLng closestToDropPosition = LatLng(closestCoordinateToDropoff.latitude, closestCoordinateToDropoff.longitude);

    LatLng userPickupPosition = LatLng(
      userPickupLocation.latitude,
      userPickupLocation.longitude,
    );

    LatLng userDropoffPosition = LatLng(
      userDropoffLocation.latitude,
      userDropoffLocation.longitude,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigator.pop(
              //   context,
              //   MaterialPageRoute(builder: (context) => AvailableRides()),
              // );
            },
            icon: Icon(Icons.arrow_back_ios)),
        title: Text('Ride Details Map'),
        titleSpacing: 0,
        leadingWidth: 60.0,
        backgroundColor: Colors.green,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
            ride['pickupLocation']['geopoint'].latitude,
            ride['pickupLocation']['geopoint'].longitude,
          ),
          zoom: 12,
        ),
        markers: {
          Marker(
            markerId: MarkerId('pickup'),
            position: LatLng(
              ride['pickupLocation']['geopoint'].latitude,
              ride['pickupLocation']['geopoint'].longitude,
            ),
            infoWindow: InfoWindow(title: 'Pickup Location'),
          ),
          Marker(
            markerId: MarkerId('dropoff'),
            position: LatLng(
              ride['dropoffLocation']['geopoint'].latitude,
              ride['dropoffLocation']['geopoint'].longitude,
            ),
            infoWindow: InfoWindow(title: 'Drop-off Location'),
          ),
          Marker(
            markerId: MarkerId('closestToPickup'),
            position: LatLng(
              closestCoordinateToPickup.latitude,
              closestCoordinateToPickup.longitude,
            ),
            infoWindow: InfoWindow(title: 'Closest to Pickup'),
          ),
          Marker(
            markerId: MarkerId('ToPickup'),
            position: LatLng(
              userPickupLocation.latitude,
              userPickupLocation.longitude,
            ),
            infoWindow: InfoWindow(title: 'your location'),
          ),
          Marker(
            markerId: MarkerId('ToDropoff'),
            position: LatLng(
              closestToDropPosition.latitude,
              closestToDropPosition.longitude,
            ),
            infoWindow: InfoWindow(title: 'closest to your drop location'),
          ),
          Marker(
            markerId: MarkerId('UserDropoff'),
            position: LatLng(
              userDropoffPosition.latitude,
              userDropoffPosition.longitude,
            ),
            infoWindow: InfoWindow(title: 'your picked drop location'),
          ),
        },
        polylines: {
          Polyline(
            polylineId: PolylineId('route'),
            points:
                List<LatLng>.from((ride['polylinePoints'] as List).map((point) {
              return LatLng(point['latitude'], point['longitude']);
            })),
            color: Colors.blue,
            width: 5,
          ),
          Polyline(
            polylineId: PolylineId('pickupMovementLine'),
            points: [userPickupPosition, closestToPickupPosition],
            color: Colors.red,
            width: 3,
          ),
          Polyline(
            polylineId: PolylineId('dropMovementLine'),
            points: [userDropoffPosition, closestToDropPosition],
            color: Colors.red,
            width: 3,
          ),
        },
      ),
    );
  }
}
