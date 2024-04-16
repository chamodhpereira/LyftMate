import 'package:flutter/material.dart';
import 'package:lyft_mate/widgets/custom_text_field.dart';
import '../../../models/signup_user.dart';

class SignupEmergencyContactsPage extends StatelessWidget {
  final String labelOne;
  final String labelTwo;
  final TextEditingController controllerOne;
  final TextEditingController controllerTwo;

  const SignupEmergencyContactsPage({
    Key? key,
    required this.labelOne,
    required this.labelTwo,
    required this.controllerOne,
    required this.controllerTwo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SignupUserData userData = SignupUserData(); // Access the singleton instance of SignupUserData

    return Container(
      padding: const EdgeInsets.only(bottom: 40.0, left: 40.0, right: 40.0, top: 80.0),
      child: Column(
        children: [
          const Text(
            "Emergency Contact",
            style: TextStyle(fontSize: 20.0),
          ),
          SizedBox(height: 20,),
          CustomTextField(
            label: labelOne,
            controller: controllerOne,
            onChanged: (value) => userData.updateEmergencyContactName(value),
          ),
          CustomTextField(
            label: labelTwo,
            controller: controllerTwo,
            onChanged: (value) => userData.updateEmergencyContactPhoneNumber(value), // Update last name in SignupUserData
          ),
          const SizedBox(height: 20.0),
          const Text(
            "Adding an emergency contact ensures quick access to help when needed. Please provide the contact's details accurately.",
            // style: TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}

// class AddEmergencyContactScreen extends StatefulWidget {
//   @override
//   _AddEmergencyContactScreenState createState() =>
//       _AddEmergencyContactScreenState();
// }
//
// class _AddEmergencyContactScreenState
//     extends State<AddEmergencyContactScreen> {
//   TextEditingController _nameController = TextEditingController();
//   TextEditingController _phoneNumberController = TextEditingController();
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneNumberController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add Emergency Contact'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: InputDecoration(labelText: 'Name'),
//             ),
//             SizedBox(height: 20),
//             TextField(
//               controller: _phoneNumberController,
//               decoration: InputDecoration(labelText: 'Phone Number'),
//               keyboardType: TextInputType.phone,
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 _addEmergencyContact();
//               },
//               child: Text('Add Contact'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _addEmergencyContact() {
//     String name = _nameController.text.trim();
//     String phoneNumber = _phoneNumberController.text.trim();
//
//     // Check if both fields are filled
//     if (name.isNotEmpty && phoneNumber.isNotEmpty) {
//       // Call method to add the emergency contact to user data
//       SignupUserData().addEmergencyContact(name, phoneNumber);
//
//       // Navigate back
//       Navigator.pop(context);
//     } else {
//       // Show error message if any field is empty
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Please fill out all fields.'),
//         ),
//       );
//     }
//   }
// }