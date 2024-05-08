// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';
//
// import 'package:url_launcher/url_launcher.dart';
//
// class MapGPX extends StatelessWidget {
//   const MapGPX({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Navigate with Google Maps'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () async {
//             // Step 1: Retrieve polyline points from Firestore
//             List<dynamic> polylinePoints = await getPolylinePointsFromFirestore("A1IxPYLCBhR9JUqPbFhD");
//             List<List<double>> decodedPolyline = decodePolylinePoints(polylinePoints);
//
//             // Step 2: Retrieve stop points from Firestore
//             List<Map<String, List<double>>> stopPoints = await getStopPointsFromFirestore("A1IxPYLCBhR9JUqPbFhD");
//
//             // Proceed with generating GPX content and launching Google Maps app
//             String gpxContent = generateGPXContent(decodedPolyline);
//
//             // Launch Google Maps app with polyline and stop points
//             // launchGoogleMapsApp(decodedPolyline, stopPoints);
//
//             // Proceed with generating encoded polyline and launching Google Maps app
//             String encodedPolyline = encodePolylinePoints(decodedPolyline);
//
//             // launchGoogleMapsAppWithGPXUpdated(gpxContent);
//             launchGoogleMapsAppWithEncodedPolyline(encodedPolyline, stopPoints);
//             // launchGoogleMapsAppWithEncodedPolylineUpdated(encodedPolyline);
//
//             // Save GPX content to a file
//             // await saveGPXToFile(gpxContent);
//
//           },
//           child: Text('Navigate'),
//         ),
//       ),
//     );
//   }
//
//   void launchGoogleMapsAppWithGPXUpdated(String gpxContent) {
//     // Encode GPX content for Google Maps URL
//     String encodedGPX = Uri.encodeComponent(gpxContent);
//
//     // Launch Google Maps with GPX content
//     String googleMapsUrl = "https://www.google.com/maps/dir/?api=1&travelmode=driving&dir_action=navigate&gpx=$encodedGPX";
//     print(googleMapsUrl);
//     print("Launching Google Maps with GPX content");
//     launch(googleMapsUrl);
//   }
//
//   // Step 1: Decode Polyline Points
//   List<List<double>> decodePolylinePoints(List<dynamic> polylinePoints) {
//     List<List<double>> coordinates = [];
//     for (var point in polylinePoints) {
//       double latitude = point['latitude'];
//       double longitude = point['longitude'];
//       coordinates.add([latitude, longitude]);
//     }
//     return coordinates;
//   }
//
//   // Encode Polyline Points
//   String encodePolylinePoints(List<List<double>> polylinePoints) {
//     List<String> encodedPoints = [];
//     for (var point in polylinePoints) {
//       encodedPoints.add(_encode(point[0]) + "," + _encode(point[1]));
//     }
//     return encodedPoints.join('|');
//   }
//
//   String _encode(double value) {
//     // This is a simplified version of polyline encoding
//     return ((value * 1e5).round()).toString();
//   }
//
//   // Launch Google Maps App with encoded polyline only
//   void launchGoogleMapsAppWithEncodedPolylineUpdated(String encodedPolyline) {
//     // Launch Google Maps with encoded polyline
//     String googleMapsUrl = "https://www.google.com/maps/dir/?api=1&travelmode=driving&dir_action=navigate&polyline=$encodedPolyline";
//     print("Launching Google Maps with URL: $googleMapsUrl");
//     launch(googleMapsUrl);
//   }
//
//   // Launch Google Maps App with encoded polyline and stop points
//   void launchGoogleMapsAppWithEncodedPolyline(String encodedPolyline, List<Map<String, List<double>>> stopPoints) {
//     // Generate waypoints for stop points
//     List<String> waypoints = [];
//     for (var stopPoint in stopPoints) {
//       if (stopPoint.containsKey('pickupCoordinate')) {
//         List<double> pickupCoord = stopPoint['pickupCoordinate']!;
//         waypoints.add('${pickupCoord[0]},${pickupCoord[1]}');
//       }
//       if (stopPoint.containsKey('dropoffCoordinate')) {
//         List<double> dropoffCoord = stopPoint['dropoffCoordinate']!;
//         waypoints.add('${dropoffCoord[0]},${dropoffCoord[1]}');
//       }
//     }
//
//     // Join waypoints into a single string
//     String encodedWaypoints = waypoints.join('|');
//
//     // Launch Google Maps with encoded polyline and waypoints
//     // String googleMapsUrl = "https://www.google.com/maps/dir/?api=1&travelmode=driving&dir_action=navigate&polyline=$encodedPolyline&waypoints=$encodedWaypoints";
//     String googleMapsUrl = "https://www.google.com/maps/dir/?api=1&travelmode=driving&dir_action=navigate&waypoints=$encodedWaypoints";
//     print("Launching Google Maps with URL: $googleMapsUrl");
//     launch(googleMapsUrl);
//   }
//
//   // Step 2: Generate GPX Content with Polyline Points
//   String generateGPXContent(List<List<double>> polylinePoints) {
//     String gpxContent = '<?xml version="1.0" encoding="UTF-8"?>\n'
//         '<gpx version="1.1" creator="YourAppName">\n'
//         '<trk>\n'
//         '<name>Your Route</name>\n'
//         '<trkseg>\n';
//
//     for (var point in polylinePoints) {
//       gpxContent += '<trkpt lat="${point[0]}" lon="${point[1]}"></trkpt>\n';
//     }
//
//     gpxContent += '</trkseg>\n</trk>\n</gpx>';
//
//     return gpxContent;
//   }
//
//   // Step 3: Launch Google Maps App with Polyline and Stop Points
//   void launchGoogleMapsApp(List<List<double>> polylinePoints, List<Map<String, List<double>>> stopPoints) {
//     // Encode polyline points for Google Maps URL
//     String encodedPolyline = Uri.encodeComponent(polylinePoints.toString());
//
//     // Generate waypoints for Google Maps URL
//     List<String> waypoints = [];
//
//     for (var stopPoint in stopPoints) {
//       if (stopPoint.containsKey('pickupCoordinate')) {
//         List<double> pickupCoord = stopPoint['pickupCoordinate']!;
//         waypoints.add('${pickupCoord[0]},${pickupCoord[1]}');
//       }
//       if (stopPoint.containsKey('dropoffCoordinate')) {
//         List<double> dropoffCoord = stopPoint['dropoffCoordinate']!;
//         waypoints.add('${dropoffCoord[0]},${dropoffCoord[1]}');
//       }
//     }
//
//     // Join waypoints into a single string
//     String encodedWaypoints = waypoints.join('|');
//
//     // Launch Google Maps with encoded polyline and waypoints
//     String googleMapsUrl = "https://www.google.com/maps/dir/?api=1&travelmode=driving&dir_action=navigate&destination=enc:$encodedPolyline&waypoints=$encodedWaypoints";
//     print("Launching Google Maps with URL: $googleMapsUrl");
//     // launch(googleMapsUrl);
//   }
//
//   // Step 4: Save GPX Content to a File
//   Future<void> saveGPXToFile(String gpxContent) async {
//     try {
//       // Get the local app directory
//       Directory appDir = await getApplicationDocumentsDirectory();
//       String appDirPath = appDir.path;
//
//       print("APPP DIR PATH: $appDirPath");
//
//       // Define the file path for saving the GPX content
//       String filePath = '$appDirPath/your_route.gpx';
//
//       // Write the GPX content to a file
//       File file = File(filePath);
//       await file.writeAsString(gpxContent);
//
//       print('GPX file saved to: $filePath');
//     } catch (e) {
//       print('Error saving GPX file: $e');
//     }
//   }
//
//   // Step 5: Retrieve Polyline Points from Firestore
//   Future<List<dynamic>> getPolylinePointsFromFirestore(String rideId) async {
//     try {
//       CollectionReference rides = FirebaseFirestore.instance.collection('rides');
//
//       // Query Firestore for the specific ride ID
//       DocumentSnapshot querySnapshot = await rides.doc(rideId).get();
//
//       // Check if the ride document exists
//       if (!querySnapshot.exists) {
//         throw Exception("Ride with ID $rideId not found");
//       }
//
//       // Extract polylinePoints from the ride document
//       dynamic data = querySnapshot.data();
//       if (data != null && data['polylinePoints'] != null) {
//         List<dynamic> polylinePoints = data['polylinePoints'];
//         return polylinePoints;
//       } else {
//         throw Exception("Polyline points not found for ride with ID $rideId");
//       }
//     } catch (e) {
//       print("Error getting polyline points for ride: $e");
//       return []; // Return an empty list in case of error
//     }
//   }
//
//   // Step 6: Retrieve Stop Points from Firestore
//   Future<List<Map<String, List<double>>>> getStopPointsFromFirestore(String rideId) async {
//     CollectionReference rides = FirebaseFirestore.instance.collection('rides');
//     DocumentSnapshot rideSnapshot = await rides.doc(rideId).get();
//     List<Map<String, List<double>>> stopPoints = [];
//
//     if (rideSnapshot.exists) {
//       print('Ride data found for ride ID: $rideId');
//
//       // Adding null check for passengers field
//       dynamic data = rideSnapshot.data();
//       if (data != null && data['passengers'] != null) {
//         List<dynamic> passengers = data['passengers'];
//         passengers.forEach((passenger) {
//           // Extracting GeoPoint objects
//           GeoPoint pickupGeoPoint = passenger['pickupCoordinate'];
//           GeoPoint dropoffGeoPoint = passenger['dropoffCoordinate'];
//
//           // Converting GeoPoint objects to List<double>
//           List<double> pickupCoords = [
//             pickupGeoPoint.latitude ?? 0.0,
//             pickupGeoPoint.longitude ?? 0.0,
//           ];
//
//           List<double> dropoffCoords = [
//             dropoffGeoPoint.latitude ?? 0.0,
//             dropoffGeoPoint.longitude ?? 0.0,
//           ];
//
//           // Constructing stop point map
//           Map<String, List<double>> stopPoint = {
//             'pickupCoordinate': pickupCoords,
//             'dropoffCoordinate': dropoffCoords,
//           };
//
//           stopPoints.add(stopPoint);
//         });
//       }
//     } else {
//       print('No ride data found for ride ID: $rideId');
//     }
//
//     return stopPoints;
//   }
// }
//
//
//
//
//
//
//
//
//
//
//
// // import 'dart:io';
// //
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:path_provider/path_provider.dart';
// // import 'package:url_launcher/url_launcher.dart';
// //
// //
// //
// // class MapGPX extends StatelessWidget {
// //   const MapGPX({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Navigate with Google Maps'),
// //       ),
// //       body: Center(
// //         child: ElevatedButton(
// //           onPressed: () async {
// //             // Step ! & 2: Retrieve polyline points from Firestore
// //             List<dynamic> polylinePoints = await getPolylinePointsFromFirestore("A1IxPYLCBhR9JUqPbFhD");
// //             List<List<double>> decodedPolyline = decodePolylinePoints(polylinePoints);
// //
// //             // Step 3: Retrieve stop points from Firestore
// //             List<Map<String, List<double>>> stopPoints = await getStopPointsFromFirestore("A1IxPYLCBhR9JUqPbFhD");
// //
// //             // Proceed with generating GPX content and launching Google Maps app
// //             String gpxContent = generateGPXContent(decodedPolyline, stopPoints);
// //
// //             print("GPXXXX COntent : $gpxContent");
// //             // launchGoogleMapsAppWithGPX(gpxContent);
// //
// //             launchGoogleMapsAppWithGPX(stopPoints);
// //
// //             // Save GPX content to a file
// //             await saveGPXToFile(gpxContent);
// //
// //           },
// //           child: Text('Navigate'),
// //         ),
// //       ),
// //     );
// //   }
// //
// //
// //   // Step 2: Decode Polyline Points
// //   List<List<double>> decodePolylinePoints(List<dynamic> polylinePoints) {
// //     List<List<double>> coordinates = [];
// //     for (var point in polylinePoints) {
// //       double latitude = point['latitude'];
// //       double longitude = point['longitude'];
// //       coordinates.add([latitude, longitude]);
// //     }
// //     return coordinates;
// //   }
// //
// //   // Step 3: Generate GPX Content
// //   String generateGPXContent(List<List<double>> polylinePoints, List<Map<String, List<double>>> stopPoints) {
// //     String gpxContent = '<?xml version="1.0" encoding="UTF-8"?>\n'
// //         '<gpx version="1.1" creator="YourAppName">\n'
// //         '<trk>\n'
// //         '<name>Your Route</name>\n'
// //         '<trkseg>\n';
// //
// //     for (var point in polylinePoints) {
// //       gpxContent += '<trkpt lat="${point[0]}" lon="${point[1]}"></trkpt>\n';
// //     }
// //
// //     for (var stopPoint in stopPoints) {
// //       if (stopPoint.containsKey('pickupCoordinate')) {
// //         List<double> pickupCoord = stopPoint['pickupCoordinate']!;
// //         gpxContent +=
// //         '<trkpt lat="${pickupCoord[0]}" lon="${pickupCoord[1]}"><name>Pickup</name></trkpt>\n';
// //       }
// //       if (stopPoint.containsKey('dropoffCoordinate')) {
// //         List<double> dropoffCoord = stopPoint['dropoffCoordinate']!;
// //         gpxContent +=
// //         '<trkpt lat="${dropoffCoord[0]}" lon="${dropoffCoord[1]}"><name>Dropoff</name></trkpt>\n';
// //       }
// //     }
// //
// //     gpxContent += '</trkseg>\n</trk>\n</gpx>';
// //
// //     return gpxContent;
// //   }
// //
// // // Step 4: Launch Google Maps App with GPX Data
// // //   void launchGoogleMapsAppWithGPX(String gpxContent) {
// // //     String gpxDataUri = Uri.encodeFull(gpxContent);
// // //     String googleMapsUrl = "https://www.google.com/maps/dir/?api=1&travelmode=driving&dir_action=navigate&destination=gpxdata=$gpxDataUri";
// // //     print("THIS IS THE URL: $googleMapsUrl");
// // //
// // //     // Launch the URL
// // //     // launch(googleMapsUrl);
// // //   }
// //
// //
// //   // Function to save GPX content to a file
// //   Future<void> saveGPXToFile(String gpxContent) async {
// //     try {
// //       // Get the local app directory
// //       Directory appDir = await getApplicationDocumentsDirectory();
// //       String appDirPath = appDir.path;
// //
// //
// //       print("APPP DIR PATH: $appDirPath");
// //
// //       // Define the file path for saving the GPX content
// //       String filePath = '$appDirPath/your_route.gpx';
// //
// //       // Write the GPX content to a file
// //       File file = File(filePath);
// //       await file.writeAsString(gpxContent);
// //
// //       print('GPX file saved to: $filePath');
// //     } catch (e) {
// //       print('Error saving GPX file: $e');
// //     }
// //   }
// //
// //
// //   void launchGoogleMapsAppWithGPX(List<Map<String, List<double>>> stopPoints) {
// //     String waypoints = '';
// //
// //     for (var stopPoint in stopPoints) {
// //       if (stopPoint.containsKey('pickupCoordinate')) {
// //         List<double> pickupCoord = stopPoint['pickupCoordinate']!;
// //         waypoints += '${pickupCoord[0]},${pickupCoord[1]}|';
// //       }
// //       if (stopPoint.containsKey('dropoffCoordinate')) {
// //         List<double> dropoffCoord = stopPoint['dropoffCoordinate']!;
// //         waypoints += '${dropoffCoord[0]},${dropoffCoord[1]}|';
// //       }
// //     }
// //
// //     // Remove the trailing '|' from waypoints
// //     waypoints = waypoints.substring(0, waypoints.length - 1);
// //
// //     String googleMapsUrl = "https://www.google.com/maps/dir/?api=1&travelmode=driving&waypoints=$waypoints";
// //     print("THIS IS THE URL: $googleMapsUrl");
// //
// //     // Launch the URL
// //     launch(googleMapsUrl);
// //   }
// //
// //
// //   Future<List<dynamic>> getPolylinePointsFromFirestore(String rideId) async {
// //     try {
// //       CollectionReference rides = FirebaseFirestore.instance.collection('rides');
// //
// //       // Query Firestore for the specific ride ID
// //       DocumentSnapshot querySnapshot = await rides.doc(rideId).get();
// //
// //       // Check if the ride document exists
// //       if (!querySnapshot.exists) {
// //         throw Exception("Ride with ID $rideId not found");
// //       }
// //
// //       // Extract polylinePoints from the ride document
// //       dynamic data = querySnapshot.data();
// //       if (data != null && data['polylinePoints'] != null) {
// //         List<dynamic> polylinePoints = data['polylinePoints'];
// //         return polylinePoints;
// //       } else {
// //         throw Exception("Polyline points not found for ride with ID $rideId");
// //       }
// //     } catch (e) {
// //       print("Error getting polyline points for ride: $e");
// //       return []; // Return an empty list in case of error
// //     }
// //   }
// //
// //
// //   Future<List<Map<String, List<double>>>> getStopPointsFromFirestore(String rideId) async {
// //     CollectionReference rides = FirebaseFirestore.instance.collection('rides');
// //     DocumentSnapshot rideSnapshot = await rides.doc(rideId).get();
// //     List<Map<String, List<double>>> stopPoints = [];
// //
// //     if (rideSnapshot.exists) {
// //       print('Ride data found for ride ID: $rideId');
// //
// //       // Adding null check for passengers field
// //       dynamic data = rideSnapshot.data();
// //       if (data != null && data['passengers'] != null) {
// //         List<dynamic> passengers = data['passengers'];
// //         passengers.forEach((passenger) {
// //           // Extracting GeoPoint objects
// //           GeoPoint pickupGeoPoint = passenger['pickupCoordinate'];
// //           GeoPoint dropoffGeoPoint = passenger['dropoffCoordinate'];
// //
// //           // Converting GeoPoint objects to List<double>
// //           List<double> pickupCoords = [
// //             pickupGeoPoint.latitude ?? 0.0,
// //             pickupGeoPoint.longitude ?? 0.0,
// //           ];
// //
// //           List<double> dropoffCoords = [
// //             dropoffGeoPoint.latitude ?? 0.0,
// //             dropoffGeoPoint.longitude ?? 0.0,
// //           ];
// //
// //           // Constructing stop point map
// //           Map<String, List<double>> stopPoint = {
// //             'pickupCoordinate': pickupCoords,
// //             'dropoffCoordinate': dropoffCoords,
// //           };
// //
// //           stopPoints.add(stopPoint);
// //         });
// //       }
// //     } else {
// //       print('No ride data found for ride ID: $rideId');
// //     }
// //
// //     return stopPoints;
// //   }
// //
// //
// //
// //
// // }
