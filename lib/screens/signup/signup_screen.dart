import 'package:flutter/material.dart';
// import 'package:lyft_mate/src/components/forms/signup_form.dart';
// import 'package:lyft_mate/src/screens/otp_screen.dart';

import 'package:lyft_mate/screens/signup/signup_form.dart';
import 'package:provider/provider.dart';

import '../../services/authentication_service.dart';
import '../otp/otp_screen.dart';

class SignupScreen extends StatelessWidget {
  // SignupScreen({Key key}) : super(key: key);

  // final AuthenticationService _authenticationService = AuthenticationService();

  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authenticationService = Provider.of<AuthenticationService>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView( // Wrap with SingleChildScrollView
          child: Padding(
            padding: const EdgeInsets.only(top: 50.0, left: 18.0, right: 18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20), // Added space
                Hero(
                  tag: "logo",
                  child: Image.asset(
                    "assets/images/carpool-image-4.jpg",
                    height: 200.0,
                  ),
                ),
                SizedBox(height: 20), // Added space
                Container(
                  padding: EdgeInsets.symmetric(vertical: 30.0),
                  child: TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Enter your phone number',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 50.0,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                    ),
                    onPressed: () {
                      String phoneNumber = phoneController.text;
                      authenticationService.phoneAuthentication(phoneNumber);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OTPScreen(
                            phonenumber: phoneNumber,
                            fromScreen: 'signup',
                          ),
                        ),
                      );
                    },

                    child: const Text("Proceed"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
