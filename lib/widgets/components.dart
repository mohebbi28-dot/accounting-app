import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('انصراف'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: const Text('تأیید'),
        ),
      ],
    );
  }
}

class NumberTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  const NumberTextField({
    super.key,
    required this.controller,
    this.hintText = 'مبلغ را وارد کنید',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) {
        final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
        if (cleanValue != value) {
          controller.text = cleanValue;
          controller.selection =
              TextSelection.collapsed(offset: cleanValue.length);
        }
        onChanged?.call(cleanValue);
      },
    );
  }
}
