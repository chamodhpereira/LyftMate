import 'package:flutter/material.dart';
import 'package:lyft_mate/constants/sizes.dart';
import 'package:lyft_mate/screens/signup/signup_dob_page.dart';
import 'package:lyft_mate/screens/signup/signup_email_page.dart';
import 'package:lyft_mate/screens/signup/signup_name_page.dart';
import 'package:lyft_mate/screens/signup/signup_password_page.dart';
import 'package:lyft_mate/screens/signup/signup_title_page.dart';
import 'package:lyft_mate/widgets/custom_bottom_buttom.dart';
import 'package:lyft_mate/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../services/authentication_service.dart';
// import 'package:lyft_mate/src/screens/login_screen.dart';
// import 'package:lyft_mate/src/screens/welcome_screen.dart';

// enum NameTitle { Mr, Mrs }

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  double _progress = 0;
  int currentPage = 0;
  DateTime? dob;
  NameTitle? character;


  final PageController _progressController = PageController(initialPage: 0);
  TextEditingController firstNameController = TextEditingController();
  TextEditingController secondNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController reEnterPasswordController = TextEditingController();

  @override
  void initState() {
    _progress = 1 / 5;
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
        return passwordController.text.isNotEmpty &&
            reEnterPasswordController.text.isNotEmpty;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {}, icon: const Icon(Icons.arrow_back_ios)),
        title: const Text(
          "Finish signing up",
          style: kBoldTextStyle,
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                child: Text("Step ${currentPage + 1} of 5"),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                child: LinearProgressIndicator(
                  minHeight: 5.0,
                  value: _progress,
                  color: Colors.green,
                  backgroundColor: Colors.grey[300],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _progressController,
                  // physics: NeverScrollableScrollPhysics(),
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
                        controllerTwo: secondNameController),
                    SignupEmailPage(
                        label: "What's your email",
                        controller: emailController),
                    SignupDOBPage(),
                    SignupTitlePage(),
                    SignupPasswordPage(
                        labelOne: "Enter password",
                        labelTwo: "Re-enter password",
                        controllerOne: passwordController,
                        controllerTwo: reEnterPasswordController),
                    // _passwordPage("Enter password", "Re-enter password",
                    //     passwordController, reEnterPasswordController),
                    // _buildPage("Page 3 Content"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 18.0, right: 18.0, bottom: 18.0),
        child: SizedBox(
          width: double.infinity,
          height: 50.0,
          child: currentPage == 4
              ? CustomBottomButton(
                  text: "Signup",
                  onPressed: () {
                    print('FirstName: ${context.read<UserM>().firstName}');
                    print('LastName: ${context.read<UserM>().lastName}');
                    print('Date of Birth: ${context.read<UserM>().selectedDate}');
                    print('Selected Title: ${context.read<UserM>().selectedTitle}');
                    print('USER EMAIL: ${context.read<UserM>().email}');
                    print('Send Promos: ${context.read<UserM>().sendPromos}');
                    print("PASssSSword: ${passwordController.text}");
                    print("userrrr: ${context.read<UserM>()}");
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => LoginScreen(),
                    //   ),
                    // );
                    String? passwordError = validatePassword();
                    if (passwordError != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(passwordError),
                        ),
                      );
                      return;
                    } else {
                      print("${emailController.text}, ${passwordController.text}");
                      authService.signUpWithEmailAndPassword(emailController.text, passwordController.text);
                    }

                  },
                )
              : CustomBottomButton(
                  text: "Proceed",
                  onPressed: () {
                    _progressController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );

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
    );
  }
}
