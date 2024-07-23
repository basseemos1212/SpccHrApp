import 'package:flutter/material.dart';
import 'package:hr_app/components/colors.dart';
import 'package:hr_app/screens/downloadEmployeeData.dart';
import 'package:hr_app/screens/files.dart';
import 'package:hr_app/screens/reports.dart';
import 'package:hr_app/screens/transactions.dart';
import 'package:hr_app/screens/home_page.dart';
import 'custom_curved_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    const HomePage(),
    const Transactions(
      direction: 'homeScreen',
    ),
    const Files(
      direction: '',
    ),
    const Reports(
      direction: '',
    ),
    const DownloadEmployeeData(
      direction: '',
    ),
  ];

  final List<String> _titles = [
    'الشاشة الرئيسية',
    'المعاملات',
    'الملفات',
    'التقارير',
    'تحميل بيانات موظف',
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset(
                'assets/logo.png', // Make sure you have a logo image in assets folder
                width: 40,
                height: 40,
              ),
              SizedBox(width: 10),
              Text(_titles[_currentIndex]),
            ],
          ),
          backgroundColor: Colors.white,
          foregroundColor: primaryColor,
          elevation: 0,
        ),
        drawer: CustomCurvedDrawer(onItemTap: onTabTapped),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: _children[_currentIndex],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
