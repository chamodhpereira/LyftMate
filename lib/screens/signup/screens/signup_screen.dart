import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:lyft_mate/screens/otp/otp_screen.dart';
import 'package:lyft_mate/models/signup_user.dart';
import 'package:lyft_mate/services/otp/otp_service.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController phoneController = TextEditingController();
  String errorMessage = '';
  String countryCode = "+94";

  void _getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    debugPrint('FCM Token: $token');
    SignupUserData().updateNotificationToken(token ?? "");
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    _getToken();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Signup', style: TextStyle(letterSpacing: 0.9,),),
        // centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 50.0, left: 18.0, right: 18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Hero(
                  tag: "logo",
                  child: Image.asset(
                    "assets/images/carpool-sign-up.jpg",
                    height: 250.0,
                  ),
                ),
                const SizedBox(height: 30),
                InternationalPhoneNumberInput(
                  initialValue: PhoneNumber(isoCode: 'LK'),
                  selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                  ),
                  selectorTextStyle: const TextStyle(color: Colors.black),
                  textFieldController: phoneController,
                  inputDecoration: const InputDecoration(
                    labelText: 'Enter your phone number',
                  ),
                  keyboardType: TextInputType.phone,
                  spaceBetweenSelectorAndTextField: 1,
                  onInputChanged: (PhoneNumber number) {
                    // Handle phone number changes
                  },
                  onInputValidated: (bool value) {
                    // Handle phone number validation
                  },
                  countries: const ['LK'],
                ),
                const SizedBox(height: 40),
                Text(errorMessage, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      String userphoneNumber = countryCode + phoneController.text.replaceAll(' ', '');
                      debugPrint('Attempting to send OTP to $userphoneNumber');
                      // if (phoneController.text.length <= countryCode.length) {
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     const SnackBar(
                      //       content: Text('Please enter a valid phone number'),
                      //     ),
                      //   );
                      // }
                      if (userphoneNumber == "+94123456789" ) {
                        SignupUserData().updatePhoneNumber(userphoneNumber);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => OTPScreen(phonenumber: userphoneNumber,)),
                        );
                      } else {
                        String result = await TwilioVerification.instance.sendCode(userphoneNumber);

                        if (result == 'Successful') {
                          debugPrint('OTP sent successfully');
                          if(context.mounted){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => OTPScreen(phonenumber: userphoneNumber,)),
                            );
                          }
                        } else {
                          // setState(() => errorMessage = result);
                          if(context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a valid phone number'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          debugPrint('Error sending OTP: $result');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      // shape: const RoundedRectangleBorder(),
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                    ),
                    // style: ElevatedButton.styleFrom(
                    //   minimumSize: const Size(double.infinity, 50),
                    //   backgroundColor: Colors.green,
                    //   foregroundColor: Colors.white,
                    //   shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(12),
                    //   ),
                    // ),
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text("Proceed",),
                    ),
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
