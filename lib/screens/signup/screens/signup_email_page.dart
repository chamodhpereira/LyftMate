import 'package:flutter/material.dart';
import 'package:lyft_mate/widgets/custom_text_field.dart'; // Import the CustomTextField widget
import '../../../models/signup_user.dart';

class SignupEmailPage extends StatefulWidget {
  final String label;
  final TextEditingController controller;

  const SignupEmailPage({
    Key? key,
    required this.label,
    required this.controller,
  }) : super(key: key);

  @override
  State<SignupEmailPage> createState() => _SignupEmailPageState();
}

class _SignupEmailPageState extends State<SignupEmailPage> {

  bool sendPromos = false;

  @override
  Widget build(BuildContext context) {
    SignupUserData userData = SignupUserData(); // Access the singleton instance of SignupUserData

    return Container(
      padding: const EdgeInsets.only(bottom: 40.0, left: 40.0, right: 40.0, top: 80.0),
      child: Column(
        children: [
          const Text(
            "What's your email",
            style: TextStyle(fontSize: 20.0),
          ),
          CustomTextField(
            label: widget.label,
            controller: widget.controller,
            onChanged: (value) {
              userData.updateEmail(value); // Update the email property in SignupUserData
            },
          ),
          const SizedBox(height: 20.0),
          Row(
            children: [
              Checkbox(
                value: sendPromos,
                onChanged: (value) {
                  setState(() {
                    sendPromos = value ?? false; // Update the state of the checkbox
                  });
                },
              ),
              const Expanded(
                child: Text(
                  "Send trip details, news, receipts, and promotions",
                  style: TextStyle(fontSize: 13.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
