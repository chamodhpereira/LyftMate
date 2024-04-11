import 'package:flutter/material.dart';

import '../models/user_profile.dart';

class ChatTile extends StatelessWidget {
  final UserProfile
      userProfile; // require thi sin constructor // not the correct profile model
  final Function onTap;
  const ChatTile({super.key, required this.userProfile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onTap;
      },
      dense: false,
      leading: CircleAvatar(
        child: Icon(
          Icons.person,   // TODO: get user profile image as network image from model
          size: 30.0,
        ),
      ),
      title: Text(userProfile.firstName),
    );
  }
}
