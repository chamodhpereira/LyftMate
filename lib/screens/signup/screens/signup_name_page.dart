import 'package:flutter/material.dart';
import 'package:lyft_mate/widgets/custom_text_field.dart';
import '../../../models/signup_user.dart';

class SignupNamePage extends StatelessWidget {
  final String labelOne;
  final String labelTwo;
  final TextEditingController controllerOne;
  final TextEditingController controllerTwo;

  const SignupNamePage({
    Key? key,
    required this.labelOne,
    required this.labelTwo,
    required this.controllerOne,
    required this.controllerTwo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SignupUserData userData = SignupUserData(); // Access the singleton instance of SignupUserData

    return Container(
      padding: const EdgeInsets.only(bottom: 40.0, left: 40.0, right: 40.0, top: 80.0),
      child: Column(
        children: [
          const Text(
            "What's your name",
            style: TextStyle(fontSize: 20.0),
          ),
          CustomTextField(
            label: labelOne,
            controller: controllerOne,
            onChanged: (value) => userData.updateFirstName(value), // Update first name in SignupUserData
          ),
          CustomTextField(
            label: labelTwo,
            controller: controllerTwo,
            onChanged: (value) => userData.updateLastName(value), // Update last name in SignupUserData
          ),
          const SizedBox(height: 20.0),
          const Text("Enter the same name as your government ID"),
        ],
      ),
    );
  }
}
