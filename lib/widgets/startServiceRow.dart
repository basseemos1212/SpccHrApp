import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class CustomRow extends StatefulWidget {
  String date;
  bool isStart;

  CustomRow({super.key, required this.date, required this.isStart});
  @override
  _CustomRowState createState() => _CustomRowState();
}

class _CustomRowState extends State<CustomRow> {
  String _selectedOption = 'باشر';
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        widget.date = DateFormat('yyyy/M/d').format(_selectedDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          const Text(
            'مباشره الخدمه',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(
            width: 10,
          ),
          Row(
            children: [
              DropdownButton<String>(
                value: _selectedOption,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedOption = newValue!;
                    if (_selectedOption == 'باشر') {
                      widget.isStart = true;
                    } else {
                      widget.isStart = false;
                    }
                  });
                },
                items: <String>['باشر', 'لم يباشر']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              if (_selectedOption == 'باشر')
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
            ],
          ),
          if (_selectedOption == 'باشر' && _selectedDate != null)
            Text(
              'تاريخ المباشره: ${DateFormat('yyyy/M/d').format(_selectedDate!)}',
              style: const TextStyle(fontSize: 16),
            ),
        ],
      ),
    );
  }
}
