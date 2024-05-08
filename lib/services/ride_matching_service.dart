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

      // for (var doc in rides) {
      //   Map<String, dynamic> ride = doc.data() as Map<String, dynamic>;
      //   List<dynamic> rideGeohashesList = ride['polylinePointsGeohashes'];
      //   List<String> rideGeohashes = [];
      //
      //   for (var geohashMap in rideGeohashesList) {
      //     if (geohashMap is Map<String, dynamic> && geohashMap.containsKey('geohash')) {
      //       rideGeohashes.add(geohashMap['geohash']);
      //     }
      //   }
      //
      //   bool pickupMatch = pickupGeohashes.any((geohash) => rideGeohashes.contains(geohash));
      //   bool dropoffMatch = dropoffGeohashes.any((geohash) => rideGeohashes.contains(geohash));
      //
      //   if (pickupMatch && dropoffMatch) {
      //     debugPrint("HAMBUNAAAAAAAAA WTTOOOOOOOOO");
      //   }
      // }

      // for (var doc in rides) {
      //   Map<String, dynamic> ride = doc.data() as Map<String, dynamic>;
      //   Map<dynamic, dynamic> rideGeohashes = ride['polylinePointsGeohashes'] ?? {};
      //
      //   // Check if any geohash from the user's pickup or dropoff geohashes matches the ride's geohashes
      //   bool pickupMatch = pickupGeohashes.any((gh) => rideGeohashes.containsKey(gh));
      //   bool dropoffMatch = dropoffGeohashes.any((gh) => rideGeohashes.containsKey(gh));
      //
      //   if (pickupMatch && dropoffMatch) {
      //     debugPrint("HAMBUNAAAAAAAAA WTTOOOOOOOOO");
      //     // Calculate distances and further process the ride if it's within walking distance
      //     // Here you might calculate exact distances or add further checks/logic
      //     // ridesWithDistances.add({
      //     //   'ride': ride,
      //     //   'pickupMatch': pickupMatch,
      //     //   'dropoffMatch': dropoffMatch
      //     // });
      //   }
      // }

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

        // double minPickupDistance = calculateUpdatedDistance(userPickupLocation, closestSnappedPickupCoordinate);
        // double minDropoffDistance = calculateUpdatedDistance(userDropoffLocation, closestSnappedDropoffCoordinate);

        // double minPickupDistance = calculateDistance(
        //     userPickupLocation.latitude,
        //     userPickupLocation.longitude,
        //     closestSnappedPickupCoordinate.latitude,
        //     closestSnappedPickupCoordinate.longitude
        // );
        // double minDropoffDistance = calculateDistance(
        //     userDropoffLocation.latitude,
        //     userDropoffLocation.longitude,
        //     closestSnappedDropoffCoordinate.latitude,
        //     closestSnappedDropoffCoordinate.longitude
        // );

        // double minPickupDistance = calculateRouteDistance(
        //     userPickupLocation,
        //     closestSnappedPickupCoordinate,
        //
        // );
        // double minDropoffDistance = calculateRouteDistance(
        //     userDropoffLocation,
        //     closestSnappedDropoffCoordinate,
        //
        // );

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

      // return ridesWithDistances;

      // for (var ride in rides) {
      //   List<LatLng> polylineCoordinates = (ride['polylinePoints'] as List).map((point) {
      //     return LatLng(point['latitude'], point['longitude']);
      //   }).toList();
      //
      //   List<LatLng> snappedPickupCoordinates = await callNearbySearchAPI(userPickupLocation);
      //   print("SNAPED PICK UPPPPPPPPPP: $snappedPickupCoordinates");
      //   List<LatLng> snappedDropoffCoordinates = await callNearbySearchAPI(userDropoffLocation);
      //   print("SNAPED DROOOOOOOP UPPPPPPPPPP: $snappedDropoffCoordinates");
      //
      //   double minPickupDistance = double.infinity;
      //   LatLng closestSnappedPickupCoordinate = LatLng(0, 0);
      //   LatLng closestSnappedDropoffCoordinate = LatLng(0, 0);
      //
      //   for (LatLng snappedCoordinate in snappedPickupCoordinates) {
      //     for (LatLng polylineCoordinate in polylineCoordinates) {
      //       double distance = calculateDistance(
      //         snappedCoordinate.latitude,
      //         snappedCoordinate.longitude,
      //         polylineCoordinate.latitude,
      //         polylineCoordinate.longitude,
      //       );
      //
      //       if (distance < minPickupDistance) {
      //         minPickupDistance = distance;
      //         // closestSnappedPickupCoordinate = snappedCoordinate;
      //         closestSnappedPickupCoordinate = polylineCoordinate;
      //       }
      //     }
      //   }
      //
      //   GeoPoint dropoffLocation = ride['dropoffLocation']['geopoint'];
      //
      //   double minDropoffDistance = double.infinity;
      //   String pickupDistanceText = "";
      //   String dropoffDistanceText = "";
      //
      //     for (LatLng snappedCoordinate in snappedDropoffCoordinates) {
      //       for (LatLng polylineCoordinate in polylineCoordinates) {
      //         double distance = calculateDistance(
      //           snappedCoordinate.latitude,
      //           snappedCoordinate.longitude,
      //           polylineCoordinate.latitude,
      //           polylineCoordinate.longitude,
      //         );
      //
      //         if (distance < minDropoffDistance) {
      //           minDropoffDistance = distance;
      //           // closestSnappedDropoffCoordinate = snappedCoordinate;
      //           closestSnappedDropoffCoordinate = polylineCoordinate;
      //         }
      //       }
      //     }
      //
      //     pickupDistanceText =
      //         '${(minPickupDistance / 1000).toStringAsFixed(2)} km';
      //     print("PDT: $pickupDistanceText");
      //     dropoffDistanceText =
      //         '${(minDropoffDistance / 1000).toStringAsFixed(2)} km';
      //     print("DDDDDDDDDDDDT: $dropoffDistanceText");
      //
      //     print("MIN PICCCCK DIST: ${minPickupDistance}");
      //     print("DIST Threshold: ${distanceThreshold}");
      //     print("MIN DropDIST: ${minDropoffDistance}");
      //     print("DIST Threshold: ${distanceThreshold}");
      //
      //
      //   if (minPickupDistance < distanceThreshold &&
      //       minDropoffDistance < distanceThreshold) {
      //     print("CHECKINGGG TRUEEEE");
      //     print("MIN PICCCCK DIST: ${minPickupDistance}");
      //     print("DIST Threshold: ${distanceThreshold}");
      //     print("MIN DropDIST: ${minDropoffDistance}");
      //     print("DIST Threshold: ${distanceThreshold}");
      //     print("DISTANCE TEXT: $pickupDistanceText");
      //     print("Dstance text: $dropoffDistanceText");
      //     ridesWithDistances.add({
      //       'ride': ride,
      //       'pickupDistance': minPickupDistance,
      //       'dropoffDistance': minDropoffDistance,
      //       'pickupDistanceText': pickupDistanceText,
      //       'dropoffDistanceText': dropoffDistanceText,
      //       'closestSnappedPickupCoordinate': closestSnappedPickupCoordinate,
      //       'closestSnappedDropoffCoordinate': closestSnappedDropoffCoordinate,
      //     });
      //   }
      // }
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

  // Future<Map<String, dynamic>> getDistances(LatLng origin, List<LatLng> destinations) async {
  //   final apiKey = _getApiKey();
  //   final String origins = '${origin.latitude},${origin.longitude}';
  //   final String destinationList = destinations.map((dest) => '${dest.latitude},${dest.longitude}').join('|');
  //   // final String destinationList = destinations.take(5).map((dest) => '${dest.latitude},${dest.longitude}').join('|');
  //
  //   final String url = 'https://maps.googleapis.com/maps/api/distancematrix/json?origins=$origins&destinations=$destinationList&key=$apiKey';
  //
  //   var response = await client.get(Uri.parse(url));
  //   if (response.statusCode == 200) {
  //     return json.decode(response.body);
  //   } else {
  //     throw Exception('Failed to load distances');
  //   }
  // }
  //
  // Future<LatLng> findClosestCoordinate(LatLng origin, List<LatLng> destinations) async {
  //   try {
  //     var distancesResponse = await getDistances(origin, destinations);
  //     if (distancesResponse['rows'].isNotEmpty) {
  //       var elements = distancesResponse['rows'][0]['elements'];
  //       double minDistance = double.infinity;
  //       int closestIndex = 0;
  //
  //       for (int i = 0; i < elements.length; i++) {
  //         double distance = elements[i]['distance']['value'];
  //         if (distance < minDistance) {
  //           minDistance = distance;
  //           closestIndex = i;
  //         }
  //       }
  //       debugPrint("DIST MATRIXXXXXX CLOSEST COORD: ${destinations[closestIndex]}");
  //       return destinations[closestIndex];
  //     } else {
  //       throw Exception('No routes found.');
  //     }
  //   } catch (e) {
  //     print('Error finding closest coordinate: $e');
  //     return LatLng(0, 0); // Return a default or signal an error appropriately
  //   }
  // }

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

  // ---------------- previous one without going throigh all the rides ------
  // Future<List<Map<String, dynamic>>> findRidesWithDistances(
  //     LatLng userPickupLocation, LatLng userDropoffLocation, DateTime? desiredDate, {double walkingDistance = 0.0,  List<String>? preferences}) async {
  //   List<Map<String, dynamic>> ridesWithDistances = [];
  //
  //   try {
  //     Timestamp startTime = Timestamp.fromDate(DateTime(desiredDate!.year, desiredDate.month, desiredDate.day, 0, 0, 0));
  //     Timestamp endTime = Timestamp.fromDate(DateTime(desiredDate.year, desiredDate.month, desiredDate.day, 23, 59, 59));
  //     print("--------------------------------------------------");
  //     print("TIMESSSSSSSSTAAAAMP start: $startTime");
  //
  //     // print("WALKINGGGGGGGGG DISTANCEEEEEE $walkingDistance");
  //     double distanceThreshold = 3000;
  //
  //     if(walkingDistance > 0.0) {
  //       print("WALKINGGGGGGGGG DISTANCEEEEEE ${walkingDistance * 1000}");
  //       print("WALKING DISTANCE IN METERSSS: ${walkingDistance/1000}");
  //       distanceThreshold = walkingDistance * 1000;
  //     }
  //
  //     print("DISTANCEEE THRESHOLDDD: $distanceThreshold");
  //     print("PREFEREEEECESSSSS: $preferences");
  //     print("--------------------------------------------------");
  //
  //
  //
  //     QuerySnapshot snapshot = await FirebaseFirestore.instance
  //         .collection('rides')
  //         .where('date', isGreaterThanOrEqualTo: startTime) // Filter rides starting from the beginning of the desired date
  //         .where('date', isLessThanOrEqualTo: endTime) // Filter rides up to the end of the desired date
  //         .get();
  //     List<DocumentSnapshot> rides = snapshot.docs;
  //
  //     // Filter rides based on drop-off location matching the user's drop-off location
  //     List<DocumentSnapshot> filteredRides = rides.where((ride) {
  //       GeoPoint dropoffLocation = ride['dropoffLocation']['geopoint'];
  //
  //       return dropoffLocation.latitude == userDropoffLocation.latitude &&
  //           dropoffLocation.longitude == userDropoffLocation.longitude;
  //     }).toList();
  //
  //
  //     if (filteredRides.isEmpty) {
  //       final GeoFirePoint geoPoint =
  //       GeoFirePoint(userDropoffLocation.latitude, userDropoffLocation.longitude);
  //       String userDropoffGeohash = geoPoint.hash;
  //       userDropoffGeohash = userDropoffGeohash.substring(0, 4);
  //       print("USER DROPGEOHASH - $userDropoffGeohash");
  //
  //       // Generate a list of nearby geohashes around the user's dropoff location
  //       List<String> nearbyGeohashes = generateNearbyGeohashes(userDropoffGeohash);
  //
  //
  //       filteredRides = rides.where((ride) {
  //         String rideDropoffGeohash =
  //         ride['dropoffLocation']['geohash'].substring(0, 4); // keep it 5
  //         print("RIDes DROPGEOHASH - $rideDropoffGeohash");
  //         return rideDropoffGeohash == userDropoffGeohash;
  //         // return nearbyGeohashes.contains(rideDropoffGeohash);
  //       }).toList();
  //     }
  //
  //
  //     // If preferences are provided, filter rides based on preferences
  //     if (preferences != null && preferences.isNotEmpty) {
  //       filteredRides = filteredRides.where((ride) {
  //         List<String> ridePreferences = List<String>.from(ride['ridePreferences']);
  //
  //         // Check if all ride preferences are present in user preferences
  //         return preferences.every((preference) => ridePreferences.contains(preference));
  //       }).toList();
  //     }
  //
  //     print("FILETERRRRRREEEEEEEEEED DRIDESSSSSSSS: ${filteredRides.length}");
  //
  //
  //
  //     for (var ride in filteredRides) {
  //       List<LatLng> polylineCoordinates = (ride['polylinePoints'] as List).map((point) {
  //         return LatLng(point['latitude'], point['longitude']);
  //       }).toList();
  //
  //       List<LatLng> snappedPickupCoordinates = await callNearbySearchAPI(userPickupLocation);
  //       List<LatLng> snappedDropoffCoordinates = await callNearbySearchAPI(userDropoffLocation);
  //
  //       double minPickupDistance = double.infinity;
  //       LatLng closestSnappedPickupCoordinate = LatLng(0, 0);
  //       LatLng closestSnappedDropoffCoordinate = LatLng(0, 0);
  //
  //       for (LatLng snappedCoordinate in snappedPickupCoordinates) {
  //         for (LatLng polylineCoordinate in polylineCoordinates) {
  //           double distance = calculateDistance(
  //             snappedCoordinate.latitude,
  //             snappedCoordinate.longitude,
  //             polylineCoordinate.latitude,
  //             polylineCoordinate.longitude,
  //           );
  //
  //           if (distance < minPickupDistance) {
  //             minPickupDistance = distance;
  //             // closestSnappedPickupCoordinate = snappedCoordinate;
  //             closestSnappedPickupCoordinate = polylineCoordinate;
  //           }
  //         }
  //       }
  //
  //       double minDropoffDistance = double.infinity;
  //
  //       for (LatLng snappedCoordinate in snappedDropoffCoordinates) {
  //         for (LatLng polylineCoordinate in polylineCoordinates) {
  //           double distance = calculateDistance(
  //             snappedCoordinate.latitude,
  //             snappedCoordinate.longitude,
  //             polylineCoordinate.latitude,
  //             polylineCoordinate.longitude,
  //           );
  //
  //           if (distance < minDropoffDistance) {
  //             minDropoffDistance = distance;
  //             // closestSnappedDropoffCoordinate = snappedCoordinate;
  //             closestSnappedDropoffCoordinate = polylineCoordinate;
  //           }
  //         }
  //       }
  //
  //       String pickupDistanceText = '${(minPickupDistance / 1000).toStringAsFixed(2)} km';
  //       print("PDT: $pickupDistanceText");
  //       String dropoffDistanceText = '${(minDropoffDistance / 1000).toStringAsFixed(2)} km';
  //       print("DDDDDDDDDDDDT: $dropoffDistanceText");
  //
  //       print("MIN PICCCCK DIST: ${minPickupDistance}");
  //       print("DIST Threshold: ${distanceThreshold}");
  //       print("MIN DropDIST: ${minDropoffDistance}");
  //       print("DIST Threshold: ${distanceThreshold}");
  //
  //       if (minPickupDistance < distanceThreshold && minDropoffDistance < distanceThreshold) {
  //         print("CHECKINGGG TRUEEEE");
  //         ridesWithDistances.add({
  //           'ride': ride,
  //           'pickupDistance': minPickupDistance,
  //           'dropoffDistance': minDropoffDistance,
  //           'pickupDistanceText': pickupDistanceText,
  //           'dropoffDistanceText': dropoffDistanceText,
  //           'closestSnappedPickupCoordinate': closestSnappedPickupCoordinate,
  //           'closestSnappedDropoffCoordinate': closestSnappedDropoffCoordinate,
  //         });
  //       }
  //     }
  //
  //     return ridesWithDistances;
  //
  //   } catch (e) {
  //     print("Error fetching rides: $e");
  //     return [];
  //   }
  // }

  // List<String> generateNearbyGeohashes(GeoFirePoint baseGeoPoint) {
  //   // Define the radius in kilometers (adjust as needed)
  //   double radiusInKm = 5.0;
  //
  //   // Define the precision level (adjust as needed)
  //   int precision = 5;
  //
  //   // Calculate the number of steps needed for the radius
  //   double stepSize = 2 *
  //       radiusInKm /
  //       1000; // Each step is approximately 1 km at precision level 5
  //   int numSteps = (radiusInKm / stepSize).ceil();
  //
  //   // Generate nearby geohashes
  //   List<String> nearbyGeohashes = [];
  //   for (int dx = -numSteps; dx <= numSteps; dx++) {
  //     for (int dy = -numSteps; dy <= numSteps; dy++) {
  //       GeoFirePoint nearbyPoint = GeoFirePoint(
  //         baseGeoPoint.latitude + stepSize * dx,
  //         baseGeoPoint.longitude + stepSize * dy,
  //       );
  //       String nearbyGeohash = nearbyPoint.hash.substring(0, precision);
  //       nearbyGeohashes.add(nearbyGeohash);
  //     }
  //   }
  //
  //   return nearbyGeohashes;
  // }

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

//  ------------------------------------------------ workingggggg but lines through buildings -------------------
// class RideMatching {
//   Future<List<Map<String, dynamic>>> findRidesWithDistances(GeoPoint userPickupLocation, GeoPoint userDropoffLocation) async {
//     List<Map<String, dynamic>> ridesWithDistances = [];
//
//     try {
//       QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('rides').get();
//       List<DocumentSnapshot> rides = snapshot.docs;
//
//       // Filter rides based on drop-off location matching the user's drop-off location
//       List<DocumentSnapshot> filteredRides = rides.where((ride) {
//         GeoPoint dropoffLocation = ride['dropoffLocation']['geopoint'];
//
//         return dropoffLocation.latitude == userDropoffLocation.latitude &&
//             dropoffLocation.longitude == userDropoffLocation.longitude;
//       }).toList();
//
//       if (filteredRides.isEmpty) {
//         final GeoFirePoint geoPoint =
//         GeoFirePoint(userDropoffLocation.latitude, userDropoffLocation.longitude);
//         String userDropoffGeohash = geoPoint.hash;
//         userDropoffGeohash = userDropoffGeohash.substring(0, 5);
//
//         filteredRides = rides.where((ride) {
//           String rideDropoffGeohash = ride['dropoffLocation']['geohash'].substring(0, 5);
//           return rideDropoffGeohash == userDropoffGeohash;
//         }).toList();
//       }
//
//       print("filtereeeeeeeeeeeeeeeeeeed ridesssssssssssgeooooo: ${filteredRides.length}");
//       // Adjust the threshold distance according to your preference
//       const double distanceThreshold = 1000; // meters
//
//       // Filter rides where the minimum distance of polyline route from the pickup location is within the threshold
//       // ---- working but no drop distance
//       // for (var ride in filteredRides) {
//       //   List<GeoPoint> polylinePoints = (ride['polylinePoints'] as List).map((point) {
//       //     return GeoPoint(point['latitude'], point['longitude']);
//       //   }).toList();
//       //
//       //   double minDistance = double.infinity;
//       //   GeoPoint nearestCoordinate = GeoPoint(0, 0);
//       //   String distanceText = 'N/A';
//       //
//       //   for (var point in polylinePoints) {
//       //     double distance = calculateDistance(
//       //       userPickupLocation.latitude,
//       //       userPickupLocation.longitude,
//       //       point.latitude,
//       //       point.longitude,
//       //     );
//       //
//       //     if (distance < minDistance) {
//       //       minDistance = distance;
//       //       nearestCoordinate = point;
//       //       distanceText = '${(minDistance / 1000).toStringAsFixed(2)} km';
//       //     }
//       //   }
//       //
//       //   if (minDistance < distanceThreshold) {
//       //     // Add ride with distances to the list
//       //     ridesWithDistances.add({
//       //       'ride': ride,
//       //       'pickupDistance': minDistance ,
//       //       'dropoffDistance': calculateDistance(
//       //         userDropoffLocation.latitude,
//       //         userDropoffLocation.longitude,
//       //         ride['dropoffLocation']['geopoint'].latitude,
//       //         ride['dropoffLocation']['geopoint'].longitude,
//       //       ),
//       //       'closestCoordinateToPickup' : nearestCoordinate,
//       //       'distanceText': distanceText,
//       //     });
//       //   }
//       // }
//
//       for (var ride in filteredRides) {
//         List<GeoPoint> polylinePoints = (ride['polylinePoints'] as List).map((point) {
//           return GeoPoint(point['latitude'], point['longitude']);
//         }).toList();
//
//         double minPickupDistance = double.infinity;
//         double minDropoffDistance = double.infinity;
//         GeoPoint nearestPickupCoordinate = GeoPoint(0, 0);
//         GeoPoint nearestDropoffCoordinate = GeoPoint(0, 0);
//         String pickupDistanceText = 'N/A';
//         String dropoffDistanceText = 'N/A';
//
//         for (var point in polylinePoints) {
//           double pickupDistance = calculateDistance(
//             userPickupLocation.latitude,
//             userPickupLocation.longitude,
//             point.latitude,
//             point.longitude,
//           );
//
//           if (pickupDistance < minPickupDistance) {
//             minPickupDistance = pickupDistance;
//             nearestPickupCoordinate = point;
//             pickupDistanceText = '${(minPickupDistance / 1000).toStringAsFixed(2)} km';
//           }
//
//           double dropoffDistance = calculateDistance(
//             userDropoffLocation.latitude,
//             userDropoffLocation.longitude,
//             point.latitude,
//             point.longitude,
//           );
//
//           if (dropoffDistance < minDropoffDistance) {
//             minDropoffDistance = dropoffDistance;
//             nearestDropoffCoordinate = point;
//             dropoffDistanceText = '${(minDropoffDistance / 1000).toStringAsFixed(2)} km';
//           }
//         }
//
//         if (minPickupDistance < distanceThreshold) {
//           // Add ride with distances to the list
//           ridesWithDistances.add({
//             'ride': ride,
//             'pickupDistance': minPickupDistance,
//             'dropoffDistance': minDropoffDistance,
//             'closestCoordinateToPickup': nearestPickupCoordinate,
//             'closestCoordinateToDropoff': nearestDropoffCoordinate,
//             'pickupDistanceText': pickupDistanceText,
//             'dropoffDistanceText': dropoffDistanceText,
//           });
//         }
//       }
//
//
//       return ridesWithDistances;
//
//       // // Calculate distances for each ride
//       // for (var ride in filteredRides) {
//       //   List<GeoPoint> polylinePoints = (ride['polylinePoints'] as List).map((point) {
//       //     return GeoPoint(point['latitude'], point['longitude']);
//       //   }).toList();
//       //
//       //   GeoPoint closestCoordinate = _findClosestCoordinate(polylinePoints, userPickupLocation);
//       //   double pickupDistance = calculateDistance(
//       //     userPickupLocation.latitude,
//       //     userPickupLocation.longitude,
//       //     closestCoordinate.latitude,
//       //     closestCoordinate.longitude,
//       //   );
//       //
//       //   // Calculate dropoff distance (assuming the dropoff point is stored in the ride document)
//       //   GeoPoint dropoffGeoPoint = ride['dropoffLocation']['geopoint'];
//       //   double dropoffDistance = calculateDistance(
//       //     userDropoffLocation.latitude,
//       //     userDropoffLocation.longitude,
//       //     dropoffGeoPoint.latitude,
//       //     dropoffGeoPoint.longitude,
//       //   );
//       //
//       //   // Add ride with distances to the list
//       //   ridesWithDistances.add({
//       //     'ride': ride,
//       //     'pickupDistance': pickupDistance,
//       //     'dropoffDistance': dropoffDistance,
//       //     'closestCoordinateToPickup' : closestCoordinate,
//       //   });
//       // }
//       //
//       // return ridesWithDistances;
//     } catch (e) {
//       print("Error fetching rides: $e");
//       return []; // Return empty list in case of error
//     }
//   }
//
//   Future<LatLng> snapToRoads(LatLng coordinate) async {
//     final String apiKey = 'YOUR_GOOGLE_MAPS_API_KEY'; // Replace with your Google Maps API key
//     final String baseUrl = 'https://roads.googleapis.com/v1/snapToRoads';
//
//     try {
//       // Construct the URL for the Snap to Roads API call
//       final String url =
//           '$baseUrl?path=${coordinate.latitude},${coordinate.longitude}&key=$apiKey';
//
//       // Send a GET request to the API
//       final response = await http.get(Uri.parse(url));
//
//       // Check if the response is successful (status code 200)
//       if (response.statusCode == 200) {
//         // Parse the response body (which contains the snapped points)
//         final Map<String, dynamic> data = json.decode(response.body);
//         final List<dynamic> snappedPoints = data['snappedPoints'];
//
//         // Check if there are snapped points returned
//         if (snappedPoints.isNotEmpty) {
//           // Extract the latitude and longitude of the first snapped point
//           final Map<String, dynamic> snappedPoint = snappedPoints[0];
//           final double latitude = snappedPoint['location']['latitude'];
//           final double longitude = snappedPoint['location']['longitude'];
//
//           // Return the snapped LatLng coordinate
//           return LatLng(latitude, longitude);
//         }
//       }
//
//       // Return the original coordinate if snapping fails or no snapped points are returned
//       return coordinate;
//     } catch (e) {
//       // Handle any errors that occur during the API call
//       print('Error occurred while snapping to roads: $e');
//       return coordinate; // Return the original coordinate in case of error
//     }
//   }
//
//   GeoPoint _findClosestCoordinate(List<GeoPoint> coordinates, GeoPoint userPickupLocation) {
//     double minDistance = double.infinity;
//     GeoPoint closestCoordinate = GeoPoint(0, 0); // Default value
//     for (var coord in coordinates) {
//       double distance = calculateDistance(
//         coord.latitude,
//         coord.longitude,
//         userPickupLocation.latitude,
//         userPickupLocation.longitude,
//       );
//       if (distance < minDistance && distance <= 1000) {
//         minDistance = distance;
//         closestCoordinate = coord;
//       }
//     }
//     return closestCoordinate;
//   }
//
//   double calculateDistance(double startLatitude, double startLongitude,
//       double endLatitude, double endLongitude) {
//     const int earthRadius = 6371000; // in meters
//     double lat1Rad = radians(startLatitude);
//     double lon1Rad = radians(startLongitude);
//     double lat2Rad = radians(endLatitude);
//     double lon2Rad = radians(endLongitude);
//
//     double deltaLat = lat2Rad - lat1Rad;
//     double deltaLon = lon2Rad - lon1Rad;
//
//     double a = math.pow(math.sin(deltaLat / 2), 2) +
//         math.cos(lat1Rad) *
//             math.cos(lat2Rad) *
//             math.pow(math.sin(deltaLon / 2), 2);
//     double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
//
//     return earthRadius * c;
//   }
//
//   double radians(double degrees) {
//     return degrees * (math.pi / 180);
//   }
// }

// ---------------------------------------------------------------------------------------

//
// class RideMatching {
//
//   num? distanceThreshold;
//
//   RideMatching(this.distanceThreshold);
//
//   Future<List<DocumentSnapshot>> findRides(GeoPoint userPickupLocation, GeoPoint userDropoffLocation) async {
//
//     List<DocumentSnapshot> rides = [];
//
//     try{
//       QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('rides').get();
//       rides = snapshot.docs;
//
//       print("snapsotttttt rides: $rides");
//       print("Functiooooon calleddddddddddddddd");
//       print("user ploc lat: ${userPickupLocation.latitude}");
//
//       // Filter rides based on drop-off location matching the user's drop-off location
//       List<DocumentSnapshot> filteredRides = rides.where((ride) {
//         GeoPoint dropoffLocation = ride['dropoffLocation']['geopoint'];
//
//         return dropoffLocation.latitude == userDropoffLocation.latitude &&
//             dropoffLocation.longitude == userDropoffLocation.longitude;
//       }).toList();
//
//       print("filtered rides: $rides");
//
//       if (filteredRides.isEmpty) {
//         final GeoFirePoint geoPoint =
//         GeoFirePoint(userDropoffLocation.latitude, userDropoffLocation.longitude);
//         String userDropoffGeohash = geoPoint.hash;
//         userDropoffGeohash = userDropoffGeohash.substring(0, 6);
//
//         print("useeeeeer dropoffff GEOOOHASH $userDropoffGeohash");
//
//         filteredRides = rides.where((ride) {
//           print("geohash method calleddd");
//           String rideDropoffGeohash = ride['dropoffLocation']['geohash'].substring(0, 6);
//           print("RIDEEEEEE dropoffff GEOOOHASH $rideDropoffGeohash");
//           return rideDropoffGeohash == userDropoffGeohash;
//         }).toList();
//       }
//
//       GeoPoint? nearestCoordinate;
//
//       String distanceText = 'N/A';
//
//       List<DocumentSnapshot> closestRides = [];
//       for (var ride in filteredRides) {
//         List<GeoPoint> polylinePoints = (ride['polylinePoints'] as List).map((point) {
//           return GeoPoint(point['latitude'], point['longitude']);
//         }).toList();
//
//         double minDistance = double.infinity;
//         for (var point in polylinePoints) {
//           double distance = calculateDistance(userPickupLocation.latitude, userPickupLocation.longitude, point.latitude, point.longitude,);
//           if (distance < minDistance) {
//             minDistance = distance;
//             nearestCoordinate = point;
//             // distanceText = nearestCoordinate != null
//             //     ? '${(minDistance / 1000).toStringAsFixed(2)} km'
//             //     : 'N/A';
//           }
//         }
//
//         if (minDistance < (distanceThreshold ?? 1000)) {
//           closestRides.add(ride);
//         }
//       }
//
//       filteredRides = closestRides;
//       return filteredRides;
//
//
//     } catch (e){
//       print("Error fetching rides: $e");
//       return []; // Return empty list in case of error
//
//     }
//
//
//
//   }
//
//
//   double calculateDistance(double startLatitude, double startLongitude,
//       double endLatitude, double endLongitude) {
//     const int earthRadius = 6371000; // in meters
//     double lat1Rad = radians(startLatitude);
//     double lon1Rad = radians(startLongitude);
//     double lat2Rad = radians(endLatitude);
//     double lon2Rad = radians(endLongitude);
//
//     double deltaLat = lat2Rad - lat1Rad;
//     double deltaLon = lon2Rad - lon1Rad;
//
//     double a = math.pow(math.sin(deltaLat / 2), 2) +
//         math.cos(lat1Rad) *
//             math.cos(lat2Rad) *
//             math.pow(math.sin(deltaLon / 2), 2);
//     double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
//
//     return earthRadius * c;
//   }
//
//   double radians(double degrees) {
//     return degrees * (math.pi / 180);
//   }
// }

// Future<List<Map<String, dynamic>>> fetchRidesWithDistances(List<dynamic> filteredRides, LatLng userPickupLocation, LatLng userDropoffLocation, double distanceThreshold) async {
//   try {
//     List<Map<String, dynamic>> ridesWithDistances = [];
//
//     for (var ride in filteredRides) {
//       List<LatLng> polylineCoordinates = (ride['polylinePoints'] as List).map((point) {
//         return LatLng(point['latitude'], point['longitude']);
//       }).toList();
//
//       // Call the snapToRoads function to obtain snapped coordinates for pickup location
//       List<LatLng> snappedPickupCoordinates = await snapToRoads(userPickupLocation);
//
//       // Call the snapToRoads function to obtain snapped coordinates for dropoff location
//       List<LatLng> snappedDropoffCoordinates = await snapToRoads(userDropoffLocation);
//
//       // Iterate through each snapped pickup coordinate to obtain the snapped point
//       List<LatLng> finalSnappedPickupCoordinates = [];
//       for (LatLng snappedCoordinate in snappedPickupCoordinates) {
//         List<LatLng> snappedPoint = await snapToRoads(snappedCoordinate);
//         finalSnappedPickupCoordinates.addAll(snappedPoint);
//       }
//
//       // Iterate through each snapped dropoff coordinate to obtain the snapped point
//       List<LatLng> finalSnappedDropoffCoordinates = [];
//       for (LatLng snappedCoordinate in snappedDropoffCoordinates) {
//         List<LatLng> snappedPoint = await snapToRoads(snappedCoordinate);
//         finalSnappedDropoffCoordinates.addAll(snappedPoint);
//       }
//
//       // Calculate distance from each snapped coordinate to polyline coordinates for pickup
//       double minPickupDistance = double.infinity;
//       LatLng closestSnappedPickupCoordinate = LatLng(0, 0);
//
//       for (LatLng snappedCoordinate in finalSnappedPickupCoordinates) {
//         for (LatLng polylineCoordinate in polylineCoordinates) {
//           double distance = calculateDistance(
//             snappedCoordinate.latitude,
//             snappedCoordinate.longitude,
//             polylineCoordinate.latitude,
//             polylineCoordinate.longitude,
//           );
//
//           // Update minimum pickup distance and closest snapped pickup coordinate if needed
//           if (distance < minPickupDistance) {
//             minPickupDistance = distance;
//             closestSnappedPickupCoordinate = snappedCoordinate;
//           }
//         }
//       }
//
//       // Calculate distance from each snapped coordinate to polyline coordinates for dropoff
//       double minDropoffDistance = double.infinity;
//       LatLng closestSnappedDropoffCoordinate = LatLng(0, 0);
//
//       for (LatLng snappedCoordinate in finalSnappedDropoffCoordinates) {
//         for (LatLng polylineCoordinate in polylineCoordinates) {
//           double distance = calculateDistance(
//             snappedCoordinate.latitude,
//             snappedCoordinate.longitude,
//             polylineCoordinate.latitude,
//             polylineCoordinate.longitude,
//           );
//
//           // Update minimum dropoff distance and closest snapped dropoff coordinate if needed
//           if (distance < minDropoffDistance) {
//             minDropoffDistance = distance;
//             closestSnappedDropoffCoordinate = snappedCoordinate;
//           }
//         }
//       }
//
//       // Calculate distance texts for pickup and dropoff distances
//       String pickupDistanceText = '${(minPickupDistance / 1000).toStringAsFixed(2)} km';
//       String dropoffDistanceText = '${(minDropoffDistance / 1000).toStringAsFixed(2)} km';
//
//       // If the minimum distances are within the threshold, add ride with distances to the list
//       if (minPickupDistance < distanceThreshold && minDropoffDistance < distanceThreshold) {
//         ridesWithDistances.add({
//           'ride': ride,
//           'pickupDistance': minPickupDistance,
//           'dropoffDistance': minDropoffDistance,
//           'pickupDistanceText': pickupDistanceText,
//           'dropoffDistanceText': dropoffDistanceText,
//           'closestSnappedPickupCoordinate': closestSnappedPickupCoordinate,
//           'closestSnappedDropoffCoordinate': closestSnappedDropoffCoordinate,
//         });
//       }
//     }
//
//     return ridesWithDistances;
//   } catch (e) {
//     print("Error fetching rides: $e");
//     return []; // Return empty list in case of error
//   }
// }

// Future<List<Map<String, dynamic>>> findRidesWithDistances(
//     LatLng userPickupLocation, LatLng userDropoffLocation) async {
//   List<Map<String, dynamic>> ridesWithDistances = [];
//
//   try {
//     QuerySnapshot snapshot = await FirebaseFirestore.instance
//         .collection('rides')
//         .get();
//     List<DocumentSnapshot> rides = snapshot.docs;
//
//     // Filter rides based on drop-off location matching the user's drop-off location
//     List<DocumentSnapshot> filteredRides = rides.where((ride) {
//       GeoPoint dropoffLocation = ride['dropoffLocation']['geopoint'];
//
//       return dropoffLocation.latitude == userDropoffLocation.latitude &&
//           dropoffLocation.longitude == userDropoffLocation.longitude;
//     }).toList();
//
//     if (filteredRides.isEmpty) {
//       final GeoFirePoint geoPoint =
//       GeoFirePoint(userDropoffLocation.latitude, userDropoffLocation.longitude);
//       String userDropoffGeohash = geoPoint.hash;
//       userDropoffGeohash = userDropoffGeohash.substring(0, 5);
//
//       filteredRides = rides.where((ride) {
//         String rideDropoffGeohash =
//         ride['dropoffLocation']['geohash'].substring(0, 5);
//         return rideDropoffGeohash == userDropoffGeohash;
//       }).toList();
//     }
//
//     // Adjust the threshold distance according to your preference
//     const double distanceThreshold = 1000; // meters
//
//     // Call fetchRidesWithDistances function to get rides with distances
//     // ridesWithDistances = await fetchRidesWithDistances(
//     //     filteredRides, userPickupLocation, userDropoffLocation, distanceThreshold);
//
//     for (var ride in filteredRides) {
//       List<LatLng> polylineCoordinates = (ride['polylinePoints'] as List).map((point) {
//         return LatLng(point['latitude'], point['longitude']);
//       }).toList();
//
//       // Call the snapToRoads function to obtain snapped coordinates for pickup location
//       List<LatLng> snappedPickupCoordinates = await snapToRoads(userPickupLocation);
//
//       // Call the snapToRoads function to obtain snapped coordinates for dropoff location
//       List<LatLng> snappedDropoffCoordinates = await snapToRoads(userDropoffLocation);
//
//       // Calculate distance from each snapped coordinate to polyline coordinates for pickup
//       double minPickupDistance = double.infinity;
//       // Initialize variables for closest snapped coordinates
//       LatLng closestSnappedPickupCoordinate = LatLng(0, 0);
//       LatLng closestSnappedDropoffCoordinate = LatLng(0, 0);
//
//       for (LatLng snappedCoordinate in snappedPickupCoordinates) {
//         for (LatLng polylineCoordinate in polylineCoordinates) {
//           double distance = calculateDistance(
//             snappedCoordinate.latitude,
//             snappedCoordinate.longitude,
//             polylineCoordinate.latitude,
//             polylineCoordinate.longitude,
//           );
//
//           // Update minimum pickup distance and closest snapped pickup coordinate if needed
//           if (distance < minPickupDistance) {
//             minPickupDistance = distance;
//             closestSnappedPickupCoordinate = snappedCoordinate;
//           }
//         }
//       }
//
//       // Calculate distance from each snapped coordinate to polyline coordinates for dropoff
//       double minDropoffDistance = double.infinity;
//       // LatLng closestSnappedDropoffCoordinate;
//
//       for (LatLng snappedCoordinate in snappedDropoffCoordinates) {
//         for (LatLng polylineCoordinate in polylineCoordinates) {
//           double distance = calculateDistance(
//             snappedCoordinate.latitude,
//             snappedCoordinate.longitude,
//             polylineCoordinate.latitude,
//             polylineCoordinate.longitude,
//           );
//
//           // Update minimum dropoff distance and closest snapped dropoff coordinate if needed
//           if (distance < minDropoffDistance) {
//             minDropoffDistance = distance;
//             closestSnappedDropoffCoordinate = snappedCoordinate;
//           }
//         }
//       }
//
//       // Calculate distance texts for pickup and dropoff distances
//       String pickupDistanceText = '${(minPickupDistance / 1000).toStringAsFixed(2)} km';
//       String dropoffDistanceText = '${(minDropoffDistance / 1000).toStringAsFixed(2)} km';
//
//       // If the minimum distances are within the threshold, add ride with distances to the list
//       if (minPickupDistance < distanceThreshold && minDropoffDistance < distanceThreshold) {
//         ridesWithDistances.add({
//           'ride': ride,
//           'pickupDistance': minPickupDistance,
//           'dropoffDistance': minDropoffDistance,
//           'pickupDistanceText': pickupDistanceText,
//           'dropoffDistanceText': dropoffDistanceText,
//           'closestSnappedPickupCoordinate': closestSnappedPickupCoordinate,
//           'closestSnappedDropoffCoordinate': closestSnappedDropoffCoordinate,
//         });
//       }
//     }
//
//     return ridesWithDistances;
//
//   } catch (e) {
//     print("Error fetching rides: $e");
//     return []; // Return empty list in case of error
//   }
// }
