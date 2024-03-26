import 'package:flutter/material.dart';
import 'package:lyft_mate/widgets/custom_text_field.dart'; // Import the CustomTextField widget
import 'package:provider/provider.dart';

import '../../models/user.dart';

class SignupEmailPage extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const SignupEmailPage({
    Key? key,
    required this.label,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 40.0, left: 40.0, right: 40.0, top: 80.0),
      child: Column(
        children: [
          const Text(
            "What's your email",
            style: TextStyle(fontSize: 20.0),
          ),
          CustomTextField(
            label: label,
            controller: controller,
            onChanged: (value) {
              Provider.of<UserM>(context, listen: false).updateEmail(value);
            },
          ),
          const SizedBox(height: 20.0),
          Consumer<UserM>(
            builder: (context, user, _) {
              return Row(
                children: [
                  Checkbox(
                    value: user.sendPromos,
                    onChanged: (value) {
                      user.updateSendPromos(value ?? false);
                    },
                  ),
                  const Expanded(
                    child: Text(
                      "Send trip details, news, receipts, and promotions",
                      style: TextStyle(fontSize: 13.0),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
