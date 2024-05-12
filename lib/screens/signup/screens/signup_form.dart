import 'package:flutter/material.dart';
import 'package:lyft_mate/constants/sizes.dart';
import 'package:lyft_mate/models/signup_user.dart';
import 'package:lyft_mate/screens/login/login_screen.dart';
import 'package:lyft_mate/screens/signup/screens/signup_dob_page.dart';
import 'package:lyft_mate/screens/signup/screens/signup_email_page.dart';
import 'package:lyft_mate/screens/signup/screens/signup_emergency_contacts_page.dart';
import 'package:lyft_mate/screens/signup/screens/signup_password_page.dart';
import 'package:lyft_mate/screens/signup/screens/signup_name_page.dart';
import 'package:lyft_mate/screens/signup/screens/signup_title_page.dart';
import 'package:lyft_mate/widgets/custom_bottom_buttom.dart';

import '../../../services/authentication/authentication_service.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  double _progress = 0;
  int currentPage = 0;
  DateTime? dob;
  Gender? character;
  bool _signingUp = false;

  final PageController _progressController = PageController(initialPage: 0);
  TextEditingController firstNameController = TextEditingController();
  TextEditingController secondNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController reEnterPasswordController =
      TextEditingController();
  final TextEditingController emergencyContactNameController =
      TextEditingController();
  final TextEditingController emergencyContactPhoneNumberController =
      TextEditingController();

  @override
  void initState() {
    _progress = 1 / 6;
    super.initState();
  }

  AuthenticationService authService = AuthenticationService();

  @override
  void dispose() {
    _progressController.dispose();
    firstNameController.dispose();
    secondNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    reEnterPasswordController.dispose();
    emergencyContactNameController.dispose();
    emergencyContactPhoneNumberController.dispose();

    super.dispose();
  }

  String? validatePassword() {
    if (passwordController.text != reEnterPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  bool areFieldsFilledForPage(int page) {
    switch (page) {
      case 0:
        return firstNameController.text.isNotEmpty &&
            secondNameController.text.isNotEmpty;
      case 1:
        return emailController.text.isNotEmpty;
      case 2:
        return dob != null;
      case 3:
        return character != null;
      case 4:
        return emergencyContactNameController.text.isNotEmpty &&
            emergencyContactPhoneNumberController.text.isNotEmpty;
      case 5:
        return passwordController.text.isNotEmpty &&
            reEnterPasswordController.text.isNotEmpty;
      default:
        return false;
    }
  }

  // Update method to store selected gender
  void updateSelectedGender(Gender? gender) {
    setState(() {
      character = gender;
    });
  }

  // Update method to store selected date of birth
  void updateSelectedDOB(DateTime? dob) {
    setState(() {
      this.dob = dob;
      debugPrint("Date of Birth: ${this.dob}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            _signingUp ? Colors.black.withOpacity(0.5) : Colors.green,
        leading: IconButton(
          onPressed: () {
            if (_progressController.page == 0) {
              // If the user is on the first page, navigate to the previous screen
              Navigator.pop(context);
            } else {
              // Otherwise, go to the previous page
              if (_progressController.hasClients) {
                // Check if the controller has clients
                _progressController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            }
          },
          icon: Icon(
            Icons.arrow_back,
            color: _signingUp ? Colors.black.withOpacity(0.5) : Colors.white,
          ),
        ),
        title: Text(
          "Finish signing up",
          style: _signingUp
              ? TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.5),
                )
              : null,
        ),
        // centerTitle: true,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            if (_signingUp)
              Container(
                color: Colors.black.withOpacity(0.5),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                    child: Text("Step ${currentPage + 1} of 6"),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                    child: LinearProgressIndicator(
                      minHeight: 5.0,
                      value: _progress,
                      color: _signingUp
                          ? Colors.black.withOpacity(0.5)
                          : Colors.green,
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        PageView(
                          controller: _progressController,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (int page) {
                            setState(() {
                              currentPage = page;
                              _progress = (currentPage + 1) /
                                  5; // Update the progress based on the current page
                            });
                          },
                          children: [
                            SignupNamePage(
                              labelOne: "What's your first name",
                              labelTwo: "What's your last name",
                              controllerOne: firstNameController,
                              controllerTwo: secondNameController,
                            ),
                            SignupEmailPage(
                                label: "What's your email",
                                controller: emailController),
                            SignupDOBPage(
                              // Pass method to update selected dob
                              updateSelectedDOB: updateSelectedDOB,
                            ),
                            SignupGenderPage(
                              updateSelectedGender: updateSelectedGender,
                            ),
                            SignupEmergencyContactsPage(
                                labelOne: "Emergency Contact Name",
                                labelTwo: "Emergency Contact Phone Number",
                                controllerOne: emergencyContactNameController,
                                controllerTwo:
                                    emergencyContactPhoneNumberController),
                            SignupPasswordPage(
                                labelOne: "Enter password",
                                labelTwo: "Re-enter password",
                                controllerOne: passwordController,
                                controllerTwo: reEnterPasswordController),
                          ],
                        ),
                        // Circular progress indicator
                        if (_signingUp)
                          const Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.green),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Stack(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 18.0, right: 18.0, bottom: 18.0),
            child: SizedBox(
              width: double.infinity,
              height: 50.0,
              child: currentPage == 5
                  ? CustomBottomButton(
                      text: "Signup",
                      onPressed: () async {
                        setState(() {
                          _signingUp = true;
                        });

                        SignupUserData userData = SignupUserData();
                        debugPrint('First Name: ${userData.firstName}');
                        debugPrint('Last Name: ${userData.lastName}');
                        debugPrint('Email: ${userData.email}');
                        debugPrint('Date of Birth: ${userData.dob}');
                        debugPrint('Title: ${userData.selectedGender}');
                        debugPrint(
                            'Emergency Contacts: ${userData.emergencyContactPhoneNumber} ${userData.emergencyContactName}');

                        String? passwordError = validatePassword();
                        if (passwordError != null) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(passwordError),
                              ),
                            );
                            setState(() {
                              debugPrint("Password error setState Triggered");
                              _signingUp = false;
                            });
                          }

                          return;
                        } else {
                          debugPrint(
                              "${emailController.text}, ${passwordController.text}");

                          late String? signUpError;
                          try {
                            // Call the signUpWithEmailAndPassword method
                            await authService.signUpWithEmailAndPassword(
                              emailController.text,
                              passwordController.text,
                            );

                            // If signUpWithEmailAndPassword completes without throwing an error, it means sign-up was successful
                            // Set state and navigate to the login screen
                            setState(() {
                              _signingUp = false;
                            });
                            if (context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            }
                          } catch (e) {
                            // Handle errors
                            if (e is AuthException) {
                              signUpError = e.message;
                            } else {
                              signUpError = 'An unexpected error occurred';
                            }

                            if(context.mounted) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Sign-Up Failed"),
                                    content: Text(
                                        "An error occurred during signup: ${signUpError.toString()}"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          SignupUserData().reset();
                                          Navigator.pop(
                                              context); // Close the dialog

                                          setState(() {
                                            _signingUp = false;
                                          });
                                        },
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                            debugPrint("Error in signup: $signUpError");
                          }
                        }
                      },
                    )
                  : CustomBottomButton(
                      text: "Proceed",
                      onPressed: () {

                        if (areFieldsFilledForPage(currentPage)) {
                          _progressController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Please fill in all the fields on this page."),
                              ),
                            );
                          }
                        }
                      },
                    ),
            ),
          ),
          // Container for fading effect
          if (_signingUp)
            Positioned.fill(
              child: Container(
                color:
                    Colors.black.withOpacity(0.5), // Adjust opacity as needed
              ),
            ),
        ],
      ),
    );
  }
}
