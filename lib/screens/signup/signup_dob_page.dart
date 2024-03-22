import 'package:flutter/material.dart';
import 'package:lyft_mate/widgets/custom_date_picker.dart';

class SignupDOBPage extends StatefulWidget {
  @override
  _SignupDOBPageState createState() => _SignupDOBPageState();
}

class _SignupDOBPageState extends State<SignupDOBPage> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 40.0, left: 40.0, right: 40.0, top: 80.0),
      child: Column(
        children: [
          const Text("What is your date of birth?", style: TextStyle(fontSize: 20.0)),
          DatePicker(
            selectedDate: selectedDate,
            onChanged: (DateTime? date) {
              setState(() {
                selectedDate = date;
              });
            },
          ),
          const SizedBox(height: 20.0),
          const Text("Enter the same DOB as your government ID")
        ],
      ),
    );
  }
}