import 'package:flutter/material.dart';

class DatePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onChanged;

  const DatePicker({
    Key? key,
    required this.selectedDate,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );

        if (pickedDate != null && pickedDate != selectedDate) {
          onChanged(pickedDate);
        }
      },
      decoration: const InputDecoration(
        labelText: 'Date of Birth',
        suffixIcon: Icon(Icons.calendar_today),
      ),
      controller: TextEditingController(
        text: selectedDate != null
            ? '${selectedDate!.toLocal()}'.split(' ')[0]
            : '',
      ),
    );
  }
}
