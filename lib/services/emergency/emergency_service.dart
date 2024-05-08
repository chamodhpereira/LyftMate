import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmergencyService {
  static String get _twilioAccountSid => dotenv.env['TWILIO_ACCOUNT_SID']!;
  static String get _twilioAuthToken => dotenv.env['TWILIO_AUTH_TOKEN']!;
  static String get _twilioPhoneNumber => dotenv.env['TWILIO_PHONE_NUMBER']!;
  static const String _emergencyMessagePrefix = 'EMERGENCY: ';

  static Future<void> sendMessage(String message) async {
    print('Sending Message: $message');

    TwilioFlutter twilioFlutter = TwilioFlutter(
      accountSid: _twilioAccountSid,
      authToken: _twilioAuthToken,
      twilioNumber: _twilioPhoneNumber,
    );

    // "EMERGENCY: [User's Name] needs help! [User's Message]. Location: [User's Current Location]"

    try {
      await twilioFlutter.sendSMS(
        toNumber: '+94 77 561 5718',
        messageBody: message,
      );
      print('SOS sent successfully');
    } catch (e) {
      print('Error sending SOS: $e');
    }
  }

  static Future<void> sendSOS(String userName) async {
    print("user name in SOS METHOD: $userName");
    String emergencyMessage = "LYFTMATE EMERGENCY: $userName needs help urgently! Please contact them immediately.";

    await sendMessage(emergencyMessage);

  }

  // static Future<void> shareRideDetails(String driverName, String passengerDetails) async {
  //   print('Sharing ride details - Driver: $driverName, Passenger: $passengerDetails');
  //
  //   String emergencyMessage = 'Ride Details - Driver: $driverName, Passenger: $passengerDetails';
  //   await sendMessage(emergencyMessage);
  // }

  static Future<void> shareRideDetails(String rideId) async {
    print('Fetching ride details for ride ID: $rideId');

    String rideLocationName = "";

    try {
      // Retrieve ride document from Firestore
      DocumentSnapshot<Map<String, dynamic>> rideDoc = await FirebaseFirestore.instance
          .collection('rides')
          .doc(rideId)
          .get();

      if (rideDoc.exists) {
        print('Ride document found');
        // Extract necessary details from the ride document
        String driverId = rideDoc.get('userId');
        String pickupLocationName = rideDoc.get('pickupLocationName');
        String dropoffLocationName = rideDoc.get('dropoffLocationName');
        GeoPoint rideLocation = rideDoc.get('rideLocation')['geopoint'];


        // Debug
        print('Driver ID: $driverId');
        print('Pickup Location Name: $pickupLocationName');
        print('Dropoff Location Name: $dropoffLocationName');
        print('Ride Location: $rideLocation');
        print('Ride Location LAT: ${rideLocation.latitude}');
        print('Ride Location LNG: ${rideLocation.longitude}');

        // Use geocoding to get the location name
        List<Placemark> placemarks = await placemarkFromCoordinates(rideLocation.latitude, rideLocation.longitude);
        if (placemarks.isEmpty) {
          print('No placemarks found');
        } else {
          // List rideLoc = placemarks;
          rideLocationName = "${placemarks[0].locality}, ${placemarks[0].country}" ?? 'Unknown Location';

          // print(rideLoc);

          print('Ride Location Name: $rideLocationName');
        }


        // // Debug
        // print('Ride Location Name: $rideLocationName');

        // Retrieve driver name from Firestore based on driverId
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(driverId)
            .get();

        if (userDoc.exists) {
          print('Driver document found');
          String driverName = userDoc.get('firstName');

          // Compose message with ride details
          String emergencyMessage = 'Ride Details\n'
              'Driver: $driverName\n'
              'Ride ID: $rideId\n'
              'Pickup Location: $pickupLocationName\n'
              'Dropoff Location: $dropoffLocationName\n'
              'Current Location: $rideLocationName';

          // Send message
          await sendMessage(emergencyMessage);

          print('Ride details shared successfully');
        } else {
          print('Driver document not found for driver ID: $driverId');
        }
      } else {
        print('Ride document not found');
      }
    } catch (e) {
      print('Error fetching ride details: $e');
    }
  }


  // static Future<void> shareRideDetails(String rideId) async {
  //   print('Fetching ride details for ride ID: $rideId');
  //
  //   try {
  //     // Retrieve ride document from Firestore
  //     DocumentSnapshot<Map<String, dynamic>> rideDoc = await FirebaseFirestore.instance
  //         .collection('rides')
  //         .doc(rideId)
  //         .get();
  //
  //     if (rideDoc.exists) {
  //       // Extract necessary details from the ride document
  //       String driverId = rideDoc.get('userId');
  //       String pickupLocationName = rideDoc.get('pickupLocationName');
  //       String dropoffLocationName = rideDoc.get('dropoffLocationName');
  //       GeoPoint rideLocation = rideDoc.get('rideLocation')['geopoint'];
  //       // GeoPoint rideGeoPoint = rideLocation['geopoint'];
  //       // double rideLatitude = rideGeoPoint.latitude;
  //       // double rideLongitude = rideGeoPoint.longitude;
  //
  //
  //       // Use geocoding to get the location name
  //       List<Placemark> placemarks = await placemarkFromCoordinates(rideLocation.latitude, rideLocation.longitude);
  //       String rideLocationName = placemarks[0].name ?? 'Unknown Location';
  //
  //       // Retrieve driver name from Firestore based on driverId
  //       DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(driverId)
  //           .get();
  //
  //       if (userDoc.exists) {
  //         String driverName = userDoc.get('firstName');
  //
  //         // Compose message with ride details
  //         String emergencyMessage = 'Ride Details\n'
  //             'Driver: $driverName\n'
  //             'Ride ID: $rideId\n'
  //             'Pickup Location: $pickupLocationName\n'
  //             'Dropoff Location: $dropoffLocationName\n'
  //             // 'Current Ride Location: Latitude: $rideLatitude, Longitude: $rideLongitude';
  //             'Current Ride Location: $rideLocationName';
  //
  //         print("THISSS IS THE EM MSSSSSSSSSSSSSG: $emergencyMessage");
  //
  //         // Send message
  //         // await sendMessage(emergencyMessage);
  //
  //         print('Ride details shared successfully');
  //       } else {
  //         print('Driver document not found for driver ID: $driverId');
  //       }
  //     } else {
  //       print('Ride document not found');
  //     }
  //   } catch (e) {
  //     print('Error fetching ride details: $e');
  //   }
  // }




  // static Future<void> sendSOSWithLocation(double latitude, double longitude, String userMessage) async {
  //   // Reverse geocoding to get the location name or place
  //   try {
  //     List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);  // using geocoding package
  //     String locationName = placemarks[0].name; // Get the name of the location
  //     String emergencyMessage = '$userMessage\nLocation: $locationName';
  //     await sendSOS(emergencyMessage);
  //   } catch (e) {
  //     print('Error getting location: $e');
  //     // If there's an error in reverse geocoding, just send the SOS with coordinates
  //     String emergencyMessage = '$userMessage\nLatitude: $latitude, Longitude: $longitude';
  //     await sendSOS(emergencyMessage);
  //   }
  // }

}
