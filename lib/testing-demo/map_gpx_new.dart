import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lyft_mate/testing-demo/gpx_map_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, dynamic>> fetchRideDetails(String rideId) async {
  var document = await FirebaseFirestore.instance.collection('rides').doc(rideId).get();
  if (document.exists) {
    return document.data()!;
  }
  return {};
}

class MapGPX extends StatelessWidget {
  const MapGPX({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Navigate with Google Maps'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {

            String? fcmToken = await FirebaseMessaging.instance.getToken();
            debugPrint('FCM TTTTTTTTTTTTTToken: $fcmToken'); // Print FCM token in the console

            Map<String, dynamic> rideDetails = await fetchRideDetails("A1IxPYLCBhR9JUqPbFhD");
            if (rideDetails.isNotEmpty) {
              List<dynamic> polylinePoints = rideDetails['polylinePoints'];
              List<LatLng> points = polylinePoints.map((point) => LatLng(point['latitude'], point['longitude'])).toList();
              String encodedPolyline = encodePolyline(points);

              // Extract passenger details with unique identifiers
              List<Map<String, dynamic>> passengers = List<Map<String, dynamic>>.from(rideDetails['passengers']);
              Map<String, LatLng> passengerStartLocations = {};
              Map<String, LatLng> passengerDropLocations = {};

              passengers.forEach((passenger) {
                String passengerId = passenger['userId']; // Unique identifier for each passenger
                LatLng startLocation = LatLng(passenger['pickupCoordinate'].latitude, passenger['pickupCoordinate'].longitude);
                LatLng dropLocation = LatLng(passenger['dropoffCoordinate'].latitude, passenger['dropoffCoordinate'].longitude);

                passengerStartLocations[passengerId] = startLocation;
                passengerDropLocations[passengerId] = dropLocation;
              });

              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => GPXMapScreen(
              //       rideId: "A1IxPYLCBhR9JUqPbFhD",
              //       origin: points.first,
              //       destination: points.last,
              //       encodedPolyline: encodedPolyline,
              //       passengerStartLocations: passengerStartLocations,
              //       passengerDropLocations: passengerDropLocations,
              //     ),
              //   ),
              // );
            } else {
              // Handle error or notify user
              print("No ride details found");
            }
          },
          child: Text('Navigate in App'),
        ),
      ),
    );
  }

  String encodePolyline(List<LatLng> points) {
    int lastLat = 0;
    int lastLng = 0;
    String result = '';

    for (final point in points) {
      int lat = (point.latitude * 1e5).round();
      int lng = (point.longitude * 1e5).round();

      int dLat = lat - lastLat;
      int dLng = lng - lastLng;

      [dLat, dLng].forEach((value) {
        int shifted = value << 1;
        if (value < 0) shifted = ~shifted;
        int rem = shifted;
        while (rem >= 0x20) {
          result += String.fromCharCode((0x20 | (rem & 0x1f)) + 63);
          rem >>= 5;
        }
        result += String.fromCharCode(rem + 63);
      });

      lastLat = lat;
      lastLng = lng;
    }

    return result;
  }


}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:lyft_mate/testing-demo/gpx_map_screen.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class MapGPX extends StatelessWidget {
//   const MapGPX({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Navigate with Google Maps'),
//       ),
//       body: Center(
//         child:
//         // ElevatedButton(
//         //   onPressed: () async {
//         //     // vPQXlpF4GTJzVbRAzFub
//         //     List<LatLng> points = await fetchPolylineCoordinates("2JF53KdlNHZ8PVETwWNJ");
//         //     if (points.isNotEmpty) {
//         //       String encodedPolyline = encodePolyline(points);
//         //       launchGoogleMapsApp(points.first, points.last, encodedPolyline);
//         //     } else {
//         //       // Handle the error or notify user
//         //       print("No points found for polyline");
//         //     }
//         //   },
//         //   child: Text('Navigate'),
//         // ),
//         ElevatedButton(
//           onPressed: () async {
//             List<LatLng> points = await fetchPolylineCoordinates("4jp6wvK74f5WDM13JGJi");
//
//
//             if (points.isNotEmpty) {
//               String encodedPolyline = encodePolyline(points);
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => GPXMapScreen(
//                     origin: points.first,
//                     destination: points.last,
//                     encodedPolyline: encodedPolyline,
//                   ),
//                 ),
//               );
//             } else {
//               // Handle error or notify user
//               print("No points found for polyline");
//             }
//           },
//           child: Text('Navigate in App'),
//         )
//       ),
//     );
//   }
//
//   Future<List<LatLng>> fetchPolylineCoordinates(String rideId) async {
//     var document = await FirebaseFirestore.instance.collection('rides').doc(rideId).get();
//     List<LatLng> points = [];
//     if (document.exists) {
//       var data = document.data()!;
//       List<dynamic> polylinePoints = data['polylinePoints'];
//       points.addAll(polylinePoints.map((point) => LatLng(point['latitude'], point['longitude'])));
//     }
//     return points;
//   }
//
//   String encodePolyline(List<LatLng> points) {
//     int lastLat = 0;
//     int lastLng = 0;
//     String result = '';
//
//     for (final point in points) {
//       int lat = (point.latitude * 1e5).round();
//       int lng = (point.longitude * 1e5).round();
//
//       int dLat = lat - lastLat;
//       int dLng = lng - lastLng;
//
//       [dLat, dLng].forEach((value) {
//         int shifted = value << 1;
//         if (value < 0) shifted = ~shifted;
//         int rem = shifted;
//         while (rem >= 0x20) {
//           result += String.fromCharCode((0x20 | (rem & 0x1f)) + 63);
//           rem >>= 5;
//         }
//         result += String.fromCharCode(rem + 63);
//       });
//
//       lastLat = lat;
//       lastLng = lng;
//     }
//
//     return result;
//   }
//
//   Future<void> launchGoogleMapsApp(LatLng origin, LatLng destination, String encodedPolyline) async {
//     String originParam = "${origin.latitude},${origin.longitude}";
//     String destinationParam = "${destination.latitude},${destination.longitude}";
//     String googleUrl = 'https://www.google.com/maps/dir/?api=1&travelmode=driving&origin=$originParam&destination=$destinationParam&path=enc:$encodedPolyline';
//     if (await canLaunchUrl(Uri.parse(googleUrl))) {
//       await launchUrl(Uri.parse(googleUrl));
//     } else {
//       throw 'Could not open the map.';
//     }
//   }
// }




//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



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
//             // List<dynamic> polylinePoints = await getPolylinePointsFromFirestore("A1IxPYLCBhR9JUqPbFhD");
//             // List<List<double>> decodedPolyline = decodePolylinePoints(polylinePoints);
//
//             String encodedPolyline = await getEncodedPolylineFromFirestore("vPQXlpF4GTJzVbRAzFub");
//
//             // Step 2: Retrieve stop points from Firestore
//             // List<Map<String, List<double>>> stopPoints = await getStopPointsFromFirestore("A1IxPYLCBhR9JUqPbFhD");
//
//             // Proceed with generating GPX content and launching Google Maps app
//             // String gpxContent = generateGPXContent(decodedPolyline);  ---
//
//             // Launch Google Maps app with polyline and stop points
//             // launchGoogleMapsApp(decodedPolyline, stopPoints);
//
//             // Proceed with generating encoded polyline and launching Google Maps app
//             // String encodedPolyline = encodePolylinePoints(decodedPolyline); // -----
//
//             // launchGoogleMapsAppWithGPXUpdated(gpxContent);
//             // launchGoogleMapsAppWithEncodedPolyline(encodedPolyline, stopPoints);  //---- working but only upto a waypoint
//             launchGoogleMapsAppWithEncodedPolylineUpdated(encodedPolyline);
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
//   // Function to retrieve encoded polyline from Firestore
//   Future<String> getEncodedPolylineFromFirestore(String rideId) async {
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
//       // Extract encoded polyline from the ride document
//       dynamic data = querySnapshot.data();
//       if (data != null && data['rideEncodedPolyline'] != null) {
//         String encodedPolyline = data['rideEncodedPolyline'];
//         return encodedPolyline;
//       } else {
//         throw Exception("Encoded polyline not found for ride with ID $rideId");
//       }
//     } catch (e) {
//       print("Error getting encoded polyline for ride: $e");
//       return ''; // Return an empty string in case of error
//     }
//   }
//
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
//     print("DECODEDDD POLY POINTSSS: $coordinates");
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
//   // String _encode(double value) {
//   //   // This is a simplified version of polyline encoding
//   //   return ((value * 1e5).round()).toString();
//   // }
//
//   String _encode(double value) {
//     // This function formats the latitude or longitude value with the decimal point
//     // and rounds it to 6 decimal places as required by polyline encoding.
//     return value.toStringAsFixed(5);
//   }
//
//   // String _encode(double value) {
//   //   // Convert the rounded integer back to a double
//   //   double roundedValue = value * 1e5;
//   //   // Convert the double to a string with the decimal point
//   //   return roundedValue.toStringAsFixed(5);
//   // }
//
//   // Launch Google Maps App with encoded polyline only
//   void launchGoogleMapsAppWithEncodedPolylineUpdated(String encodedPolyline) {
//
//     String updatedencodedPolyline = Uri.encodeComponent(encodedPolyline);
//
//     // Launch Google Maps with encoded polyline
//     // String googleMapsUrl = "https://www.google.com/maps/dir/?api=1&travelmode=driving&dir_action=navigate&polyline=$updatedencodedPolyline@";
//     String googleMapsUrl = "https://www.google.com/maps/dir/?api=&origin=7.2003900000000005,79.87369000000001&destination=7.4129700000000005,79.859171&travelmode=driving&dir_action=navigate&polyline=$updatedencodedPolyline";
//     // String googleMapsUrl = "https://www.google.com/maps/dir/?api=1&travelmode=driving&dir_action=navigate&path=enc:=$updatedencodedPolyline";
//     print("Launching Google Maps with URL: $googleMapsUrl");
//     String testingurl = "https://www.google.com/maps/dir/7.20255,79.8697/7.20362,79.86964/7.2038,79.86961/7.20393,79.86963/7.20384,79.86844/7.2038,79.8674/7.20372,79.86622/7.20368,79.86558/7.20372,79.86503/7.20366,79.86404/7.20357,79.86353/7.20347,79.8618/7.20343,79.86123/7.20324,79.86024/7.20313,79.85975/7.20314,79.85965/7.2032,79.85959/7.20363,79.85944/7.20406,79.85923/7.20428,79.8591/7.20434,79.85902/7.20438,79.85888/7.20447,79.85806/7.2048,79.85562/7.20641,79.85487/7.20666,79.85473/7.20834,79.85396/7.20849,79.85391/7.21142,79.85255/7.21169,79.85241/7.21223,79.85218/7.2134,79.85164/7.21348,79.85158/7.21542,79.85071/7.21585,79.85049/7.21684,79.85003/7.21725,79.84983/7.21884,79.84912/7.22192,79.84771/7.22206,79.84765/7.22211,79.8476/7.22226,79.84749/7.22233,79.84746/7.22386,79.84878/7.22445,79.84927/7.22558,79.85016/7.22601,79.85044/7.2263,79.85058/7.22721,79.85095/7.22756,79.85105/7.22789,79.85107/7.22821,79.85103/7.22904,79.85081/7.22921,79.85079/7.22983,79.85067/7.23031,79.85052/7.23139,79.85008/7.23348,79.84945/7.23457,79.84917/7.23506,79.84908/7.23566,79.8489/7.23658,79.84858/7.23719,79.84839/7.23766,79.8483/7.23815,79.84816/7.23857,79.84808/7.23868,79.84809/7.23892,79.84817/7.23908,79.84829/7.23984,79.84917/7.24014,79.84943/7.24024,79.84949/7.24044,79.84953/7.24056,79.84953/7.24088,79.84946/7.2414,79.84931/7.24152,79.8493/7.24323,79.84882/7.24389,79.8487/7.24414,79.84872/7.24433,79.84874/7.24457,79.84881/7.24489,79.84894/7.24544,79.84925/7.2458,79.84951/7.24598,79.84964/7.24738,79.85089/7.2477,79.85111/7.24854,79.85158/7.2499,79.85205/7.25079,79.8524/7.25156,79.85275/7.25231,79.85315/7.25286,79.85351/7.25307,79.8537/7.25324,79.85398/7.25343,79.85436/7.25367,79.85495/7.25387,79.8552/7.25411,79.85536/7.25463,79.85557/7.25518,79.85568/7.25608,79.85581/7.25711,79.85591/7.25792,79.85606/7.25845,79.85616/7.25906,79.85628/7.25945,79.85634/7.25977,79.85642/7.25988,79.85643/7.2607,79.85673/7.26096,79.85683/7.26163,79.85719/7.26249,79.85756/7.26273,79.85773/7.2629,79.85789/7.26335,79.85835/7.26359,79.85856/7.26377,79.85869/7.26401,79.8588/7.26454,79.85896/7.26482,79.85907/7.26565,79.85955/7.26589,79.85973/7.26601,79.8599/7.26625,79.86034/7.26637,79.86049/7.2665,79.8606/7.26669,79.86066/7.26723,79.86077/7.26738,79.86083/7.26753,79.86098/7.26867,79.86244/7.26915,79.86301/7.26922,79.86312/7.26945,79.8633/7.26975,79.86348/7.26992,79.86356/7.27079,79.86378/7.27141,79.86397/7.2716,79.86401/7.27202,79.864/@7.2733348,79.9946128,10z?entry=ttu";
//     // String testingurl = "https://www.google.com/maps/dir/?api=1&origin=7.2003900000000005,79.87369000000001&destination=7.4129700000000005,79.85917&travelmode=driving&dir_action=navigate&data=mi%7Dj%40qiofNCqAGoCS%40s%40Dg%40BmM%5EiBHuADEmAAc%40KwD%40mCE_FG%7BAOeFSmGkCHuELgRb%40cm%40vA_HNiFDwBDcHLcBHiFLyFLwJXmQ%60%40yM%5C%7DKNuGPY%40%7BBLIMII%5D%5BgAq%40wAg%40YQOQoAsCeA%7DBc%40kAy%40Za%40NaC%7C%40mC%60As%40ZOXFf%40Ab%40W%5CUP_%40H_%40B_%40Gm%40G%7D%40NmEzAwCl%40gALy%40DUA%5BKwAs%40u%40QKA_%40DOHY%40mBDgAHaAPeAZwCp%40yAJoDHwCR_FdAeCZHv%40IBwBx%40iAb%40yEfBwE%7CAkBh%40y%40F%7BC%40m%40%40y%40HiDx%40i%40NMLOl%40QRI%3F_AImAa%40YOgAc%40gBc%40gBc%40c%40fA%7D%40xDQp%40MJc%40DcA%5Es%40Vc%40Xw%40z%40%5DXq%40r%40iCrDw%40p%40oBfAYLwAb%40UFAf%40EzBO~CMjBe%40rD%7D%40bIS%7CAIbBItDEtCNlALrABr%40FrDIz%40Ol%40W~AK~ASZ_Al%40k%40i%40e%40KsAOu%40Qq%40w%40sAmB%7BB%7BC%7D%40iAo%40%7D%40kAw%40%7D%40_%40gAQaDk%40aAScBMc%40CsATOc%40A%5Bs%40%7BASe%40gBoC%7DF%7DH%7DAsBo%40q%40%7B%40o%40uAs%40yAq%40eAYcCMmCI%7BAW_AQoB%5DkC_Aw%40a%40iKyIcBwAeBcA_CqAkGwDoNoI%7BFsDqLuHkM%7BHsByAs%40a%40yC%7DBwFeEsCmAC%40C%3FGCCG%7BF%7BBmB%7B%40SSiCkBsDqCeIqGsPgMyKcI%7D%40%5DaAO%7BX%7DDeIiAaBWgAYkHoDsCmAaA%5DeBc%40sCg%40%7D%40GiBIqDOiAAqCB%7DBNcPz%40mHl%40sHt%40cB%60%40kDdAyNrEoDbAiB%5CiH%60AgJjA_BJkAC%7B%40I%7BC_%40uBO%7DASmDe%40%7BDa%40cCEmAAwEDsDFsAFaA%5C%7DJhEkMhFaO%60GqDrAyAl%40wEpBiOfGiIdDiMfFaE%60B%7DBz%40qCdA%7DAp%40aBnAmAdAiD~CoD~CoC%60Cg%40%5C%7B%40ZgCl%40iD~%40oCt%40cCp%40mBhAqBx%40mBb%40gBLqGDwBBiCLaCT%7BAToEjAuG%60BgAb%40_Af%40wAbAe%40d%40eAlAs%40~%40%7DCtDuHfJgE%60FmB~ByErFqK%7CLeBvB%7DCtD%7BAjBwAjB%7BBjC_BdByCzDcE~F_%40%5Ei%40Bu%40E%7B%40OsCs%40kA%5DaA_%40i%40%5D%7BDcD%7DAmAcAi%40%7BBqAyB%7DAcDaCu%40q%40kBeBa%40Sc%40K%7BFa%40eJi%40wE_%40mKg%40KHeAh%40aCt%40eCz%40sBj%40QBWASIQEe%40%3Fk%40DcAHChBAp%40Cl%40OfD_%40zDKx%40EX_BQsBOwDW%5BIcAe%40i%40dCQhB";
// String testingurl = "https://www.google.com/maps/dir/?api=1&origin=7.2003900000000005,79.87369000000001&destination=7.4129700000000005,79.85917&travelmode=driving&dir_action=navigate&polyline=mi%7Dj%40qiofNCqAGoCS%40s%40Dg%40BmM%5EiBHuADEmAAc%40KwD%40mCE_FG%7BAOeFSmGkCHuELgRb%40cm%40vA_HNiFDwBDcHLcBHiFLyFLwJXmQ%60%40yM%5C%7DKNuGPY%40%7BBLIMII%5D%5BgAq%40wAg%40YQOQoAsCeA%7DBc%40kAy%40Za%40NaC%7C%40mC%60As%40ZOXFf%40Ab%40W%5CUP_%40H_%40B_%40Gm%40G%7D%40NmEzAwCl%40gALy%40DUA%5BKwAs%40u%40QKA_%40DOHY%40mBDgAHaAPeAZwCp%40yAJoDHwCR_FdAeCZHv%40IBwBx%40iAb%40yEfBwE%7CAkBh%40y%40F%7BC%40m%40%40y%40HiDx%40i%40NMLOl%40QRI%3F_AImAa%40YOgAc%40gBc%40gBc%40c%40fA%7D%40xDQp%40MJc%40DcA%5Es%40Vc%40Xw%40z%40%5DXq%40r%40iCrDw%40p%40oBfAYLwAb%40UFAf%40EzBO~CMjBe%40rD%7D%40bIS%7CAIbBItDEtCNlALrABr%40FrDIz%40Ol%40W~AK~ASZ_Al%40k%40i%40e%40KsAOu%40Qq%40w%40sAmB%7BB%7BC%7D%40iAo%40%7D%40kAw%40%7D%40_%40gAQaDk%40aAScBMc%40CsATOc%40A%5Bs%40%7BASe%40gBoC%7DF%7DH%7DAsBo%40q%40%7B%40o%40uAs%40yAq%40eAYcCMmCI%7BAW_AQoB%5DkC_Aw%40a%40iKyIcBwAeBcA_CqAkGwDoNoI%7BFsDqLuHkM%7BHsByAs%40a%40yC%7DBwFeEsCmAC%40C%3FGCCG%7BF%7BBmB%7B%40SSiCkBsDqCeIqGsPgMyKcI%7D%40%5DaAO%7BX%7DDeIiAaBWgAYkHoDsCmAaA%5DeBc%40sCg%40%7D%40GiBIqDOiAAqCB%7DBNcPz%40mHl%40sHt%40cB%60%40kDdAyNrEoDbAiB%5CiH%60AgJjA_BJkAC%7B%40I%7BC_%40uBO%7DASmDe%40%7BDa%40cCEmAAwEDsDFsAFaA%5C%7DJhEkMhFaO%60GqDrAyAl%40wEpBiOfGiIdDiMfFaE%60B%7DBz%40qCdA%7DAp%40aBnAmAdAiD~CoD~CoC%60Cg%40%5C%7B%40ZgCl%40iD~%40oCt%40cCp%40mBhAqBx%40mBb%40gBLqGDwBBiCLaCT%7BAToEjAuG%60BgAb%40_Af%40wAbAe%40d%40eAlAs%40~%40%7DCtDuHfJgE%60FmB~ByErFqK%7CLeBvB%7DCtD%7BAjBwAjB%7BBjC_BdByCzDcE~F_%40%5Ei%40Bu%40E%7B%40OsCs%40kA%5DaA_%40i%40%5D%7BDcD%7DAmAcAi%40%7BBqAyB%7DAcDaCu%40q%40kBeBa%40Sc%40K%7BFa%40eJi%40wE_%40mKg%40KHeAh%40aCt%40eCz%40sBj%40QBWASIQEe%40%3Fk%40DcAHChBAp%40Cl%40OfD_%40zDKx%40EX_BQsBOwDW%5BIcAe%40i%40dCQhB";
//
//
//     launch(testingurl);
//   }
//
//   // void launchGoogleMapsAppWithEncodedPolyline(String encodedPolyline) {
//   //   // Construct the Google Maps URL with the encoded polyline
//   //   String googleMapsUrl = "https://www.google.com/maps/dir/?api=1&travelmode=driving&dir_action=navigate&polyline=$encodedPolyline";
//   //
//   //   // Launch Google Maps with the URL
//   //   print("Launching Google Maps with URL: $googleMapsUrl");
//   //   launch(googleMapsUrl);
//   // }
//
//   // Launch Google Maps App with encoded polyline and stop points
//   void launchGoogleMapsAppWithEncodedPolyline(String encodedPolyline, List<Map<String, List<double>>> stopPoints) {
//
//
//     print("THISSS IS THE ENCODED POLYLINE: $encodedPolyline");
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
//     // launch(googleMapsUrl);
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
