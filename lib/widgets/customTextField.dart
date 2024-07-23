import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController textEditingController;
  final TextInputType? keyboardType;
  final bool isobsecureText;
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isValidate;
  final bool? enable;
  final String? Function(String?) validator;

  const CustomTextField({
    super.key,
    required this.textEditingController,
    this.keyboardType,
    required this.isobsecureText,
    required this.hintText,
    this.prefixIcon,
    this.enable,
    this.suffixIcon,
    required this.isValidate,
    required this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: TextFormField(
        controller: widget.textEditingController,
        obscureText: widget.isobsecureText,
        keyboardType: widget.keyboardType,
        enabled: widget.enable,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          contentPadding: const EdgeInsets.only(top: 12, right: 20),
          constraints: BoxConstraints(
            maxHeight: height * 0.065,
            maxWidth: width * 0.4,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        validator: widget.isValidate ? widget.validator : null,
      ),
    );
  }
}
