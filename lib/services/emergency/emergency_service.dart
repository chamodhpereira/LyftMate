import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmergencyService {
  static String get _vonageApiKey => dotenv.env['VONAGE_API_KEY']!;
  static String get _vonageApiSecret => dotenv.env['VONAGE_API_SECRET']!;
  static const String _emergencyMessagePrefix = 'EMERGENCY: ';

  // Sends an SMS message using Vonage SMS API and returns a boolean indicating success/failure.
  static Future<bool> sendMessage(String message, String toNumber) async {
    print('Sending Message: $message');

    final response = await http.post(
      Uri.parse('https://rest.nexmo.com/sms/json'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'api_key': _vonageApiKey,
        'api_secret': _vonageApiSecret,
        'to': toNumber,
        'from': 'Vonage',
        'text': message,
      }),
    );

    if (response.statusCode == 200) {
      print('SOS sent successfully');
      return true;
    } else {
      print('Error sending SOS: ${response.body}');
      return false;
    }
  }

  // Sends an SOS message and returns a boolean indicating success/failure.
  static Future<bool> sendSOS(String userName) async {
    print("User name in SOS method: $userName");
    String emergencyMessage = "LYFTMATE EMERGENCY: $userName needs help urgently! Please contact them immediately.";
    return await sendMessage(emergencyMessage, dotenv.env['REGISTERED_PHONENUMBER']!);
  }

  // Shares ride details using Vonage and returns a boolean indicating success/failure.
  static Future<bool> shareRideDetails(String rideId) async {
    print('Fetching ride details for ride ID: $rideId');

    String rideLocationName = "";
    String? currentUserFirstName;
    String? currentUserLastName;

    try {
      // Retrieve the current user's name from Firestore
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot<Map<String, dynamic>> currentUserDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
        if (currentUserDoc.exists) {
          currentUserFirstName = currentUserDoc.get('firstName');
          currentUserLastName = currentUserDoc.get('lastName');
        }
      }

      // Retrieve the ride document from Firestore
      DocumentSnapshot<Map<String, dynamic>> rideDoc = await FirebaseFirestore.instance.collection('rides').doc(rideId).get();
      if (rideDoc.exists) {
        print('Ride document found');

        // Extract necessary details from the ride document
        String driverId = rideDoc.get('driverId');
        String pickupLocationName = rideDoc.get('pickupLocationName');
        String dropoffLocationName = rideDoc.get('dropoffLocationName');

        // Directly access the latitude and longitude properties of the GeoPoint objects
        GeoPoint pickupLocation = rideDoc.get('pickupLocation')['geopoint'];
        GeoPoint dropoffLocation = rideDoc.get('dropoffLocation')['geopoint'];
        GeoPoint rideLocation = rideDoc.get('rideLocation');

        // Use geocoding to find the location name
        List<Placemark> placemarks = await placemarkFromCoordinates(rideLocation.latitude, rideLocation.longitude);
        rideLocationName = placemarks.isNotEmpty ? "${placemarks[0].locality}, ${placemarks[0].country}" : 'Unknown Location';

        // Retrieve the driver's name and phone number from Firestore based on driverId
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance.collection('users').doc(driverId).get();
        if (userDoc.exists) {
          print('Driver document found');
          String driverName = userDoc.get('firstName');
          String driverPhoneNumber = userDoc.get('phoneNumber'); // Assuming 'phoneNumber' field

          String emergencyMessage = '''
🚨 Ride Details Shared 🚨
${currentUserFirstName ?? "User"} ${currentUserLastName ?? ""} shared their ride details with you.

🚖 Ride Information 🚖
Driver: $driverName
Phone: $driverPhoneNumber
Ride ID: $rideId
Pickup Location: $pickupLocationName
Dropoff Location: $dropoffLocationName
Current Location: $rideLocationName

Please contact the driver for assistance or additional information.
''';
          // Send the message using Vonage
          return await sendMessage(emergencyMessage, dotenv.env['REGISTERED_PHONENUMBER']!);
        } else {
          print('Driver document not found for driver ID: $driverId');
        }
      } else {
        print('Ride document not found');
      }
    } catch (e) {
      print('Error fetching ride details: $e');
    }
    return false;
  }
}


