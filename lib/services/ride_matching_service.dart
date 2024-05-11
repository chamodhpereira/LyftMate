import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:dart_geohash/dart_geohash.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../screens/find_ride/available_rides.dart';

class RideMatching {
  final client = Client();
  final geo = GeoFlutterFire();
  GeoHasher geoHasher = GeoHasher();

  String _getApiKey() {
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'YOUR_DEFAULT_API_KEY';
  }

  Future<bool> isHighway(LatLng coordinate) async {
    try {
      final roadsResponse = await client.get(Uri.parse(
          'https://roads.googleapis.com/v1/nearestRoads?points=${coordinate.latitude},${coordinate.longitude}&key=${_getApiKey()}'));

      if (roadsResponse.statusCode == 200) {
        final roadsData = json.decode(roadsResponse.body);
        final placeId = roadsData['snappedPoints'][0]['placeId'] as String;

        final placesResponse = await client.get(Uri.parse(
            'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=address_components&key=${_getApiKey()}'));

        if (placesResponse.statusCode == 200) {
          final placesData = json.decode(placesResponse.body);
          final addressComponents =
          placesData['result']['address_components'] as List<dynamic>;

          for (final component in addressComponents) {
            final longName = component['long_name'] as String;
            if (longName.toLowerCase().contains('expressway') ||
                longName.toLowerCase().contains('highway')) {
              return true;
            }
          }
        }
      }

      return false;
    } catch (e) {
      print('Error checking if coordinate is a highway/expressway: $e');
      return false;
    }
  }



  // // Generate a list of geohashes that cover the area around the provided geopoint
  List<String> generateNearbyGeohashes(double latitude, double longitude) {
    String centralGeohash = geoHasher.encode(longitude, latitude,
        precision: 5); // Correct parameter is 'precision'
    // List<String> nearbyGeohashes = geoHasher.neighbors(centralGeohash); // Correct method call
    Map<String, String> nearbyGeohashesMap = geoHasher.neighbors(
        centralGeohash); // Assuming neighbors() returns a Map<String, String>
    List<String> nearbyGeohashes = nearbyGeohashesMap.values.toList();
    nearbyGeohashes.add(centralGeohash); // Include the central geohash

    // Print nearby GeoHashes
    print("Nearby GeoHashes:");
    nearbyGeohashes.forEach((geohash) =>
        print("GEOOOOOOOOOOOOOOOO---------HASHERRRRRRRRRRRRRR--- $geohash"));
    return nearbyGeohashes;
  }

  void printRidesWithDistances(List<Map<String, dynamic>> ridesWithDistances) {
    print(
        '*****Length of ridesWithDistances: *********${ridesWithDistances.length}');
    print('********Ride IDs:************');
    for (var rideData in ridesWithDistances) {
      print(rideData['ride'].id);
    }
  }

  // currently working - 4/26/2024
  Future<List<Map<String, dynamic>>> findRidesWithDistances(
      LatLng userPickupLocation,
      LatLng userDropoffLocation,
      DateTime? desiredDate,
      {double walkingDistance = 0.0,
      List<String>? preferences,
      int selectedTimeSlot = -1}) async {
    List<Map<String, dynamic>> ridesWithDistances = [];

    // Define the time slot ranges
    List<DateTimeRange> timeSlotRanges = [
      DateTimeRange(
        start: DateTime(desiredDate!.year, desiredDate.month, desiredDate.day, 0, 0),
        end: DateTime(desiredDate.year, desiredDate.month, desiredDate.day, 5, 59),
      ),
      DateTimeRange(
        start: DateTime(desiredDate.year, desiredDate.month, desiredDate.day, 6, 0),
        end: DateTime(desiredDate.year, desiredDate.month, desiredDate.day, 11, 59),
      ),
      DateTimeRange(
        start: DateTime(desiredDate.year, desiredDate.month, desiredDate.day, 12, 0),
        end: DateTime(desiredDate.year, desiredDate.month, desiredDate.day, 17, 59),
      ),
      DateTimeRange(
        start: DateTime(desiredDate.year, desiredDate.month, desiredDate.day, 18, 0),
        end: DateTime(desiredDate.year, desiredDate.month, desiredDate.day, 23, 59),
      ),
    ];


    try {
      List<String> pickupGeohashes = generateNearbyGeohashes(
          userPickupLocation.latitude, userPickupLocation.longitude);
      List<String> dropoffGeohashes = generateNearbyGeohashes(
          userDropoffLocation.latitude, userDropoffLocation.longitude);

      Timestamp startTime = Timestamp.fromDate(DateTime(
          desiredDate!.year, desiredDate.month, desiredDate.day, 0, 0, 0));
      Timestamp endTime = Timestamp.fromDate(DateTime(
          desiredDate.year, desiredDate.month, desiredDate.day, 23, 59, 59));
      print("--------------------------------------------------");
      print("TIMESSSSSSSSTAAAAMP start: $startTime");

      // print("WALKINGGGGGGGGG DISTANCEEEEEE $walkingDistance");
      double distanceThreshold = 1000;

      if (walkingDistance > 0.0) {
        print("WALKINGGGGGGGGG DISTANCEEEEEE ${walkingDistance * 1000}");
        print("WALKING DISTANCE IN METERSSS: ${walkingDistance / 1000}");
        distanceThreshold = walkingDistance * 1000;
      }

      print("DISTANCEEE THRESHOLDDD: $distanceThreshold");
      print("PREFEREEEECESSSSS: $preferences");
      print("--------------------------------------------------");

      // generateNearbyGeohashes(7.201192460189143, 79.87352611754969);

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('rides')
          .where('date',
              isGreaterThanOrEqualTo:
                  startTime) // Filter rides starting from the beginning of the desired date
          .where('date',
              isLessThanOrEqualTo:
                  endTime) // Filter rides up to the end of the desired date
          .get();
      List<DocumentSnapshot> rides = snapshot.docs;

      // rides = rides.where((ride) {
      //   GeoPoint dropoffLocation = ride['dropoffLocation']['geopoint'];
      //
      //   return dropoffLocation.latitude == userDropoffLocation.latitude &&
      //       dropoffLocation.longitude == userDropoffLocation.longitude;
      // }).toList();

      // Apply filtering based on the selected time slot
      if (selectedTimeSlot >= 0 && selectedTimeSlot < timeSlotRanges.length) {
        DateTimeRange range = timeSlotRanges[selectedTimeSlot];
        rides = rides.where((ride) {
          DateTime rideTime = (ride['time'] as Timestamp).toDate();
          return rideTime.isAfter(range.start) && rideTime.isBefore(range.end);
        }).toList();
      }

      // If preferences are provided, filter rides based on preferences
      if (preferences != null && preferences.isNotEmpty) {
        rides = rides.where((ride) {
          List<String> ridePreferences =
              List<String>.from(ride['ridePreferences']);

          // Check if all ride preferences are present in user preferences
          return preferences
              .every((preference) => ridePreferences.contains(preference));
        }).toList();
      }

      print("FILETERRRRRREEEEEEEEEED DRIDESSSSSSSS: ${rides.length}");

      for (var ride in rides) {
        print('Processing document: $ride');

        Map<String, dynamic> rideData = ride.data() as Map<String, dynamic>;
        print('Ride data: $rideData');

        Map<dynamic, dynamic> polylineGeohashes =
            rideData['polylinePointsGeohashes'] ?? {};
        // print('Polyline geohashes: $polylineGeohashes');

        List<LatLng> matchedPickupCoordinates = [];
        List<LatLng> matchedDropoffCoordinates = [];

        pickupGeohashes.forEach((gh) {
          // print('Checking pickup geohash: $gh');
          if (polylineGeohashes.containsKey(gh)) {
            var coords = polylineGeohashes[gh];
            // print('Found matching geohash for pickup: $gh, coordinates: $coords');
            if (coords != null) {
              matchedPickupCoordinates.addAll(coords.map<LatLng>(
                  (coord) => LatLng(coord['latitude'], coord['longitude'])));
            }
          }
        });

        dropoffGeohashes.forEach((gh) {
          // print('Checking dropoff geohash: $gh');
          if (polylineGeohashes.containsKey(gh)) {
            var coords = polylineGeohashes[gh];
            // print('Found matching geohash for dropoff: $gh, coordinates: $coords');
            if (coords != null) {
              matchedDropoffCoordinates.addAll(coords.map<LatLng>(
                  (coord) => LatLng(coord['latitude'], coord['longitude'])));
            }
          }
        });

        // Find the closest coordinates for pickup and dropoff
        LatLng closestSnappedPickupCoordinate =
            findClosestCoordinate(userPickupLocation, matchedPickupCoordinates);
        LatLng closestSnappedDropoffCoordinate = findClosestCoordinate(
            userDropoffLocation, matchedDropoffCoordinates);

        // LatLng closestSnappedPickupCoordinate = await findClosestCoordinate(userPickupLocation, matchedPickupCoordinates);
        // LatLng closestSnappedDropoffCoordinate = await findClosestCoordinate(userDropoffLocation, matchedDropoffCoordinates);

        debugPrint("USERRRR Pickup $userPickupLocation");
        debugPrint(
            "USERRRR closest snnapedddd $closestSnappedPickupCoordinate");

        print(
            'Closest snapped pickup coordinate: $closestSnappedPickupCoordinate');
        print(
            'Closest snapped dropoff coordinate: $closestSnappedDropoffCoordinate');

        if (await isHighway(closestSnappedPickupCoordinate) || await isHighway(closestSnappedDropoffCoordinate)) {
          debugPrint("==============================================");
          debugPrint("----------------falllssss on high waaaayyyyy-------");
          debugPrint("==============================================");


          continue; // Skip this ride if either snapped pickup or drop-off is on a highway/expressway
        }


        double minPickupDistance = 0.0;
        double minDropoffDistance = 0.0;

        Future<void> calculateDistances() async {
          try {
            minPickupDistance = await calculateRouteDistance(
              userPickupLocation,
              closestSnappedPickupCoordinate,
            );
            minDropoffDistance = await calculateRouteDistance(
              userDropoffLocation,
              closestSnappedDropoffCoordinate,
            );

            // Now you can use minPickupDistance and minDropoffDistance as doubles
            print("Minimum Pickup Distance: $minPickupDistance meters");
            print("Minimum Dropoff Distance: $minDropoffDistance meters");

            // Any further code that needs these distances can go here
          } catch (e) {
            print("Failed to calculate distances: $e");
          }
        }

        await calculateDistances();

        print(
            'Min pickup distance: $minPickupDistance meters, Threshold: $distanceThreshold meters');
        print(
            'Min dropoff distance: $minDropoffDistance meters, Threshold: $distanceThreshold meters');
        if (minPickupDistance <= distanceThreshold &&
            minDropoffDistance <= distanceThreshold) {
          print('Both pickup and dropoff within walking distance.');
          // Add to ridesWithDistances
        } else {
          print('One or both distances exceed the threshold.');
        }

        String pickupDistanceText =
            '${(minPickupDistance / 1000).toStringAsFixed(2)} km';
        String dropoffDistanceText =
            '${(minDropoffDistance / 1000).toStringAsFixed(2)} km';
        // String pickupDistanceText = '${(minPickupDistance).toStringAsFixed(2)} km';
        // String dropoffDistanceText = '${(minDropoffDistance).toStringAsFixed(2)} km';
        debugPrint("PICKUP DST TEXT: $pickupDistanceText");

        print(
            'Min pickup distance: $minPickupDistance, Min dropoff distance: $minDropoffDistance');
        print('DISATCNEEEE THERESHOLD: $distanceThreshold');

        print(
            'Min pickup distance: $minPickupDistance meters, Threshold: $distanceThreshold meters');
        print(
            'Min dropoff distance: $minDropoffDistance meters, Threshold: $distanceThreshold meters');
        if (minPickupDistance <= distanceThreshold &&
            minDropoffDistance <= distanceThreshold) {
          print('Both pickup and dropoff within walking distance.');
          // Add to ridesWithDistances
        } else {
          print('One or both distances exceed the threshold.');
        }

        // if (minPickupDistance <= walkingDistance && minDropoffDistance <= walkingDistance) {
        if (minPickupDistance <= distanceThreshold &&
            minDropoffDistance <= distanceThreshold) {
          print('Both pickup and dropoff within walking distance.');

          ridesWithDistances.add({
            'ride': ride,
            'pickupDistance': minPickupDistance,
            'dropoffDistance': minDropoffDistance,
            'pickupDistanceText': pickupDistanceText,
            'dropoffDistanceText': dropoffDistanceText,
            'closestSnappedPickupCoordinate': closestSnappedPickupCoordinate,
            'closestSnappedDropoffCoordinate': closestSnappedDropoffCoordinate,
          });
        }
      }

      printRidesWithDistances(ridesWithDistances);

      return ridesWithDistances;
    } catch (e) {
      print("Error fetching rides: $e");
      return [];
    }
  }

  Future<double> getRouteDistance(LatLng start, LatLng destination) async {
    final apiKey = _getApiKey();
    const String baseUrl =
        'https://maps.googleapis.com/maps/api/directions/json';
    final String url =
        '$baseUrl?origin=${start.latitude},${start.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    var response = await client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['routes'].isNotEmpty) {
        var route = data['routes'][0];
        var leg = route['legs'][0];
        // double distance = leg['distance']['value'];  // Distance in meters\
        int distanceValue =
            leg['distance']['value']; // The API returns an integer
        double distance = distanceValue.toDouble();
        debugPrint("==================Distanceee============ $distance");
        return distance;
      }
      return 0.0; // No route found
    } else {
      throw Exception('Failed to fetch route data');
    }
  }

  Future<double> calculateRouteDistance(
      LatLng userLocation, LatLng pickupLocation) async {
    // LatLng userLocation = LatLng(-34.6037, -58.3816);  // Example coordinates
    // LatLng pickupLocation = LatLng(-34.6159, -58.4333);  // Example coordinates
    try {
      double distance = await getRouteDistance(userLocation, pickupLocation);
      print("Distance to pickup: $distance meters");
      return distance;
    } catch (e) {
      print("Error getting distance: $e");
      return 0;
    }
  }

  LatLng findClosestCoordinate(LatLng baseLocation, List<LatLng> coordinates) {
    double minDistance = double.infinity;
    LatLng closestCoordinate =
        LatLng(0, 0); // Default to an unlikely coordinate

    debugPrint("COOOOOOOOOOOOOOOORDINATESSSSSSSSSSSSS_ $coordinates");

    for (LatLng coord in coordinates) {
      double distance = calculateUpdatedDistance(baseLocation, coord);
      if (distance < minDistance) {
        minDistance = distance;
        closestCoordinate = coord;
      }
    }

    return closestCoordinate;
  }

  double calculateUpdatedDistance(LatLng start, LatLng end) {
    var rad = (x) => x * math.pi / 180;
    var R = 6378137; // Earth’s mean radius in meter
    var dLat = rad(end.latitude - start.latitude);
    var dLong = rad(end.longitude - start.longitude);
    var a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(rad(start.latitude)) *
            math.cos(rad(end.latitude)) *
            math.sin(dLong / 2) *
            math.sin(dLong / 2);
    var c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    var distance = R * c;
    return distance; // returns the distance in meter
  }


  Future<List<LatLng>> callNearbySearchAPI(LatLng coordinate) async {
    final apiKey = _getApiKey();
    final String baseUrl =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

    // Construct the URL for the Nearby Search API request
    final String url =
        '$baseUrl?location=${coordinate.latitude},${coordinate.longitude}&radius=500&type=route&key=$apiKey';

    // Make the HTTP request
    final response = await client.get(Uri.parse(url));

    // Check if the response is successful
    if (response.statusCode == 200) {
      // Parse the JSON response
      final Map<String, dynamic> data = json.decode(response.body);

      // Extract route coordinates from the response
      List<LatLng> routeCoordinates = _extractRouteCoordinates(data);

      return routeCoordinates;
    } else {
      // If the request was not successful, throw an exception or handle the error accordingly
      throw Exception('Failed to load route coordinates');
    }
  }

// Helper method to extract route coordinates from the Nearby Search API response
  List<LatLng> _extractRouteCoordinates(Map<String, dynamic> data) {
    List<LatLng> routeCoordinates = [];

    // Extract the results array from the response
    List<dynamic> results = data['results'];

    // Iterate through the results array
    for (var result in results) {
      // Extract the location object from each result
      Map<String, dynamic> location = result['geometry']['location'];
      // Extract the latitude and longitude from the location object
      double latitude = location['lat'];
      double longitude = location['lng'];
      // Create a LatLng object and add it to the routeCoordinates list
      routeCoordinates.add(LatLng(latitude, longitude));
    }

    return routeCoordinates;
  }

  Future<List<LatLng>> snapToRoads(LatLng coordinate) async {
    final apiKey = _getApiKey();
    final String baseUrl = 'https://roads.googleapis.com/v1/snapToRoads';

    final String url =
        '$baseUrl?path=${coordinate.latitude},${coordinate.longitude}&key=$apiKey';

    final response = await client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> snappedPoints = data['snappedPoints'];

      // Check if there are snapped points returned
      if (snappedPoints.isNotEmpty) {
        // Extract latitude and longitude of each snapped point and create LatLng objects
        List<LatLng> snappedCoordinates = snappedPoints.map((point) {
          double latitude = point['location']['latitude'];
          double longitude = point['location']['longitude'];
          print(
              'Snapped PPPPPPPoint: Latitude: $latitude, Longitude: $longitude');
          return LatLng(latitude, longitude);
        }).toList();

        return snappedCoordinates;
      }
    }

    // Return an empty list if snapping fails or no snapped points are returned
    return [];
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
}

