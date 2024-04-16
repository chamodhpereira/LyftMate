// // import 'package:http/http.dart' as http;
// //
//
// import 'package:twilio_flutter/twilio_flutter.dart';
//
// class EmergencyService {
//   static const String _twilioAccountSid = 'YOUR_TWILIO_ACCOUNT_SID';
//   static const String _twilioAuthToken = 'YOUR_TWILIO_AUTH_TOKEN';
//   static const String _twilioPhoneNumber = 'YOUR_TWILIO_PHONE_NUMBER';
//   static const String _emergencyMessagePrefix = 'EMERGENCY: ';
//
//   static Future<void> sendSOS(String message) async {
//     TwilioFlutter twilioFlutter = TwilioFlutter(
//       accountSid: _twilioAccountSid,
//       authToken: _twilioAuthToken,
//       twilioNumber: _twilioPhoneNumber,
//     );
//
//     try {
//       await twilioFlutter.sendSMS(
//         toNumber: 'EMERGENCY_CONTACT_PHONE_NUMBER',
//         messageBody: '$_emergencyMessagePrefix$message',
//       );
//     } catch (e) {
//       print('Error sending SOS: $e');
//     }
//   }
//
//   static Future<void> shareRideDetails(String driverName, String passengerDetails) async {
//
//     String emergencyMessage = 'Ride Details - Driver: $driverName, Passenger: $passengerDetails';
//     await sendSOS(emergencyMessage);
//   }
// }
//
//
//
//
//
//
