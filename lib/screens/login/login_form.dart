import 'package:flutter/material.dart';
import 'package:lyft_mate/constants/sizes.dart';
import 'package:lyft_mate/home.dart';
import 'package:lyft_mate/screens/chat/user_list.dart';
import 'package:lyft_mate/screens/welcome/welcome_screen.dart';
import 'package:lyft_mate/userprofile_screen.dart';

import '../../constants/colors.dart';
import '../../services/authentication_service.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  AuthenticationService authService = AuthenticationService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 50),
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person_outline_outlined),
                labelText: "Username or Email",
                hintText: "Enter username or email",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your username or email';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.key_off_outlined),
                labelText: "Password",
                hintText: "Enter password",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
              onChanged: (newValue) {
                print(newValue);
              },
            ),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text("Forgot Password?"),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {

                  if (_formKey.currentState!.validate()) {
                    // Call the sign in method from AuthenticationService
                    // bool success = await authService.signInWithEmailAndPassword(_emailController.text, _passwordController.text);
                    bool success = await authService.signInWithEmailAndPassword(context, _emailController.text, _passwordController.text);
                    if (success) {
                      // Navigate to the next screen only if login is successful
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>UserList()),
                            // (route) => false,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sign-in failed. Please check your credentials and try again.'),
                          duration: Duration(seconds: 3), // Adjust the duration as needed
                        ),
                      );
                    }
                  }
                  // if (_formKey.currentState!.validate()) {
                    // Call the sign in method from AuthenticationService
                    // await _authService.signInWithEmailAndPassword(_emailController.text, _passwordController.text);
                    // After successful login, you can navigate to the next screen
                    // Navigator.pushAndRemoveUntil(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => NewHomeScreen()),
                    //   (route) => false,
                    // );
                  // }
                },
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(),
                  foregroundColor: kWhiteColor,
                  backgroundColor: Colors.green,
                  side: const BorderSide(color: kSecondaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                ),
                child: Text(
                  "Login".toUpperCase(),
                  style: kBoldTextStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
