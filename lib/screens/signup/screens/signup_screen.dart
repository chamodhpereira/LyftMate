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
        title: const Text('Signup', style: TextStyle(letterSpacing: 0.9, fontWeight: FontWeight.bold, fontSize: 18.0),),
        centerTitle: true,
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
                    "assets/images/signup-image.avif",
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
                  child: OutlinedButton(
                    onPressed: () async {
                      String userphoneNumber = countryCode + phoneController.text.replaceAll(' ', '');
                      debugPrint('Attempting to send OTP to $userphoneNumber');
                      if (phoneController.text.length <= countryCode.length) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a valid phone number'),
                          ),
                        );
                      }
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
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text("Proceed", style: TextStyle(letterSpacing: 0.9, fontSize: 14.0, fontWeight: FontWeight.bold),),
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







// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:lyft_mate/screens/otp/otp_screen.dart';
// import 'package:lyft_mate/screens/signup/screens/signup_form.dart';
// import 'package:lyft_mate/models/signup_user.dart';
//
//
// import 'package:provider/provider.dart';
//
// import '../../../constants/colors.dart';
// import '../../../constants/sizes.dart';
// import '../../../services/otp/otp_service.dart';
//
//
//
//
//
// class SignupScreen extends StatefulWidget {
//
//   const SignupScreen({super.key});
//
//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }
//
// class _SignupScreenState extends State<SignupScreen> {
//   final TextEditingController phoneController = TextEditingController();
//
//   String errorMessage = '';
//   String countryCode = "+94";
//
//   void _getToken() async {
//     String? token = await FirebaseMessaging.instance.getToken();
//     print('FCM Token: $token');
//     // return token ?? '';// Return token, or empty string if null
//
//     SignupUserData().updateNotificationToken(token ?? "");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // final authenticationService = Provider.of<AuthenticationService>(context);
//
//     _getToken();
//
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       appBar: AppBar(
//         title: const Text('Sign Up'),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           onPressed: () {},
//           icon: const Icon(Icons.arrow_back_ios),
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView( // Wrap with SingleChildScrollView
//           child: Padding(
//             padding: const EdgeInsets.only(top: 50.0, left: 18.0, right: 18.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 20), // Added space
//                 Hero(
//                   tag: "logo",
//                   child: Image.asset(
//                     "assets/images/carpool-image-4.jpg",
//                     height: 200.0,
//                   ),
//                 ),
//                 const SizedBox(height: 20), // Added space
//                 Container(
//                   padding: const EdgeInsets.symmetric(vertical: 30.0),
//                   child: TextField(
//                     onTap: () {
//                       setState(() {
//                         errorMessage = "";
//                       });
//                     },
//                     controller: phoneController,
//                     decoration: InputDecoration(
//                       labelText: 'Enter your phone number',
//                       prefixText: countryCode + " ",
//                       // prefixStyle: TextStyle(wordSpacing: 10),
//                     ),
//                     keyboardType: TextInputType.phone, // Set keyboard type to phone
//                     onChanged: (value) {
//                       // Update the controller's text when the value changes
//                       phoneController.text = value;
//                       // phoneController.selection = TextSelection.fromPosition(
//                       //   TextPosition(offset: phoneController.text.length),
//                       // );
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Center(
//                     child: Text(
//                         errorMessage,
//                         style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.red
//                         )
//                     )
//                 ),
//                 SizedBox(
//                   height: 50.0,
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     // style: ButtonStyle(
//                     //   backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
//                     // ),
//                     style: ElevatedButton.styleFrom(
//                       shape: const RoundedRectangleBorder(),
//                       foregroundColor: kWhiteColor,
//                       backgroundColor: Colors.green,
//                       side: const BorderSide(color: kSecondaryColor),
//                       // padding: const EdgeInsets.symmetric(vertical: 10.0),
//                     ),
//                     onPressed: () async {
//                       String phoneNumber = phoneController.text;
//                       SignupUserData().updatePhoneNumber(phoneNumber);// update user phone number
//
//                       String result = await TwilioVerification.instance.sendCode('+94' + phoneController.text);
//
//                       // String result = "Successful";
//
//                       if (result == 'Successful'){
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => OTPScreen(phoneNumber: phoneNumber,))
//                         );
//                       }
//                       else{
//                         setState(() {
//                           errorMessage = result;
//                         });
//                       }
//
//                       // Navigator.push(
//                       //   context,
//                       //   // MaterialPageRoute(
//                       //   //   builder: (context) => OTPScreen(
//                       //   //     phonenumber: phoneNumber,
//                       //   //     fromScreen: 'signup',
//                       //   //   ),
//                       //   // ),
//                       //   MaterialPageRoute(
//                       //     builder: (context) => SignUpForm(),
//                       //   ),
//                       // );
//                     },
//
//                     child: Text("Proceed".toUpperCase(), style: kBoldTextStyle,),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
