import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onPressed;
  final FormFieldValidator<String>? validator; // Added validator parameter

  const PasswordField({
    Key? key,
    required this.label,
    required this.controller,
    required this.obscureText,
    required this.onPressed,
    this.validator, // Initialize the validator parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: onPressed,
        ),
      ),
      controller: controller,
      validator: validator, // Use the validator parameter
    );
  }
}
