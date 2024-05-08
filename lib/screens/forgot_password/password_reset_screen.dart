import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:lyft_mate/screens/login/login_screen.dart';


class PasswordResetSentScreen extends StatelessWidget {
  const PasswordResetSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Lottie.asset(
                "assets/images/email_animation.json",
                height: MediaQuery.of(context).size.height * 0.4, // Adjust the height accordingly
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned( // Positioned to move the text exactly below the Lottie animation
            top: 300,
            left: 0,
            right: 0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      'support@lyftmate.com',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Password Reset Email Sent',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your account security is our priority! We\'ve sent you a secure link to safely change your password and keep your account protected.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        // Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                            // builder: (context) => PasswordResetSentScreen(email: email),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Done'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        // Add resend password reset logic here
                      },
                      child: const Text('Resend Email'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      )



      // Center(
      //   child: Padding(
      //     padding: const EdgeInsets.all(16.0),
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         // Replace this placeholder image with your desired illustration
      //         Image.asset(
      //           'assets/password_reset_illustration.png',
      //           height: 150, // Adjust based on your illustration
      //         ),
      //         const SizedBox(height: 24),
      //         Text(
      //           'support@codingwith.com',
      //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      //         ),
      //         SizedBox(height: 16),
      //         Text(
      //           'Password Reset Email Sent',
      //           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      //         ),
      //         SizedBox(height: 8),
      //         Text(
      //           'Your account security is our priority! We\'ve sent you a secure link to safely change your password and keep your account protected.',
      //           textAlign: TextAlign.center,
      //           style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      //         ),
      //         SizedBox(height: 32),
      //         ElevatedButton(
      //           onPressed: () {
      //             Navigator.pop(context);
      //           },
      //           child: Text('Done'),
      //           style: ElevatedButton.styleFrom(
      //             minimumSize: Size(double.infinity, 50),
      //             shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(10),
      //             ),
      //           ),
      //         ),
      //         SizedBox(height: 16),
      //         TextButton(
      //           onPressed: () {
      //             // Add resend password reset logic here
      //           },
      //           child: Text('Resend Email'),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}