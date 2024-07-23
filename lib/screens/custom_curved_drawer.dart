import 'package:flutter/material.dart';

class CustomCurvedDrawer extends StatelessWidget {
  final Function(int) onItemTap;

  const CustomCurvedDrawer({required this.onItemTap, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.deepPurpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  'القائمة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _buildDrawerItem(
                context, 'الشاشة الرئيسية', Icons.home, Colors.teal, 0),
            _buildDrawerItem(
                context, 'المعاملات', Icons.assignment, Colors.blueAccent, 1),
            _buildDrawerItem(
                context, 'الملفات', Icons.folder, Colors.orangeAccent, 2),
            _buildDrawerItem(
                context, 'التقارير', Icons.bar_chart, Colors.greenAccent, 3),
            _buildDrawerItem(context, 'تحميل بيانات موظف', Icons.cloud_download,
                Colors.redAccent, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon,
      Color color, int index) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      onTap: () {
        Navigator.of(context).pop();
        onItemTap(index);
      },
    );
  }
}
