import 'package:flutter/material.dart';

class MultilineTextField extends StatefulWidget {
  final TextEditingController controller;

  MultilineTextField({super.key, required this.controller});

  @override
  _MultilineTextFieldState createState() => _MultilineTextFieldState();
}

class _MultilineTextFieldState extends State<MultilineTextField> {
  List<String> items = [];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: widget.controller,
            keyboardType: TextInputType.multiline,
            maxLines: null, // Allow unlimited lines
            onChanged: (value) {
              setState(() {
                items = value.split('\n');
              });
            },
            decoration: InputDecoration(
              hintText: 'ادخل العهده',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Colors.grey), // Add border color
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              // Adjust content padding as needed
            ),
          ),
          const SizedBox(height: 8), // Spacer between TextField and Items
          const Text(
            'العهد:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8), // Spacer between the header and output
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              items.length,
              (index) => Text(
                '${index + 1}- ${items[index]}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }
}
