import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool isRequired;
  final TextInputType? keyboardType;
  final String? Function(String?)? customValidator;
  final int? maxLines;
  final int? minLines;
  final Widget? suffixIcon;

  const CustomFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.isRequired = true,
    this.keyboardType,
    this.customValidator,
    this.maxLines = 1,
    this.minLines = 1,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400,
            maxHeight: 50, // Limita el ancho máximo
          ),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText:
                  isRequired
                      ? '$labelText*'.toLowerCase()
                      : labelText.toLowerCase(),
              hintText: hintText,
              border: const OutlineInputBorder(),
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 10.0,
              ),
              isDense: true,
            ),
            keyboardType: keyboardType,
            maxLines: maxLines,
            minLines: minLines,
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
      ),
    );
  }
}
