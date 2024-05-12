
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  static Map<String, dynamic>? paymentIntent;

  static Future<String?> makePayment(double amount, String email, String username) async {
    try {
      paymentIntent = await createPaymentIntent(amount, email, username);
      print('Payment Intent: $paymentIntent');

      var gpay = const PaymentSheetGooglePay(
        merchantCountryCode: "US",
        currencyCode: "US",
        testEnv: true,
      );

      await Stripe.instance.initPaymentSheet(paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntent!["client_secret"],
        style: ThemeMode.dark,
        merchantDisplayName: "LyftMate",
        googlePay: gpay,
      ));

      print('Payment sheet initialized');

      bool res = await displayPaymentSheet();
      if (res) {
        return paymentIntent!["id"]; // Return the payment ID on success
      }
      return null; // Payment failed
    } catch (e) {
      print('Error making payment: $e');
      return null; // Payment failed
    }
  }


  static Future<bool> displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      print("Payment sheet presented");
      return true;
    } catch (e) {
      print("Error presenting payment sheet: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>> createPaymentIntent(double amount, String email, String payerName) async {
    try {

      // Convert amount to cents
      int amountInCents = (amount * 100).toInt();



      Map<String, dynamic> body = {
        "amount": amountInCents.toString(),
        "currency": "LKR",
        "receipt_email": email, // Include email of the payer
        "description": "Payment by $payerName", // Include name of the payer
        // "customer": "Itadori Yuji"
      };

      http.Response response = await http.post(
          Uri.parse("https://api.stripe.com/v1/payment_intents"),
          body: body,
          headers: {
            "Authorization":
            "Bearer sk_test_51P0qunAUzW9AUgM9QzqfIaOFsEgdTcn9vZcDLD42TtDglcBFXssDbXCdic3feRgZdp61gTKPsWe0G6KGrWHbu19Y00rVDLcV09",
            "Content-Type": "application/x-www-form-urlencoded",
          });
      return json.decode(response.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}