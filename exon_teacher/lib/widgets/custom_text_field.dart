import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final double bottomSpace; // පරතරය පාලනය කිරීමට අලුත් Variable එකක්
  final int? maxLength;
  final String? Function(String?)? validator;
  final bool enabled;
  final VoidCallback? onTap;
  final bool readOnly;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = '',
    this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.bottomSpace = 10.0, // Default එක විදිහට 10ක් දෙනවා
    this.maxLength,
    this.validator,
    this.enabled = true,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          maxLength: maxLength,
          validator: validator,
          enabled: enabled,
          onTap: onTap,
          readOnly: readOnly,
          inputFormatters: maxLength != null
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(maxLength),
                ]
              : null,
          decoration: InputDecoration(
            labelText: label,
            counterText: "",
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.deepOrangeAccent,
                width: 2,
              ),
            ),
          ),
        ),
        // මෙතනදී තමයි පරතරය ඇඩ් වෙන්නේ
        SizedBox(height: bottomSpace),
      ],
    );
  }
}
