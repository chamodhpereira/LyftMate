import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';

// enum NameTitle { Mr, Mrs }

class SignupTitlePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 40.0, left: 20.0, right: 20.0, top: 80.0),
      child: Consumer<User>(
        builder: (context, user, _) {
          return Column(
            children: [
              const Text(
                "How would you like to be addressed ?",
                style: TextStyle(fontSize: 18.0),
              ),
              ListTile(
                title: const Text('Mr'),
                leading: Radio<NameTitle>(
                  value: NameTitle.Mr,
                  groupValue: user.selectedTitle,
                  onChanged: (NameTitle? value) {
                    user.updateTitle(value);
                  },
                ),
              ),
              ListTile(
                title: const Text('Ms/Mrs'),
                leading: Radio<NameTitle>(
                  value: NameTitle.Mrs,
                  groupValue: user.selectedTitle,
                  onChanged: (NameTitle? value) {
                    user.updateTitle(value);
                  },
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          );
        },
      ),
    );
  }
}
