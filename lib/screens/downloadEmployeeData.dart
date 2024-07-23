import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

const List<Color> colorPalette = [
  Colors.lightBlue, // Light Blue
  Colors.lightGreen, // Light Green
  Colors.orangeAccent, // Orange
];

class DownloadEmployeeData extends StatefulWidget {
  final String direction;
  const DownloadEmployeeData({super.key, required this.direction});

  @override
  State<DownloadEmployeeData> createState() => _DownloadEmployeeDataState();
}

class _DownloadEmployeeDataState extends State<DownloadEmployeeData>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> employees = [];
  List<Map<String, dynamic>> filteredEmployees = [];
  TextEditingController searchController = TextEditingController();
  late List<AnimationController> _controllers;
  late List<Animation<double>> _opacityAnimations;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
    searchController.addListener(_searchEmployees);
  }

  Future<void> _fetchEmployees() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('الموظفين').get();

    setState(() {
      employees = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      filteredEmployees = employees;
      _initAnimations();
    });
  }

  void _initAnimations() {
    _controllers = List<AnimationController>.generate(
      filteredEmployees.length,
      (index) => AnimationController(
        duration: const Duration(seconds: 1),
        vsync: this,
      )..forward(),
    );

    _opacityAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(
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

  void _searchEmployees() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredEmployees = employees.where((employee) {
        final name = employee['name']?.toLowerCase() ?? '';
        return name.contains(query);
      }).toList();
      _initAnimations();
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        'تحميل بيانات الموظف',
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
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'بحث عن موظف',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              padding: const EdgeInsets.all(8),
              itemCount: filteredEmployees.length,
              itemBuilder: (context, index) {
                final employee = filteredEmployees[index];
                return _buildAnimatedGridItem(employee, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedGridItem(Map<String, dynamic> employee, int index) {
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
        onTap: () => _generatePdfAndSave(employee),
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
                const Icon(Icons.download, size: 36, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  employee['name'] ?? 'No Name',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  employee['number'] ?? 'No Number',
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

  Future<void> _generatePdfAndSave(Map<String, dynamic> employee) async {
    final profileImageUrl =
        await _fetchProfileImageUrl(employee['profile_image'] ?? '');

    final pdf = pw.Document();
    final arabicFont =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Amiri-Regular.ttf'));

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "تفاصيل الموظف",
                style: pw.TextStyle(
                  font: arabicFont,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              if (profileImageUrl != null)
                pw.Image(
                  pw.MemoryImage(profileImageUrl),
                  width: 100,
                  height: 100,
                ),
              pw.SizedBox(height: 20),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "الاسم: ${employee['name'] ?? 'N/A'}",
                  style: pw.TextStyle(font: arabicFont, fontSize: 18),
                ),
              ),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "الرقم: ${employee['number'] ?? 'N/A'}",
                  style: pw.TextStyle(font: arabicFont, fontSize: 18),
                ),
              ),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "الوظيفه: ${employee['job'] ?? 'N/A'}",
                  style: pw.TextStyle(font: arabicFont, fontSize: 18),
                ),
              ),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "الكود: ${employee['code'] ?? 'N/A'}",
                  style: pw.TextStyle(font: arabicFont, fontSize: 18),
                ),
              ),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "مباشره الخدمه: ${employee['projectStartWork'] ?? 'N/A'}",
                  style: pw.TextStyle(font: arabicFont, fontSize: 18),
                ),
              ),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "الإداره: ${employee['department'] ?? 'N/A'}",
                  style: pw.TextStyle(font: arabicFont, fontSize: 18),
                ),
              ),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "الموقع: ${employee['location'] ?? 'N/A'}",
                  style: pw.TextStyle(font: arabicFont, fontSize: 18),
                ),
              ),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "الراتب: ${employee['mainSalary'] ?? 'N/A'}",
                  style: pw.TextStyle(font: arabicFont, fontSize: 18),
                ),
              ),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "بدل السكن: ${employee['homeAltSalary'] ?? 'N/A'}",
                  style: pw.TextStyle(font: arabicFont, fontSize: 18),
                ),
              ),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "بدل المعيشه: ${employee['livingAltSalary'] ?? 'N/A'}",
                  style: pw.TextStyle(font: arabicFont, fontSize: 18),
                ),
              ),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "بدل المسئوليه: ${employee['responsabilityAlt'] ?? 'N/A'}",
                  style: pw.TextStyle(font: arabicFont, fontSize: 18),
                ),
              ),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "الايام المستحقه من الاجازه الرسميه: ${employee['vacationTime'] ?? 'N/A'}",
                  style: pw.TextStyle(font: arabicFont, fontSize: 18),
                ),
              ),
              if (employee['rate'] != null)
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    "التقيم العام: ${employee['rate']}",
                    style: pw.TextStyle(font: arabicFont, fontSize: 18),
                  ),
                ),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "رقم الهويه: ${employee['idNumber'] ?? 'N/A'}",
                  style: pw.TextStyle(font: arabicFont, fontSize: 18),
                ),
              ),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "نوع الرخصه: ${employee['licenseType'] ?? 'N/A'}",
                  style: pw.TextStyle(font: arabicFont, fontSize: 18),
                ),
              ),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "سياره: ${employee['carType'] ?? 'N/A'}",
                  style: pw.TextStyle(font: arabicFont, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final file = File("F:/${employee['name'] ?? 'employee'}.pdf");
    await file.writeAsBytes(await pdf.save());

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => file.readAsBytesSync(),
    );

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('PDF saved to ${file.path}')));
  }

  Future<Uint8List?> _fetchProfileImageUrl(String? objectId) async {
    if (objectId == null || objectId.isEmpty) return null;
    final ParseResponse response =
        await ParseObject('profileImages').getObject(objectId);

    if (response.success && response.results != null) {
      final parseObject = response.results!.first as ParseObject;
      final ParseFileBase? varFile = parseObject.get<ParseFileBase>('file');
      if (varFile != null) {
        final Uri uri = Uri.parse(varFile.url!);
        final http.Response imageData = await http.get(uri);
        return imageData.bodyBytes;
      }
    }
    return null;
  }
}
