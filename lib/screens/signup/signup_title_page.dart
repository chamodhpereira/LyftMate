import 'package:flutter/material.dart';

enum NameTitle { Mr, Mrs }

class SignupTitlePage extends StatefulWidget {
  @override
  _SignupTitlePageState createState() => _SignupTitlePageState();
}

class _SignupTitlePageState extends State<SignupTitlePage> {
  NameTitle? character;

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
            leading: Radio<NameTitle>(
              value: NameTitle.Mr,
              groupValue: character,
              onChanged: (NameTitle? value) {
                print("presseddd");
                setState(() {
                  character = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Ms/Mrs'),
            leading: Radio<NameTitle>(
              value: NameTitle.Mrs,
              groupValue: character,
              onChanged: (NameTitle? value) {
                setState(() {
                  character = value;
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
