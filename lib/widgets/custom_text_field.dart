import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  // final String? Function(String?)? validator; // Add validator property

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.onChanged,
    // this.validator, // Add validator to constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField( // Use TextFormField instead of TextField
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
      ),
      // validator: validator, // Pass validator to TextFormField
    );
  }
}
