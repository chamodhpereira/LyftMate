import 'package:flutter/material.dart';

import 'login_form.dart';


class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent resizing when keyboard appears
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView( // Wrap with SingleChildScrollView
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Hero(
                    tag: "logo",
                    child: Image.asset(
                      "assets/images/carpool-image-4.jpg",
                      height: 200.0,
                    ),
                  ),
                  const LoginForm(),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {},
                    child: Text.rich(
                      TextSpan(
                        text: "Don't have an Account? ",
                        style: Theme.of(context).textTheme.bodyText1,
                        children: const [
                          TextSpan(
                            text: "Signup",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
