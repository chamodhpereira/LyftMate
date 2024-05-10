import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class RideRequestSentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green, // Set the background color to green
      body: SafeArea(
        child: Stack( // Use Stack to overlay widgets
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 130.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: Lottie.asset(
                  "assets/images/request-sent-animation.json", // Replace this with the appropriate animation file
                  height: MediaQuery.of(context).size.height * 0.3,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Positioned(
              top: 400,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    'Ride Request Sent',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      "You'll be notified once the driver accepts your request.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Positioned( // Positioned to align the button at the bottom
              bottom: 10, // Adjust bottom padding to match your design
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.green, backgroundColor: Colors.white, // Button text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24), // Rounded corners
                    ),
                    minimumSize: const Size(double.infinity, 50), // Full-width button
                  ),
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/navigationScreen',
                        (route) => false,
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
