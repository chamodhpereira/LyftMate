import 'package:flutter/material.dart';
import 'package:lyft_mate/constants/sizes.dart';

class CustomBottomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomBottomButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: kBoldButtonTextStyle,
      ),
    );
  }
}
