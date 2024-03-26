import 'package:flutter/material.dart';
import 'package:lyft_mate/models/loggeduser.dart';
import 'package:lyft_mate/services/authentication_service.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';

class UserProfileScreen extends StatelessWidget {
  UserProfileScreen({Key? key});


  AuthenticationService authService = AuthenticationService();

  Widget build(BuildContext context) {

    final user = Provider.of<LoggedUser>(context);

    // Print the hash code of the user instance
    print('User instance hash code: ${user.hashCode}');

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text('UID: ${user.userID}'),
            Text('Email: ${user.email}'),
            ElevatedButton(
              onPressed: () async {
                await authService.signOut();
              },
              child: Text("signout"),
            ),
          ],
        ),
      ),
    );
  }
}
