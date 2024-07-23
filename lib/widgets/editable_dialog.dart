import 'package:flutter/material.dart';
import 'package:hr_app/components/colors.dart';
import 'package:hr_app/managers/firebaseHelper.dart';

class PromoteEmployee extends StatefulWidget {
  final String salary;
  final String homeAlt;
  final String resAlt;
  final String transAlt;
  final String job;
  final String location;
  final dynamic doc;

  const PromoteEmployee({
    super.key,
    required this.salary,
    required this.homeAlt,
    required this.resAlt,
    required this.transAlt,
    required this.doc,
    required this.job,
    required this.location,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PromoteEmployeeState createState() => _PromoteEmployeeState();
}

class _PromoteEmployeeState extends State<PromoteEmployee> {
  late TextEditingController _controller1;
  late TextEditingController _controller2;
  late TextEditingController _controller3;
  late TextEditingController _controller4;
  late TextEditingController _controller5;
  late TextEditingController _controller6;
  final FirestoreManager _firestoreManager = FirestoreManager();

  // Define enable states for each text field
  Map<TextEditingController, bool> enableStates = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers with initial text
    _controller1 = TextEditingController(text: widget.salary);
    _controller2 = TextEditingController(text: widget.homeAlt);
    _controller3 = TextEditingController(text: widget.transAlt);
    _controller4 = TextEditingController(text: widget.resAlt);
    _controller5 = TextEditingController(text: widget.job);
    _controller6 = TextEditingController(text: widget.location);

    // Initialize enable states for each text field
    enableStates = {
      _controller1: false,
      _controller2: false,
      _controller3: false,
      _controller4: false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'ترقيه راتب الموظف',
        style: TextStyle(
          color: primaryColor,
        ),
      ),
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildEditableField("الوظيفه", _controller5),
            _buildEditableField("الموقع", _controller6),
            _buildEditableField("الراتب الاساسي", _controller1),
            _buildEditableField("بدل السكن", _controller2),
            _buildEditableField("بدل المواصلات", _controller3),
            _buildEditableField("بدل المسؤليه", _controller4),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            if (_controller1.text.isEmpty) {
              _controller1.text = "0";
            }
            if (_controller2.text.isEmpty) {
              _controller2.text = "0";
            }
            if (_controller3.text.isEmpty) {
              _controller3.text = "0";
            }
            if (_controller4.text.isEmpty) {
              _controller4.text = "0";
            }

            _firestoreManager.updateDocument("الموظفين", widget.doc['name'], {
              "mainSalary": _controller1.text,
              "homeAltSalary": _controller2.text,
              "transportAlt": _controller3.text,
              "responsabilityAlt": _controller4.text,
              "totalSalary": (int.parse(_controller1.text) +
                      int.parse(_controller2.text) +
                      int.parse(_controller3.text) +
                      int.parse(_controller4.text))
                  .toString(),
              "rate": widget.doc['rate']
            });
            Navigator.pop(context);
          },
          child: const Text('ترقية الموظف'),
        ),
        TextButton(
          onPressed: () {
            // Close the dialog without saving
            Navigator.pop(context);
          },
          child: const Text('غلق'),
        ),
      ],
    );
  }

  Widget _buildEditableField(
    String header,
    TextEditingController controller,
  ) {
    return Row(
      children: [
        Text(header), // Header
        Expanded(
          child: TextField(
            controller: controller,
            enabled: enableStates[controller] ?? false,
            decoration: InputDecoration(
              hintText: controller.text,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            // Enable editing for the corresponding text field
            setState(() {
              enableStates[controller] = true;
            });
          },
        ),
      ],
    );
  }
}
