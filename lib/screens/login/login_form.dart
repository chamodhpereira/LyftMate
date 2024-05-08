import 'package:flutter/material.dart';
import 'package:lyft_mate/constants/sizes.dart';
import 'package:lyft_mate/screens/navigation/navigation_screen.dart';


import '../../constants/colors.dart';
import '../../services/authentication_service.dart';
import '../forgot_password/forgot_password_screen.dart';

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

  bool _isLoading = false; // Boolean to control loading indicator

@override
  void dispose() {
  _emailController.dispose();
  _passwordController.dispose();
    super.dispose();
  }

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
                labelText: "Email",
                hintText: "Enter email",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.key_outlined),
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
                debugPrint(newValue);
              },
            ),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return ForgotPasswordScreen();
                  }));
                },
                child: const Text("Forgot Password?"),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () async { // Disable button when loading
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _isLoading = true; // Set loading to true before starting authentication
                    });
                    // bool success = false;
                    bool success = await authService.signInWithEmailAndPassword(context, _emailController.text, _passwordController.text);

                    if (success) {

                      Navigator.pushNamedAndRemoveUntil(context, '/navigationScreen', (route) => false,);
                      setState(() {
                        _isLoading = false; // Set loading to false after authentication is done
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Login failed. Please check your credentials and try again.'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                      setState(() {
                        _isLoading = false; // Set loading to false after authentication is done
                      });

                    }
                  }
                },
                // style: ElevatedButton.styleFrom(
                //   foregroundColor: kWhiteColor,
                //   backgroundColor: Colors.green,
                //   side: const BorderSide(color: kSecondaryColor),
                // ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.green,) // Show loading indicator if _isLoading is true
                    : Text(
                  // "Login",
                  "Login".toUpperCase(),
                  // style: ,
                  // style: kBoldTextStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
