import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';


class OTPScreen extends StatefulWidget {
  final String? phonenumber;
  final String fromScreen;

  const OTPScreen({super.key, this.phonenumber, required this.fromScreen});

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

  String? phoneNumber;
  late final String fromScreen;

  @override
  void initState() {
    super.initState();
    phoneNumber = widget.phonenumber ?? "+94123456789";
    fromScreen = widget.fromScreen;
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
          icon: const Icon(Icons.arrow_back_ios),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                onChanged: (code) {
                  print(code);
                },
                onCompleted: (value) {
                  if (value != "123456") {
                    errorController.add(ErrorAnimationType.shake);
                    setState(() {
                      hasError = true;
                    });
                  } else {
                    setState(() {
                      hasError = false;
                    });
                    if (!hasError) {
                      if (fromScreen == 'signup') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpName(), // Navigate to SignupScreen
                          ),
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(), // Navigate to HomeScreen
                          ),
                        );
                      }
                    }
                  }
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
                  ),
                  onPressed: () {
                    // Verify OTP or handle submission
                  },
                  child: const Text("Submit"),
                ),
              ),
              const SizedBox(height: 30),
              buildResendButton(),
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

  Future<void> verifyOTP(String enteredCode) async {
    // Verify OTP logic with Firebase
    // ... (same as in the previous example)
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
        });

        // Stop the timer
        timer.cancel();
      } else {
        // Update the countdown and notify the stream
        setState(() {
          countdownSeconds--;
          timerController.add(countdownSeconds);
        });
      }
    });

    // Call Firebase to resend OTP
    // ...
  }
}