import 'package:flutter/material.dart';
import 'package:hr_app/screens/downloadEmployeeData.dart';
import 'package:hr_app/screens/files.dart';
import 'package:hr_app/screens/reports.dart';
import 'package:hr_app/screens/stepper_form.dart';
import 'package:hr_app/screens/transactions.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;
  late AnimationController _controller4;

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _controller2 = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _controller3 = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _controller4 = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _controller1.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _controller2.forward();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      _controller3.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      _controller4.forward();
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    double containerWidth =
        (width - 64) / 2; // Adjust width for padding and spacing
    double containerHeight = (height - 128) /
        2; // Adjust height for padding, spacing, and top/bottom separation

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
        child: Center(
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: <Widget>[
              _buildAnimatedContainer(
                _controller1,
                'المعاملات',
                Icons.assignment,
                Colors.blue,
                Colors.blueAccent,
                containerWidth,
                containerHeight,
                const Transactions(
                  direction: "homePage",
                ), // Navigate to Transactions screen
              ),
              _buildAnimatedContainer(
                _controller2,
                'الملفات',
                Icons.folder,
                Colors.orange,
                Colors.orangeAccent,
                containerWidth,
                containerHeight,
                const Files(
                  direction: 'homePage',
                ), // Navigate to Files screen
              ),
              _buildAnimatedContainer(
                _controller3,
                'التقارير',
                Icons.bar_chart,
                Colors.green,
                Colors.greenAccent,
                containerWidth,
                containerHeight,
                const Reports(
                  direction: 'homePage',
                ), // Navigate to Reports screen
              ),
              _buildAnimatedContainer(
                  _controller4,
                  'تحميل بيانات موظف',
                  Icons.cloud_download,
                  Colors.red,
                  Colors.redAccent,
                  containerWidth,
                  containerHeight,
                  const DownloadEmployeeData(
                    direction: 'homePage',
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedContainer(
    AnimationController controller,
    String title,
    IconData icon,
    Color startColor,
    Color endColor,
    double width,
    double height,
    Widget destinationScreen, // Destination screen parameter
  ) {
    return ScaleTransition(
      scale: controller,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(_createRoute(destinationScreen));
        },
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 48, color: Colors.white), // Reduced icon size
              const SizedBox(height: 8), // Reduced spacing
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18, // Reduced font size
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Route _createRoute(Widget destinationScreen) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          destinationScreen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
