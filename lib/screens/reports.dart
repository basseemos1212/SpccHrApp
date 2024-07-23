import 'package:flutter/material.dart';
import 'package:hr_app/components/colors.dart';
import 'package:hr_app/components/lists.dart';
import 'package:hr_app/screens/financeScreen.dart';
import 'package:hr_app/screens/responsabiltyReport.dart';
import 'package:hr_app/screens/transportaionReport.dart';
import 'package:hr_app/screens/vacationBalance.dart';
import 'package:hr_app/screens/vacation_detailed_report_screen.dart';
import 'package:hr_app/screens/work_injury_report.dart';

const List<Color> colorPalette = [
  Colors.lightBlue, // Light Blue
  Colors.lightGreen, // Light Green
  Colors.orangeAccent, // Orange
];

const List<IconData> reportIcons = [
  Icons.directions_car, // for "Transportation Report"
  Icons.attach_money, // for "Finance Report"
  Icons.assignment, // for "Responsibility Report"
  Icons.local_hospital, // for "Work Injury Report"
  Icons.calendar_today, // for "Vacation Detailed Report"
];

class Reports extends StatefulWidget {
  final String direction;
  const Reports({Key? key, required this.direction}) : super(key: key);

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> with TickerProviderStateMixin {
  bool isOpen = false;
  int selectedIndex = -10;
  String searchQuery = '';
  late List<AnimationController> _controllers;
  late List<Animation<double>> _opacityAnimations;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _controllers =
        List<AnimationController>.generate(reportsList.length, (index) {
      return AnimationController(
        duration: const Duration(seconds: 1),
        vsync: this,
      )..forward();
    });

    _opacityAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.8, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _startStaggeredAnimations();
  }

  void _startStaggeredAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = reportsList
        .where((item) => item.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: widget.direction == 'homePage'
          ? AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        height: 40,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'التقارير',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
              backgroundColor: Colors.white,
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isOpen)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'بحث...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search),
                  ),
                ),
              ),
            ),
          if (isOpen && selectedIndex == 0)
            const Expanded(child: TransportationReport())
          else if (isOpen && selectedIndex == 1)
            const Expanded(child: FinanceReportScreen())
          else if (isOpen && selectedIndex == 2)
            const Expanded(child: ResponsabilityReports())
          else if (isOpen && selectedIndex == 3)
            const Expanded(child: WorkInjuryReports())
          else if (isOpen && selectedIndex == 10)
            Expanded(child: VacationBalanceTable())
          else if (isOpen && selectedIndex == 4)
            const Expanded(child: VacationDetailReport())
          else
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  childAspectRatio: 1,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                padding: const EdgeInsets.all(8),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  return _buildAnimatedGridItem(
                      filteredList[index], reportIcons[index], index);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedGridItem(String title, IconData icon, int index) {
    final Color color = colorPalette[index % colorPalette.length];
    return AnimatedBuilder(
      animation: _controllers[index],
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimations[index].value,
          child: Transform.scale(
            scale: _scaleAnimations[index].value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            isOpen = true;
            selectedIndex = index;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 36,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
