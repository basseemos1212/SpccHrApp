import 'package:flutter/material.dart';

class StatusContainer extends StatelessWidget {
  final String status;

  const StatusContainer({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color color;

    // Determine icon and color based on the status
    switch (status) {
      case 'نشط':
        iconData = Icons.check_circle;
        color = Colors.green;
        break;
      case 'هروب':
        iconData = Icons.warning;
        color = Colors.yellow;
        break;
      case 'اصابه عمل':
        iconData = Icons.medical_services;
        color = Colors.red;
        break;
      case 'اجازه':
        iconData = Icons.beach_access;
        color = Colors.blue;
        break;
      case 'موقوف':
        iconData = Icons.block;
        color = Colors.orange;
        break;
      case 'خرج و لم يعد':
        iconData = Icons.exit_to_app;
        color = Colors.grey;
        break;
      default:
        iconData = Icons.error;
        color = Colors.black;
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2), // Use a slightly transparent color
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            color: color,
          ),
          SizedBox(width: 8),
          Text(status),
        ],
      ),
    );
  }
}
