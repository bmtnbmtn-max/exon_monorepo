import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:
          width ??
          double
              .infinity, // Width එකක් දුන්නොත් ඒක ගන්නවා, නැත්නම් Full Width ගන්නවා
      height: 50, // Button එකේ උස
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          // backgroundColor: color ?? Colors.blueAccent, // Default පාට නිල්
          // foregroundColor: Colors.white, // අකුරු වල පාට
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              10,
            ), // TextField එකේ වගේම වටකුරු ගතිය
          ),
          elevation: 2,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}
