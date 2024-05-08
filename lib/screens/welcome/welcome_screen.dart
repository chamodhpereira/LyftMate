import 'package:flutter/material.dart';
import 'package:lyft_mate/constants/colors.dart';
import 'package:lyft_mate/screens/signup/screens/signup_screen.dart';
import '../login/login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Hero(
                tag: "logo",
                child: Image.asset(
                  "assets/images/carpool-image-4.jpg",
                  height: height * 0.4,
                ),
              ),
              Column(
                children: [
                  Text(
                    "LyftMate🚀",
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  Text(
                    "Join the community, and enjoy the ride.",
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        debugPrint("Login button pressed.");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        // shape: const RoundedRectangleBorder(),
                        foregroundColor: kSecondaryColor,
                        side: const BorderSide(color: kSecondaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                      ),
                      child: Text(
                        "Login".toUpperCase(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        debugPrint("Signup button pressed.");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignupScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        // shape: const RoundedRectangleBorder(),
                        foregroundColor: kWhiteColor,
                        backgroundColor: Colors.green,
                        side: const BorderSide(color: kSecondaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                      ),
                      child: Text(
                        "Signup".toUpperCase(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
