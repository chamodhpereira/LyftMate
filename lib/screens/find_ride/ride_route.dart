import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideMapScreen extends StatelessWidget {
  final DocumentSnapshot ride;
  final GeoPoint closestCoordinateToPickup;
  final GeoPoint userLocation;

  RideMapScreen({required this.ride, required this.closestCoordinateToPickup, required this.userLocation});

  @override
  Widget build(BuildContext context) {


    LatLng closestToPickupPosition = LatLng(
      closestCoordinateToPickup.latitude,
      closestCoordinateToPickup.longitude,
    );

    LatLng userPickupPosition = LatLng(
      userLocation.latitude,
      userLocation.longitude,
    );

    return GoogleMap(
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
            userLocation.latitude,
            userLocation.longitude,
          ),
          infoWindow: InfoWindow(title: 'your location'),
        ),
      },
      polylines: {
        Polyline(
          polylineId: PolylineId('route'),
          points: List<LatLng>.from((ride['polylinePoints'] as List).map((point) {
            return LatLng(point['latitude'], point['longitude']);
          })),
          color: Colors.blue,
          width: 5,
        ),
        Polyline(
          polylineId: PolylineId('movementLine'),
          points: [userPickupPosition, closestToPickupPosition],
          color: Colors.red,
          width: 3,
        ),
      },
    );
  }
}