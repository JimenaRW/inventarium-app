import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool isRequired;
  final TextInputType? keyboardType;
  final String? Function(String?)? customValidator;
  final int? maxLines;

  const CustomFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.isRequired = true,
    this.keyboardType,
    this.customValidator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: isRequired ? '$labelText*' : labelText,
            hintText: hintText,
            border: const OutlineInputBorder(),
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator:
              customValidator ??
              (value) {
                if (isRequired && (value == null || value.isEmpty)) {
                  return 'Por favor ingrese $labelText';
                }
                return null;
              },
        ),
      ),
    );
  }
}
