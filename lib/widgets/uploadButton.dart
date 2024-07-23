import 'package:flutter/material.dart';

class UploadButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final Color buttonColor;
  final Color textColor;
  final double borderRadius;
  final double fontSize;

  const UploadButton({
    required this.buttonText,
    required this.onPressed,
    this.buttonColor = Colors.blue,
    this.textColor = Colors.white,
    this.borderRadius = 10,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        textStyle: TextStyle(color: textColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Text(
              buttonText,
              style: TextStyle(fontSize: fontSize, color: textColor),
            ),
            const SizedBox(
              width: 5,
            ),
            const Icon(
              Icons.upload_file,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}
