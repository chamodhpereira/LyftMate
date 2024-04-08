import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Map<String, dynamic>? paymentIntent;

  void makePayment() async {
    try {
      paymentIntent = await createPaymentIntent();

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

      displayPaymentSheet();
    } catch (e) {}
  }

  void displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      print("DONNNNNNEEEE");
    } catch (e) {
      print("PAYMENET SHEET FAILEd");
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent() async {
    try {
      Map<String, dynamic> body = {
        "amount": "1000",
        "currency": "USD",
        "receipt_email": "hp@mail.com", // Include email of the payer
        "description": "Payment by Harry Potter", // Include name of the payer
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stripe Payment"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            makePayment();
          },
          child: Text("Make Payment"),

        ),
      ),
    );
  }
}
