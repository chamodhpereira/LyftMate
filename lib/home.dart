import 'package:flutter/material.dart';
import 'package:lyft_mate/userprofile_screen.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserProfileScreen()),
            );
          },
          child: Text("Profile"),
        ),
      ),
    );
  }
}
