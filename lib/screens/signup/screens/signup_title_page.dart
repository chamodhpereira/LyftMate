import 'package:flutter/material.dart';
import '../../../models/signup_user.dart';

class SignupGenderPage extends StatefulWidget {
  final void Function(Gender?) updateSelectedGender; // Callback function
  const SignupGenderPage({Key? key, required this.updateSelectedGender}) : super(key: key);

  @override
  _SignupGenderPageState createState() => _SignupGenderPageState();
}

class _SignupGenderPageState extends State<SignupGenderPage> {
  Gender? _selectedGender;
  SignupUserData userData = SignupUserData(); // Initialize SignupUserData here

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 40.0, left: 20.0, right: 20.0, top: 80.0),
      child: Column(
        children: [
          const Text(
            "How would you like to be addressed ?",
            style: TextStyle(fontSize: 18.0),
          ),
          ListTile(
            title: const Text('Mr'),
            leading: Radio<Gender>(
              value: Gender.male,
              groupValue: _selectedGender,
              onChanged: (Gender? value) {
                setState(() {
                  _selectedGender = value;
                  userData.updateGender(value!);
                  widget.updateSelectedGender(value);// Pass enum value directly
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Ms/Mrs'),
            leading: Radio<Gender>(
              value: Gender.female,
              groupValue: _selectedGender,
              onChanged: (Gender? value) {
                setState(() {
                  _selectedGender = value;
                  userData.updateGender(value!);
                  widget.updateSelectedGender(value);// Pass enum value directly
                });
              },
            ),
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }
}
