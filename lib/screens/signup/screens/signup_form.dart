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
import 'package:lyft_mate/screens/welcome/welcome_screen.dart';
import 'package:lyft_mate/widgets/custom_bottom_buttom.dart';

import '../../../services/authentication_service.dart';
import '../../home/ui/home.dart';

// import 'package:lyft_mate/src/screens/login_screen.dart';
// import 'package:lyft_mate/src/screens/welcome_screen.dart';

// enum Gender { Mr, Mrs }

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

  final PageController _progressController = PageController(initialPage: 0);
  TextEditingController firstNameController = TextEditingController();
  TextEditingController secondNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController reEnterPasswordController = TextEditingController();
  TextEditingController emergencyContactNameController =
      TextEditingController();
  TextEditingController emergencyContactPhoneNumberController =
      TextEditingController();

  @override
  void initState() {
    _progress = 1 / 6;
    super.initState();
  }

  AuthenticationService authService = AuthenticationService();

  // late DatabaseService _databaseService;

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
    // Change parameter type to DateTime?
    setState(() {
      this.dob = dob; // Assign the parameter value to the instance variable
    });
  }

  bool _signingUp = false;

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
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            }
          },
          icon: Icon(
            Icons.arrow_back_ios,
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
              : kBoldTextStyle,
        ),
        centerTitle: true,
        // backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            if (_signingUp)
              Container(
                color:
                    Colors.black.withOpacity(0.5), // Adjust opacity as needed
              ),
            Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // if (_signingUp)
                  //   Container(
                  //     color: Colors.black.withOpacity(0.5), // Adjust opacity as needed
                  //   ),
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
                      //  backgroundColor: _signingUp ? Colors.black.withOpacity(0.5) : Colors.green,
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        PageView(
                          controller: _progressController,
                          physics: NeverScrollableScrollPhysics(),
                          // physics: ,
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
                            // Pass formKey here
                            SignupEmailPage(
                                label: "What's your email",
                                controller: emailController),
                            SignupDOBPage(
                              // Pass method to update selected dob
                              updateSelectedDOB: updateSelectedDOB,
                            ),
                            SignupGenderPage(
                              // Pass method to update selected gender
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
                            // _passwordPage("Enter password", "Re-enter password",
                            //     passwordController, reEnterPasswordController),
                            // _buildPage("Page 3 Content"),
                          ], // uper page
                        ),
                        // Circular progress indicator
                        if (_signingUp)
                          Center(
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
                        print('First Name: ${userData.firstName}');
                        print('Last Name: ${userData.lastName}');
                        print('Email: ${userData.email}');
                        print('Date of Birth: ${userData.dob}');
                        print('Title: ${userData.selectedGender}');
                        print(
                            'Emergency Contacts: ${userData.emergencyContactPhoneNumber} ${userData.emergencyContactName}');

                        String? passwordError = validatePassword();
                        if (passwordError != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(passwordError),
                            ),
                          );
                          return;
                        } else {
                          print(
                              "${emailController.text}, ${passwordController.text}");

                          // Retrieve the BuildContext
                          BuildContext currentContext = context;
                          // UserM newUser = UserM(
                          //   userID: '', // The ID will be assigned automatically after signup
                          //   email: emailController.text,
                          //   firstName: firstNameController.text,
                          //   lastName: secondNameController.text,
                          // );
                          // authService.signUpWithEmailAndPassword(emailController.text, passwordController.text);

                          // Future<bool> simulateDelayedSignUp() async {
                          //   // Delay for 3 seconds
                          //   await Future.delayed(Duration(seconds: 3));
                          //   return true; // Return true after the delay
                          // }

                          // bool signUpSuccess = await simulateDelayedSignUp();

                          //     bool signUpSuccess =
                          //         await authService.signUpWithEmailAndPassword(
                          //             emailController.text, passwordController.text);
                          //
                          //     // Check if sign-up was successful
                          //     if (signUpSuccess) {
                          //       setState(() {
                          //         _signingUp = false;
                          //       });
                          //       if (context.mounted) {
                          //         Navigator.pushReplacement(
                          //           context,
                          //           MaterialPageRoute(
                          //               builder: (context) =>
                          //                   LoginScreen()), // Replace HomePage() with your actual home page widget
                          //         );
                          //       }
                          //     } else {
                          //       // Handle sign-up failure (e.g., show error message)
                          //     }
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

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Sign-Up Failed"),
                                  content: Text(
                                      "An error occurred during sign-up: ${signUpError.toString()}"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        SignupUserData().reset();
                                        Navigator.pop(
                                            context); // Close the dialog
                                        // Navigator.pushReplacement(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) => WelcomeScreen(),
                                        //   ),
                                        // );
                                        setState(() {
                                          _signingUp = false;
                                        });
                                      },
                                      child: Text("OK"),
                                    ),
                                  ],
                                );
                              },
                            );

                            print(
                                "EERRRRRRRRRRRRRRRRRRRRRRRORRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRQQQQQQQQ: $signUpError");
                            // Show dialog or handle the error in another way
                          }

                          // late String? signUpError;
                          // // Call the signUpWithEmailAndPassword method
                          // signUpError = await authService.signUpWithEmailAndPassword(
                          //   emailController.text,
                          //   passwordController.text,
                          // );
                          //
                          // // Check if signUpError is not null, indicating an error occurred
                          // if (signUpError != null) {
                          //   // Handle the error by showing a dialog
                          //   showDialog(
                          //     context: context,
                          //     builder: (BuildContext context) {
                          //       return AlertDialog(
                          //         title: Text("Sign-Up Failed"),
                          //         content: Text(
                          //             "An error occurred during sign-up: ${signUpError.toString()}"),
                          //         actions: [
                          //           TextButton(
                          //             onPressed: () {
                          //               Navigator.pop(context); // Close the dialog
                          //               setState(() {
                          //                 _signingUp = false;
                          //               });
                          //             },
                          //             child: Text("OK"),
                          //           ),
                          //         ],
                          //       );
                          //     },
                          //   );
                          // }

                          // // Check if sign-up was successful
                          // if (signUpError == null) {
                          //   setState(() {
                          //     _signingUp = false;
                          //   });
                          //   if (context.mounted) {
                          //     Navigator.pushReplacement(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) => LoginScreen(),
                          //       ),
                          //     );
                          //   }
                          // }
                          // } else {
                          //   // Handle sign-up failure (e.g., show error message)
                          //   showDialog(
                          //     context: context,
                          //     builder: (BuildContext context) {
                          //       return AlertDialog(
                          //         title: Text("Sign-Up Failed"),
                          //         content: Text("An unknown error occurred during sign-up."),
                          //         actions: [
                          //           TextButton(
                          //             onPressed: () {
                          //               Navigator.pop(context); // Close the dialog
                          //             },
                          //             child: Text("OK"),
                          //           ),
                          //         ],
                          //       );
                          //     },
                          //   );
                          // }
                        }
                      },
                    )
                  : CustomBottomButton(
                      text: "Proceed",
                      onPressed: () {
                        // _progressController.nextPage(
                        //   duration: Duration(milliseconds: 300),
                        //   curve: Curves.easeInOut,
                        // );

                        if (areFieldsFilledForPage(currentPage)) {
                          _progressController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Please fill in all the fields on this page."),
                            ),
                          );
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
