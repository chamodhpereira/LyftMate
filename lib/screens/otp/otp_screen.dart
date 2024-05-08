import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:lottie/lottie.dart';


import '../../models/signup_user.dart';
import '../../services/otp/otp_service.dart';
import '../signup/screens/signup_form.dart';


class OTPScreen extends StatefulWidget {
  final String phonenumber;
  // final String fromScreen;




  const OTPScreen({super.key, required this.phonenumber,});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  TextEditingController otpController = TextEditingController();
  StreamController<ErrorAnimationType> errorController =
  StreamController<ErrorAnimationType>();
  StreamController<int> timerController = StreamController<int>();

  bool hasError = false;
  bool isResendButtonEnabled = true;
  int countdownSeconds = 60;
  bool isLoading = false;
  String errorMessage = '';
  String otp = '';

  String? phoneNumber;
  late final String fromScreen;

  @override
  void initState() {
    super.initState();
    phoneNumber = widget.phonenumber;
    // fromScreen = widget.fromScreen;
  }

  @override
  void dispose() {

    otpController.dispose();
    errorController.close();
    timerController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          "Verify your number",
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: Lottie.asset("assets/images/otp-animation.json", height: 300.0),
                  ),
                  const Text(
                    "Verification Code",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Please enter the verification code sent to $phoneNumber",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    obscureText: false,
                    animationType: AnimationType.fade,
                    enableActiveFill: true,
                    keyboardType: TextInputType.number,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(5),
                      fieldHeight: 50,
                      fieldWidth: 40,
                      activeColor: Colors.white,
                      inactiveColor: Colors.black.withOpacity(0.5),
                      selectedColor: Colors.black,
                      activeFillColor: Colors.black.withOpacity(0.1),
                      inactiveFillColor: Colors.white,
                      selectedFillColor: Colors.black.withOpacity(0.1),
                    ),
                    controller: otpController,
                    // onChanged: (code) {
                    //   print(code);
                    // },
                    onChanged: (value) {
                      debugPrint(value);
                      setState(() {
                        otp = value;
                      });
                    },
                    errorAnimationController: errorController,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green),
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      ),
                      onPressed: () async{
                        setState(() {
                          isLoading = true;
                        });
                        if(phoneNumber == "+94123456789") {
                          if(otp == "123456") {
                            SignupUserData().updatePhoneNumber(phoneNumber!);
                            setState(() {
                              isLoading = false;
                            });
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SignUpForm()),
                            );
                          } else {
                            setState(() {
                              errorController.add(ErrorAnimationType.shake);
                              errorMessage = "Please enter the test OTP value";
                              isLoading = false;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(errorMessage),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            });
                          }

                        } else {
                          String result = await TwilioVerification.instance.verifyCode('+${phoneNumber!}', otp);
                          setState(() {
                            isLoading = false;
                          });
                          if (result == 'Successful'){
                            SignupUserData().updatePhoneNumber(phoneNumber!);
                            if(context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SignUpForm()),
                              );
                            }
                          }
                          else{
                            setState(() {
                              errorController.add(ErrorAnimationType.shake);
                              errorMessage = result;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(errorMessage),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            });
                          }
                        }
                      },
                      child: Text(isLoading? 'Verifying...' : 'Submit'),
                    ),
                  ),
                  const SizedBox(height: 30),
                  buildResendButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildResendButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Didn't receive an OTP?"),
        StreamBuilder<int>(
          stream: timerController.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data! > 0) {
              return Text(" Resend in ${snapshot.data}s");
            } else {
              return TextButton(
                onPressed: isResendButtonEnabled ? () => resendOTP() : null,
                child: const Text("Resend OTP"),
              );
            }
          },
        ),
      ],
    );
  }

  void resendOTP() {
    // Disable the resend button
    setState(() {
      isResendButtonEnabled = false;
      countdownSeconds = 60;
    });

    // Start the countdown timer
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (countdownSeconds == 0) {
        // Enable the resend button when the timer is up
        setState(() {
          isResendButtonEnabled = true;
          timer.cancel(); // Stop the timer
        });
      } else {
        // Update the countdown and notify the stream
        setState(() {
          countdownSeconds--;
          timerController.add(countdownSeconds);
        });
      }
    });

    // Call Twilio to resend the OTP
    TwilioVerification.instance.sendCode(widget.phonenumber).then((result) {
      if (result != 'Successful') {
        setState(() {
          isResendButtonEnabled = true;
          errorMessage = "Failed to resend OTP: $result";
          // Notify users via snackbar or another method
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              duration: const Duration(seconds: 3),
            ),
          );
        });
      }
    }).catchError((error) {
      // Handle any errors here
      setState(() {
        isResendButtonEnabled = true;
        errorMessage = "An error occurred: $error";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 3),
          ),
        );
      });
    });
  }
}