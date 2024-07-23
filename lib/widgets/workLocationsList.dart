import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hr_app/classes/workLocation.dart';
import 'package:hr_app/components/colors.dart';
import 'package:hr_app/managers/firebaseHelper.dart';
import 'package:hr_app/screens/workLocationDetailPage.dart';

const List<Color> colorPalette = [
  Colors.lightBlue, // Light Blue
  Colors.lightGreen, // Light Green
  Colors.orangeAccent, // Orange
];

class WorkLocationsList extends StatefulWidget {
  const WorkLocationsList({super.key});

  @override
  State<WorkLocationsList> createState() => _WorkLocationsListState();
}

class _WorkLocationsListState extends State<WorkLocationsList>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> locs = [];
  final FirestoreManager _firestoreManager = FirestoreManager();
  bool isOpen = false;
  int selectedIndex = -10;
  WorkLocation workLocation =
      WorkLocation(name: "name", department: "department", employeeList: []);
  late List<AnimationController> _controllers;
  late List<Animation<double>> _opacityAnimations;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _firestoreManager.getAllDocuments("ألمواقع").then((value) => setState(() {
          locs = value;
          _initializeAnimations();
        }));
  }

  void _initializeAnimations() {
    _controllers = List<AnimationController>.generate(locs.length, (index) {
      return AnimationController(
        duration: const Duration(seconds: 1),
        vsync: this,
      );
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
    return isOpen
        ? WorkLocationDetailScreen(workLocation: workLocation)
        : Scaffold(
            body: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                childAspectRatio: 1,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              padding: const EdgeInsets.all(8),
              itemCount: locs.length,
              itemBuilder: (context, index) {
                final Color color = colorPalette[index % colorPalette.length];
                return _buildAnimatedGridItem(locs[index], color, index);
              },
            ),
          );
  }

  Widget _buildAnimatedGridItem(
      Map<String, dynamic> location, Color color, int index) {
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
            workLocation = WorkLocation(
              name: location['name'],
              department: location['department'],
              employeeList: [],
            );
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
                const Icon(
                  Icons.location_on,
                  size: 36,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  location['name'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  location['department'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
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
