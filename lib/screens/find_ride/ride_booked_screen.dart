import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:lyft_mate/screens/navigation/navigation_screen.dart';


class RideBookedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green, // Set the background color to green
      body: SafeArea(
        child: Stack( // Use Stack to overlay widgets
          children: [
            // SizedBox(height: 50,),
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: Lottie.asset(
                  "assets/images/ridebooked-animation.json",
                  height: MediaQuery.of(context).size.height * 0.5,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Positioned(
              // top: MediaQuery.of(context).size.height * 0.5,
              top: 360,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    'Booked! Enjoy your ride',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30,),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      "Go to 'My rides' section for details of your ride and more options.",
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
                padding: const EdgeInsets.only(left: 12.0, top: 0, right: 12.0, bottom: 12.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.green, backgroundColor: Colors.white, // Button text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24), // Rounded corners
                    ),
                    minimumSize: const Size(double.infinity, 50), // Full width button
                  ),
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/navigationScreen', (route) => false,), // Dismiss the screen when button is pressed
                  child: Text(
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

