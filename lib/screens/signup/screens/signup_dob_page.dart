import 'package:flutter/material.dart';
import 'package:lyft_mate/widgets/custom_date_picker.dart';
import 'package:provider/provider.dart';

import '../../../models/signup_user.dart';

class SignupDOBPage extends StatelessWidget {
  final void Function(DateTime?) updateSelectedDOB; // Callback function

  const SignupDOBPage({Key? key, required this.updateSelectedDOB}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SignupUserData userData = SignupUserData(); // Access the singleton instance of SignupUserData

    return Container(
      padding: const EdgeInsets.only(bottom: 40.0, left: 40.0, right: 40.0, top: 80.0),
      child: Column(
        children: [
          const Text("What is your date of birth?", style: TextStyle(fontSize: 20.0)),
          DatePicker(
            selectedDate: userData.dob, // Access the dob property from SignupUserData
            onChanged: (DateTime? date) {
              updateSelectedDOB(date); // Call the callback function with the new date
            },
          ),
          const SizedBox(height: 20.0),
          const Text("Enter the same DOB as your government ID")
        ],
      ),
    );
  }
}
