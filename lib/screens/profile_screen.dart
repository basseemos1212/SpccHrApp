import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hr_app/components/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> doc;
  const ProfileScreen({super.key, required this.doc});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController jobController;
  late TextEditingController nationalityController;
  late TextEditingController numberController;
  late TextEditingController statusController;
  late TextEditingController ratingController;
  late TextEditingController mainSalaryController;
  late TextEditingController housingAllowanceController;
  late TextEditingController carAllowanceController;
  late TextEditingController vacationDurationController;
  late TextEditingController vacationStatusController;
  late TextEditingController licenseTypeController;
  late TextEditingController carTypeController;
  late TextEditingController startDateController;
  late TextEditingController endDateController;
  late TextEditingController locationController;
  late TextEditingController departmentController;
  late TextEditingController projectController;
  late TextEditingController serviceStartDateController;

  late String discountType;
  String? housingAllowanceType;
  String? carAllowanceType;

  final List<String> housingAllowanceOptions = [
    'يوفر سكن',
    'يوفر بدل سكن',
  ];

  final List<String> paymentTypeOptions = [
    'شهري',
    'سنوي',
  ];

  final List<String> carAllowanceOptions = [
    'تسليم سيارة',
    'بدل ديزل',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    jobController = TextEditingController(text: widget.doc['job']);
    nationalityController =
        TextEditingController(text: widget.doc['nationality']);
    numberController = TextEditingController(text: widget.doc['number']);
    statusController = TextEditingController(text: widget.doc['status']);
    ratingController =
        TextEditingController(text: widget.doc['rating']?.toString());
    mainSalaryController =
        TextEditingController(text: widget.doc['mainSalary']?.toString());
    housingAllowanceController =
        TextEditingController(text: widget.doc['housingAllowance']?.toString());
    carAllowanceController = TextEditingController(
        text: widget.doc['carAllowanceValue']?.toString());
    vacationDurationController =
        TextEditingController(text: widget.doc['vacationDuration']?.toString());
    vacationStatusController =
        TextEditingController(text: widget.doc['vacationStatus']);
    licenseTypeController =
        TextEditingController(text: widget.doc['licenseType']);
    carTypeController = TextEditingController(text: widget.doc['carType']);
    startDateController = TextEditingController(text: widget.doc['startDate']);
    endDateController = TextEditingController(text: widget.doc['endDate']);
    locationController = TextEditingController(text: widget.doc['location']);
    departmentController =
        TextEditingController(text: widget.doc['department']);
    projectController = TextEditingController(text: widget.doc['project']);
    serviceStartDateController =
        TextEditingController(text: widget.doc['serviceStartDate']);

    discountType = widget.doc['nationality'] ?? 'سعودي';
    housingAllowanceType = widget.doc['housingAllowanceType'] ?? 'يوفر سكن';
    carAllowanceType = widget.doc['carAllowanceType'] ?? 'تسليم سيارة';
  }

  @override
  void dispose() {
    _tabController.dispose();
    jobController.dispose();
    nationalityController.dispose();
    numberController.dispose();
    statusController.dispose();
    ratingController.dispose();
    mainSalaryController.dispose();
    housingAllowanceController.dispose();
    carAllowanceController.dispose();
    vacationDurationController.dispose();
    vacationStatusController.dispose();
    licenseTypeController.dispose();
    carTypeController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    locationController.dispose();
    departmentController.dispose();
    projectController.dispose();
    serviceStartDateController.dispose();
    super.dispose();
  }

  double _parseDouble(dynamic value) {
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else if (value is double) {
      return value;
    } else {
      return 0.0;
    }
  }

  double _calculateTotalSalary() {
    double mainSalary = _parseDouble(mainSalaryController.text);
    double housingAllowance = _parseDouble(housingAllowanceController.text);
    double carAllowance = _parseDouble(carAllowanceController.text);

    double totalSalary = mainSalary + housingAllowance + carAllowance;

    double discount = 0;
    if (nationalityController.text == 'سعودي') {
      discount = totalSalary * 0.2;
    } else {
      discount = totalSalary * 0.02;
    }

    return totalSalary - discount;
  }

  Future<void> _updateProfile() async {
    await FirebaseFirestore.instance
        .collection('الموظفين')
        .doc(widget.doc['name'])
        .update({
      'job': jobController.text,
      'nationality': nationalityController.text,
      'number': numberController.text,
      'status': statusController.text,
      'rating': _parseDouble(ratingController.text),
      'mainSalary': _parseDouble(mainSalaryController.text),
      'housingAllowance': _parseDouble(housingAllowanceController.text),
      'housingAllowanceType': housingAllowanceType,
      'carAllowance': _parseDouble(carAllowanceController.text),
      'carAllowanceType': carAllowanceType,
      'vacationDuration': _parseDouble(vacationDurationController.text),
      'vacationStatus': vacationStatusController.text,
      'licenseType': licenseTypeController.text,
      'carType': carTypeController.text,
      'startDate': startDateController.text,
      'endDate': endDateController.text,
      'location': locationController.text,
      'department': departmentController.text,
      'project': projectController.text,
      'serviceStartDate': serviceStartDateController.text,
    });
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('بيانات الموظف'),
          actions: [
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _updateProfile,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Material(
                            elevation: 3,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            width: height * 0.2,
                                            height: height * 0.2,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                image: DecorationImage(
                                                    image: widget
                                                                .doc['imageUrl']
                                                                ?.isNotEmpty ??
                                                            false
                                                        ? NetworkImage(widget
                                                            .doc['imageUrl'])
                                                        : AssetImage(
                                                                "assets/profile.jpeg")
                                                            as ImageProvider,
                                                    fit: BoxFit.cover)),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                              ),
                                              child: Material(
                                                elevation: 4.0,
                                                shape: CircleBorder(),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    Icons.edit,
                                                    color: primaryColor,
                                                    size: height * 0.03,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        widget.doc['name'] ?? 'لا يوجد',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 18),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Text(
                                            widget.doc['job'] ?? 'لا يوجد',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      _buildEditableDetailTile(
                                          title: 'الجنسيه',
                                          controller: nationalityController,
                                          width: width * 0.25),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      _buildEditableDetailTile(
                                          title: 'رقم الهاتف',
                                          controller: numberController,
                                          width: width * 0.25),
                                      _buildEditableDetailTile(
                                          title: 'الحالة الوظيفية',
                                          controller: statusController,
                                          width: width * 0.25),
                                      _buildEditableDetailTile(
                                          title: 'تقييم الموظف',
                                          controller: ratingController,
                                          width: width * 0.25),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Material(
                      color: Colors.white,
                      elevation: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TabBar(
                            controller: _tabController,
                            labelColor: primaryColor,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: primaryColor,
                            tabs: const [
                              Tab(text: 'معلومات المرتب'),
                              Tab(text: 'معلومات الإجازة'),
                              Tab(text: 'معلومات العمل'),
                              Tab(text: 'ملفات'),
                              Tab(text: "التقييم السنوي"),
                            ],
                          ),
                          Container(
                            height: height * 0.7,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildSalaryInfoTab(),
                                _buildVacationInfoTab(),
                                _buildWorkInfoTab(),
                                _buildFilesTab(),
                                _buildRatingTab(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableDetailTile({
    required String title,
    required TextEditingController controller,
    required double width,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14, color: primaryColor),
            ),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryInfoTab() {
    final width = MediaQuery.of(context).size.width;
    double totalSalary = _calculateTotalSalary();
    String discountRate = discountType == 'سعودي' ? '20%' : '2%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'معلومات المرتب',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              _buildEditableDetailTile(
                  title: 'الراتب الأساسي',
                  controller: mainSalaryController,
                  width: width * 0.5),
              _buildEditableDetailTile(
                  title: 'بدل السكن',
                  controller: housingAllowanceController,
                  width: width * 0.5),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  width: width * 0.5,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نوع بدل السكن',
                        style: TextStyle(fontSize: 14, color: primaryColor),
                      ),
                      DropdownButtonFormField<String>(
                        value: housingAllowanceType,
                        onChanged: (String? newValue) {
                          setState(() {
                            housingAllowanceType = newValue;
                          });
                        },
                        items: housingAllowanceOptions.map((String option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                      ),
                      if (housingAllowanceType == 'يوفر بدل سكن')
                        DropdownButtonFormField<String>(
                          value: paymentTypeOptions.first,
                          onChanged: (String? newValue) {
                            setState(() {
                              // housingAllowanceController.text = newValue!;
                            });
                          },
                          items: paymentTypeOptions.map((String option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  width: width * 0.5,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نوع بدل السيارة',
                        style: TextStyle(fontSize: 14, color: primaryColor),
                      ),
                      DropdownButtonFormField<String>(
                        value: carAllowanceType,
                        onChanged: (String? newValue) {
                          setState(() {
                            carAllowanceType = newValue;
                          });
                        },
                        items: carAllowanceOptions.map((String option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                      ),
                      if (carAllowanceType == 'بدل ديزل')
                        TextFormField(
                          controller: carAllowanceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'قيمة بدل الديزل',
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
              ),
              _buildDetailTile(
                  title: 'نسبة خصم التأمينات الاجتماعية',
                  value: discountRate,
                  width: width * 0.5),
              _buildDetailTile(
                  title: 'إجمالي الراتب',
                  value: totalSalary.toStringAsFixed(2),
                  width: width * 0.5),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVacationInfoTab() {
    final width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'معلومات الإجازة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              _buildEditableDetailTile(
                  title: 'مدة الإجازة السنوية',
                  controller: vacationDurationController,
                  width: width * 0.5),
              _buildEditableDetailTile(
                  title: 'حالة الإجازة السنوية',
                  controller: vacationStatusController,
                  width: width * 0.5),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkInfoTab() {
    final width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'معلومات العمل',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              _buildEditableDetailTile(
                  title: 'نوع الرخصة',
                  controller: licenseTypeController,
                  width: width * 0.5),
              _buildEditableDetailTile(
                  title: 'نوع السيارة',
                  controller: carTypeController,
                  width: width * 0.5),
              _buildEditableDetailTile(
                  title: 'تاريخ بداية العقد',
                  controller: startDateController,
                  width: width * 0.5),
              _buildEditableDetailTile(
                  title: 'تاريخ نهايه العقد',
                  controller: endDateController,
                  width: width * 0.5),
              _buildEditableDetailTile(
                  title: 'موقع العمل',
                  controller: locationController,
                  width: width * 0.5),
              _buildEditableDetailTile(
                  title: 'الاداره',
                  controller: departmentController,
                  width: width * 0.5),
              _buildEditableDetailTile(
                  title: 'المشروع',
                  controller: projectController,
                  width: width * 0.5),
              _buildEditableDetailTile(
                  title: 'تاريخ مباشره العمل',
                  controller: serviceStartDateController,
                  width: width * 0.5),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilesTab() {
    final fileUrls = widget.doc['fileUrls'] as List<dynamic>? ?? [];
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 20.0,
        runSpacing: 10.0,
        children: fileUrls.map((file) {
          final fileName = file['name'] ?? 'غير معروف';
          final fileUrl = file['url'] ?? '';
          final isPdf = fileName.endsWith('.pdf');
          final isPng = fileName.endsWith('.png');

          return GestureDetector(
            onTap: () => _launchURL(fileUrl),
            child: Column(
              children: [
                Icon(
                  isPdf
                      ? Icons.picture_as_pdf
                      : isPng
                          ? Icons.image
                          : Icons.file_copy,
                  color: primaryColor,
                  size: width * 0.035,
                ),
                SizedBox(height: 5),
                Text(
                  fileName,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRatingTab() {
    final monthlyRatings =
        widget.doc['monthlyRatings'] as Map<String, dynamic>? ?? {};
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التقييم السنوي',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: months.length,
              itemBuilder: (context, index) {
                final month = months[index];
                final rating = _pDouble(monthlyRatings[month]);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      month,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    RatingBarIndicator(
                      rating: rating,
                      itemBuilder: (context, index) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 40.0,
                      direction: Axis.horizontal,
                    ),
                    SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  double _pDouble(dynamic value) {
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else if (value is double) {
      return value;
    } else {
      return 0.0;
    }
  }

  Widget _buildDetailTile(
      {required String title, required String value, required double width}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14, color: primaryColor),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
