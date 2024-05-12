import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SmsService {
  static String get _vonageApiKey => dotenv.env['VONAGE_API_KEY']!;
  static String get _vonageApiSecret => dotenv.env['VONAGE_API_SECRET']!;

  // Sends an SMS message using Vonage's SMS API
  static Future<bool> sendMessage(String message, String toNumber) async {
    debugPrint('Sending refund message: $message');

    final response = await http.post(
      Uri.parse('https://rest.nexmo.com/sms/json'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'api_key': _vonageApiKey,
        'api_secret': _vonageApiSecret,
        'to': toNumber,
        'from': 'LyftMate', // Customizable sender name
        'text': message,
      }),
    );

    if (response.statusCode == 200) {
      debugPrint('Refund notification sent successfully');
      return true;
    } else {
      debugPrint('Error sending refund notification: ${response.body}');
      return false;
    }
  }

  static Future<bool> sendRefundNotification(String? toNumber, String? userName, double amount) async {

    if (toNumber == null || userName == null) {
      debugPrint('Missing critical information: No SMS sent.');
      return false;
    }
    String refundMessage = "Hello $userName! You will be refunded \$$amount within a few days. Thank you for using LyftMate.";
    return await sendMessage(refundMessage, dotenv.env['REGISTERED_PHONENUMBER']!);
  }

  static Future<void> notifyPaidPassengersOfRefund(List<dynamic> passengers, String rideId, {double? refundAmount}) async {
    for (var passenger in passengers) {
      bool paidStatus = passenger['paidStatus'] ?? false;
      String? phoneNumber = passenger['phoneNumber'];
      String? name = passenger['name'];
      double amount = passenger['amount'] ?? refundAmount; // Use specific amount if available

      if (paidStatus && phoneNumber != null && name != null) {
        String message = "Hello $name! Your ride with ID $rideId has been cancelled. You will be refunded \$$amount within a few days. Thank you for using our service.";
        await sendMessage(message, dotenv.env['REGISTERED_PHONENUMBER']!);
      }
    }
  }


}
