import 'package:flutter/material.dart';
import 'package:lyft_mate/widgets/custom_date_picker.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';

// class SignupDOBPage extends StatelessWidget {
//   DateTime? selectedDate;
//
//   @override
//   Widget build(BuildContext context) {
//     User user = Provider.of<User>(context);
//
//     return Container(
//       padding: const EdgeInsets.only(bottom: 40.0, left: 40.0, right: 40.0, top: 80.0),
//       child: Column(
//         children: [
//           const Text("What is your date of birth?", style: TextStyle(fontSize: 20.0)),
//           DatePicker(
//             selectedDate: selectedDate,
//             onChanged: (DateTime? date) {
//               user.updateDob(date);
//               // setState(() {
//               //   selectedDate = date;
//               // });
//             },
//           ),
//           const SizedBox(height: 20.0),
//           const Text("Enter the same DOB as your government ID")
//         ],
//       ),
//     );
//   }
// }
class SignupDOBPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<User>(
      builder: (context, user, _) {
        return Container(
          padding: const EdgeInsets.only(bottom: 40.0, left: 40.0, right: 40.0, top: 80.0),
          child: Column(
            children: [
              const Text("What is your date of birth?", style: TextStyle(fontSize: 20.0)),
              DatePicker(
                selectedDate: user.selectedDate,
                onChanged: (DateTime? date) {
                  user.updateDob(date);
                },
              ),
              const SizedBox(height: 20.0),
              const Text("Enter the same DOB as your government ID")
            ],
          ),
        );
      },
    );
  }
}


