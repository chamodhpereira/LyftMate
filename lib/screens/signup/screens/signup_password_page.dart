import 'package:flutter/material.dart';
import 'package:lyft_mate/widgets/custom_password_field.dart';

class SignupPasswordPage extends StatefulWidget {
  final String labelOne;
  final String labelTwo;
  final TextEditingController controllerOne;
  final TextEditingController controllerTwo;

  const SignupPasswordPage({
    Key? key,
    required this.labelOne,
    required this.labelTwo,
    required this.controllerOne,
    required this.controllerTwo,
  }) : super(key: key);

  @override
  _SignupPasswordPageState createState() => _SignupPasswordPageState();
}

class _SignupPasswordPageState extends State<SignupPasswordPage> {
  bool obscureTextOne = true;
  bool obscureTextTwo = true;

  void togglePasswordVisibilityOne() {
    setState(() {
      obscureTextOne = !obscureTextOne;
    });
  }

  void togglePasswordVisibilityTwo() {
    setState(() {
      obscureTextTwo = !obscureTextTwo;
    });
  }

  String? _validatePassword(String? value) {
    if (value != widget.controllerOne.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 40.0, left: 40.0, right: 40.0, top: 80.0),
          child: Column(
            children: [
              const Text(
                "Create your password",
                style: TextStyle(fontSize: 20.0),
              ),
              PasswordField(
                label: widget.labelOne,
                controller: widget.controllerOne,
                obscureText: obscureTextOne,
                onPressed: togglePasswordVisibilityOne,
              ),
              PasswordField(
                label: widget.labelTwo,
                controller: widget.controllerTwo,
                obscureText: obscureTextTwo,
                onPressed: togglePasswordVisibilityTwo,
                validator: _validatePassword,
              ),
              const SizedBox(height: 35.0),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "In order to protect your account, make sure your password:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    "- Includes a minimum of 8 characters",
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "- Contains at least one uppercase letter",
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "- Contains at least one lowercase letter",
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "- Includes at least one digit (0-9)",
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],

    );
  }
}
