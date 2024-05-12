import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;

class RideMapScreen extends StatefulWidget {
  final DocumentSnapshot ride;
  final GeoPoint closestCoordinateToPickup;
  final GeoPoint closestCoordinateToDropoff;
  final GeoPoint userPickupLocation;
  final GeoPoint userDropoffLocation;

  RideMapScreen({required this.ride,
    required this.closestCoordinateToPickup,
    required this.userPickupLocation, required this.closestCoordinateToDropoff, required this.userDropoffLocation});

  @override
  State<RideMapScreen> createState() => _RideMapScreenState();
}

class _RideMapScreenState extends State<RideMapScreen> {

  Set<Marker> markers = {};


  @override
  Widget build(BuildContext context) {

    LatLng closestToPickupPosition = LatLng(
      widget.closestCoordinateToPickup.latitude,
      widget.closestCoordinateToPickup.longitude,
    );

    LatLng closestToDropPosition = LatLng(
        widget.closestCoordinateToDropoff.latitude,
        widget.closestCoordinateToDropoff.longitude);

    LatLng userPickupPosition = LatLng(
      widget.userPickupLocation.latitude,
      widget.userPickupLocation.longitude,
    );

    LatLng userDropoffPosition = LatLng(
      widget.userDropoffLocation.latitude,
      widget.userDropoffLocation.longitude,
    );

    markers.addAll([
      Marker(
        markerId: MarkerId('pickup'),
        position: LatLng(
          widget.ride['pickupLocation']['geopoint'].latitude,
          widget.ride['pickupLocation']['geopoint'].longitude,
        ),
        infoWindow: InfoWindow(title: 'Pickup Location'),
      ),
      Marker(
        markerId: MarkerId('dropoff'),
        position: LatLng(
          widget.ride['dropoffLocation']['geopoint'].latitude,
          widget.ride['dropoffLocation']['geopoint'].longitude,
        ),
        infoWindow: InfoWindow(title: 'Drop-off Location'),
      ),
      Marker(
        markerId: MarkerId('closestToPickup'),
        position: closestToPickupPosition, // Use updated position
        infoWindow: InfoWindow(title: '$closestToPickupPosition'),
      ),
      Marker(
        markerId: MarkerId('ToPickup'),
        position: LatLng(
          widget.userPickupLocation.latitude,
          widget.userPickupLocation.longitude,
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
    ]);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
        title: const Text('Ride Details Map'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
            widget.ride['pickupLocation']['geopoint'].latitude,
            widget.ride['pickupLocation']['geopoint'].longitude,
          ),
          zoom: 12,
        ),
        onTap: (LatLng latLng) {
          LatLng closestToPickupPos = findNearestPointOnPolyline(latLng);
          print('Nearest point to tap: $closestToPickupPos');
          setState(() {
            closestToPickupPosition = closestToPickupPos; // Update the state

            // Find the existing marker with markerId 'closestToPickup'
            Marker existingMarker = markers.firstWhere(
                  (marker) => marker.markerId.value == 'closestToPickup',
              orElse: () => const Marker(markerId: MarkerId('closestToPickup')), // Create a new marker if not found
            );

            // Update the position of the existing marker
            existingMarker = existingMarker.copyWith(
              positionParam: closestToPickupPosition,
            );

            // Update the markers set with the modified marker
            markers = Set.of(markers..removeWhere((marker) => marker.markerId.value == 'closestToPickup')..add(existingMarker));

            // Print the updated markers set
            markers.forEach((marker) {
              print(marker.markerId.value);
            });
          });
        },
        markers: markers ,
        polylines: {
          Polyline(
            polylineId: PolylineId('route'),
            points:
            List<LatLng>.from(
                (widget.ride['polylinePoints'] as List).map((point) {
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

  double calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    const int earthRadius = 6371000; // in meters
    double lat1Rad = radians(startLatitude);
    double lon1Rad = radians(startLongitude);
    double lat2Rad = radians(endLatitude);
    double lon2Rad = radians(endLongitude);

    double deltaLat = lat2Rad - lat1Rad;
    double deltaLon = lon2Rad - lon1Rad;

    double a = math.pow(math.sin(deltaLat / 2), 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.pow(math.sin(deltaLon / 2), 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double radians(double degrees) {
    return degrees * (math.pi / 180);
  }

  LatLng findNearestPointOnPolyline(LatLng tapLatLng) {
    print('Tapped location: $tapLatLng');
    // Calculate nearest point on the polyline to the tap
    List<LatLng> polylinePoints = List<LatLng>.from(
        widget.ride['polylinePoints']
            .map<LatLng>((point) =>
            LatLng(point['latitude'], point['longitude'])));

    double minDistance = double.infinity;
    LatLng nearestPoint = polylinePoints.first;

    for (LatLng point in polylinePoints) {
      double distance = calculateDistance(
        tapLatLng.latitude,
        tapLatLng.longitude,
        point.latitude,
        point.longitude,
      );
      // print('Distance to point $point: $distance');
      if (distance < minDistance) {
        minDistance = distance;
        nearestPoint = point;
      }
    }
    debugPrint('Nearest point: $nearestPoint');
    return nearestPoint;
  }
}

