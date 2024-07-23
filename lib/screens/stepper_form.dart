import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hr_app/managers/firebaseHelper.dart';

class StepperForm extends StatefulWidget {
  @override
  _StepperFormState createState() => _StepperFormState();
}

class _StepperFormState extends State<StepperForm>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  final FirestoreManager _firestoreManager = FirestoreManager();
  int _currentPage = 0;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController jobController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController projectController = TextEditingController();
  final TextEditingController vacationStartController = TextEditingController();
  final TextEditingController vacationDurationController =
      TextEditingController();
  final TextEditingController mainSalaryController = TextEditingController();
  TextEditingController nationalityController = TextEditingController();

  final TextEditingController numberController = TextEditingController();
  final TextEditingController housingAllowanceValueController =
      TextEditingController();
  final TextEditingController carAllowanceValueController =
      TextEditingController();
  final TextEditingController totalSalaryController = TextEditingController();
  final TextEditingController idNumberController = TextEditingController();
  final TextEditingController serviceStartDateController =
      TextEditingController();
  String? housingAllowanceType;
  String? housingAllowancePaymentType;
  String? carAllowanceType;
  String? selectedLicenseType;
  String? selectedJob;
  String? selectedLocation;
  String? selectedDepartment;
  String? selectedProject;
  String? serviceStatus;
  String? selectedNationality;
  bool isStart = true;
  XFile? imageFile;
  String imageUrl = '';
  bool isLoading = false;
  bool isUploadingFile = false;
  List<Map<String, String>> fileUrls = [];

  bool isProfileImageUploaded = false;
  bool isContractUploaded = false;

  List<String> jobTypes = [];
  List<String> departments = [];
  List<String> locations = [];
  List<String> projects = [];

  final List<String> licenseTypes = [
    'خاصه',
    'نقل ثقيل',
    'عمومي',
    'لا يوجد',
  ];

  final List<String> serviceStatusOptions = [
    'باشر',
    'لم يباشر',
  ];

  final List<String> nationalityOptions = [
    'سعودي',
    'اجنبي',
  ];

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _fetchInitialData();
    _addListeners();
  }

  Future<void> _fetchInitialData() async {
    jobTypes = await _firestoreManager.fetchJobs();
    departments = await _firestoreManager.fetchDepartments();
    locations = await _firestoreManager.fetchLocations();
    setState(() {});
  }

  Future<void> _fetchProjects(String departmentId) async {
    setState(() {
      projects = [];
      selectedProject = null; // Reset selected project
    });

    projects = await _firestoreManager.fetchProjects(departmentId);
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    codeController.dispose();
    nationalityController.dispose();
    numberController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    jobController.dispose();
    locationController.dispose();
    departmentController.dispose();
    projectController.dispose();
    vacationStartController.dispose();
    vacationDurationController.dispose();
    mainSalaryController.dispose();
    housingAllowanceValueController.dispose();
    carAllowanceValueController.dispose();
    totalSalaryController.dispose();
    idNumberController.dispose();
    serviceStartDateController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 5) {
      setState(() {
        _currentPage++;
        _pageController.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.ease);
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        _pageController.previousPage(
            duration: const Duration(milliseconds: 300), curve: Curves.ease);
      });
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _saveForm() {
    final employeeData = {
      'name': nameController.text,
      'code': codeController.text,
      'startDate': startDateController.text,
      'endDate': endDateController.text,
      'job': selectedJob,
      'location': selectedLocation,
      'department': selectedDepartment,
      'project': selectedProject,
      'vacationStart': vacationStartController.text,
      'vacationDuration': vacationDurationController.text,
      'mainSalary': mainSalaryController.text,
      'housingAllowanceType': housingAllowanceType,
      'housingAllowancePaymentType': housingAllowancePaymentType,
      'housingAllowance': housingAllowanceValueController.text,
      'carAllowanceType': carAllowanceType,
      'carAllowanceValue': carAllowanceValueController.text,
      'totalSalary': totalSalaryController.text,
      'idNumber': idNumberController.text,
      'licenseType': selectedLicenseType,
      'serviceStartDate': serviceStartDateController.text,
      'serviceStatus': serviceStatus,
      'fileUrls': _filterFileUrls(),
      "nationality": nationalityController.text,
      "rating": 0,
      'number': numberController.text,
      'imageUrl': imageUrl,
      'status': serviceStatus == "باشر" ? "نشط" : "موقوف",
      'discount': selectedNationality
    };

    _firestoreManager.addDocument("الموظفين", employeeData).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ البيانات بنجاح')),
      );

      _addServiceStartReport();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء حفظ البيانات: $error')),
      );
    });
  }

  Future<void> _addServiceStartReport() async {
    final reportData = {
      'report':
          'تمت مباشره خدمه الموظف في يوم ${serviceStartDateController.text}',
    };

    await _firestoreManager.addDoc(
      'التقرير العام',
      reportData,
      nameController.text,
    );
  }

  List<Map<String, String>> _filterFileUrls() {
    return fileUrls.map((file) {
      String originalName = file['name']!;
      int underscoreIndex = originalName.lastIndexOf('_');
      String filteredName =
          (underscoreIndex != -1 && underscoreIndex < originalName.length - 1)
              ? originalName.substring(underscoreIndex + 1)
              : originalName;
      return {
        'name': filteredName,
        'url': file['url']!,
        'folder': file['folder']!,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('تعين موظف'),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Image.asset(
                  'assets/logo.png', // Replace with your actual logo URL
                  height: 100,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                _buildFormStep('البيانات الشخصية', _buildPersonalDetailsForm()),
                _buildFormStep('اختيار الوظيفه', _buildJobDetailsForm()),
                _buildFormStep('تفاصيل الراتب', _buildVacationDetailsForm()),
                _buildFormStep('معلومات الهوية', _buildIdentityDetailsForm()),
                _buildFormStep('تحميل الملفات', _buildFileUploadForm()),
                _buildFormStep('مباشره الخدمه', _buildServiceStartForm()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _currentPage == 5
          ? FloatingActionButton(
              onPressed: _saveForm,
              child: const Icon(Icons.save),
            )
          : null,
    );
  }

  Widget _buildFormStep(String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(child: content), // Ensure the content is scrollable
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentPage > 0)
                ElevatedButton(
                  onPressed: _previousPage,
                  child: const Text('رجوع'),
                ),
              _currentPage == 5
                  ? SizedBox()
                  : ElevatedButton(
                      onPressed: _nextPage,
                      child: Text(_currentPage == 5 ? 'حفظ' : 'التالي'),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int step, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: _currentPage >= step ? Colors.purple : Colors.grey,
          child: Text((step + 1).toString(),
              style: const TextStyle(color: Colors.white)),
        ),
        Text(label, style: const TextStyle(color: Colors.black)),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStep(0, 'بيانات الموظف'),
        _buildStep(1, 'اختيار الوظيفه'),
        _buildStep(2, 'تفاصيل الراتب'),
        _buildStep(3, 'معلومات الهوية والرخصه'),
        _buildStep(4, 'تحميل الملفات'),
        _buildStep(5, 'مباشره الخدمه'),
      ],
    );
  }

  Widget _buildPersonalDetailsForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          FormTextField(
            textEditingController: nameController,
            isobsecureText: false,
            hintText: "اسم الموظف",
            isValidate: true,
          ),
          FormTextField(
            textEditingController: numberController,
            isobsecureText: false,
            hintText: "رقم الموظف",
            isValidate: true,
          ),
          FormTextField(
            textEditingController: nationalityController,
            isobsecureText: false,
            hintText: "جنسيه الموظف",
            isValidate: true,
          ),
          FormTextField(
            textEditingController: codeController,
            isobsecureText: false,
            hintText: "كود الموظف",
            isValidate: true,
          ),
          FormTextField(
            textEditingController: startDateController,
            isobsecureText: false,
            hintText: "تاريخ بداية العقد",
            isValidate: true,
            onTap: () => _selectDate(context, startDateController),
          ),
          FormTextField(
            textEditingController: endDateController,
            isobsecureText: false,
            hintText: "تاريخ نهاية العقد",
            isValidate: true,
            onTap: () => _selectDate(context, endDateController),
          ),
        ],
      ),
    );
  }

  Widget _buildJobDetailsForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'اختيار الوظيفه',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                ),
              ),
              items: jobTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedJob = newValue;
                });
              },
              value: selectedJob,
            ),
          ),
          LocationsDropdown(
            textEditingController: locationController,
            locations: locations,
            onChanged: (newValue) {
              setState(() {
                selectedLocation = newValue;
              });
            },
            selectedValue: selectedLocation,
          ),
          DepartmentsDropdown(
            textEditingController: departmentController,
            departments: departments,
            onChanged: (newValue) {
              setState(() {
                selectedDepartment = newValue;
                selectedProject = null; // Reset selected project
                _fetchProjects(newValue!);
              });
            },
            selectedValue: selectedDepartment,
          ),
          ProjectsDropdown(
            textEditingController: projectController,
            projects: projects,
            onChanged: (newValue) {
              setState(() {
                selectedProject = newValue;
              });
            },
            selectedValue: selectedProject,
          ),
        ],
      ),
    );
  }

  Widget _buildVacationDetailsForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          FormTextField(
            textEditingController: vacationStartController,
            keyboardType: TextInputType.number,
            isobsecureText: false,
            hintText: "يملك اجازه بعد كم شهر",
            isValidate: true,
          ),
          FormTextField(
            textEditingController: vacationDurationController,
            keyboardType: TextInputType.number,
            isobsecureText: false,
            hintText: "مدة الاجازة السنوية",
            isValidate: true,
          ),
          FormTextField(
            textEditingController: mainSalaryController,
            keyboardType: TextInputType.number,
            isobsecureText: false,
            hintText: "الراتب الأساسي",
            isValidate: true,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'بدل السكن',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                ),
              ),
              items: ['يوفر سكن', 'يوفر بدل سكن'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  housingAllowanceType = newValue;
                  housingAllowancePaymentType = null;
                  housingAllowanceValueController.clear();
                });
              },
              value: housingAllowanceType,
            ),
          ),
          if (housingAllowanceType == 'يوفر بدل سكن') ...[
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  hintText: "نوع بدل السكن",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: ['شهري', 'سنوي'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    housingAllowancePaymentType = newValue;
                  });
                },
                value: housingAllowancePaymentType,
                hint: Text('اختر نوع بدل السكن'),
              ),
            ),
            FormTextField(
              textEditingController: housingAllowanceValueController,
              keyboardType: TextInputType.number,
              isobsecureText: false,
              hintText: "قيمة بدل السكن",
              isValidate: true,
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'بدل السيارة',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                ),
              ),
              items: ["تسليم سيارة", 'بدل ديزل'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  carAllowanceType = newValue;
                  carAllowanceValueController.clear();
                });
              },
              value: carAllowanceType,
            ),
          ),
          if (carAllowanceType == 'بدل ديزل')
            FormTextField(
              textEditingController: carAllowanceValueController,
              keyboardType: TextInputType.number,
              isobsecureText: false,
              hintText: "قيمة بدل الديزل",
              isValidate: true,
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'اختر الجنسية',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                ),
              ),
              items: nationalityOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedNationality = newValue;
                  _calculateTotalSalary(); // Recalculate total salary when nationality changes
                });
              },
              value: selectedNationality,
            ),
          ),
          FormTextField(
            textEditingController: totalSalaryController,
            isobsecureText: false,
            hintText: "إجمالي الراتب",
            isValidate: false,
            enable: false,
          ),
        ],
      ),
    );
  }

  void _addListeners() {
    mainSalaryController.addListener(_calculateTotalSalary);
    housingAllowanceValueController.addListener(_calculateTotalSalary);
    carAllowanceValueController.addListener(_calculateTotalSalary);
  }

  void _calculateTotalSalary() {
    double mainSalary = double.tryParse(mainSalaryController.text) ?? 0;
    double housingAllowanceValue =
        double.tryParse(housingAllowanceValueController.text) ?? 0;
    double carAllowanceValue =
        double.tryParse(carAllowanceValueController.text) ?? 0;

    double totalSalary = mainSalary + housingAllowanceValue + carAllowanceValue;

    double discount = 0;
    if (selectedNationality == 'سعودي') {
      discount = totalSalary * 0.2;
    } else if (selectedNationality == 'اجنبي') {
      discount = totalSalary * 0.02;
    }

    totalSalary = totalSalary - discount;
    totalSalaryController.text = totalSalary.toStringAsFixed(2);
  }

  Widget _buildIdentityDetailsForm() {
    return Column(
      children: [
        FormTextField(
          textEditingController: idNumberController,
          isobsecureText: false,
          hintText: "رقم الهوية",
          isValidate: true,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "نوع الرخصة",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6,
              ),
            ),
            items: licenseTypes.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedLicenseType = newValue;
              });
            },
            value: selectedLicenseType,
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadForm() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: saveProfileImage,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.height * 0.3,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    image: imageFile == null
                        ? null
                        : DecorationImage(
                            image: FileImage(File(imageFile!.path)),
                            fit: BoxFit.cover,
                          ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: imageFile == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "ارفق صورة الموظف",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Icon(
                                Icons.add,
                                size: 30,
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isProfileImageUploaded
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const SizedBox(),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              FolderWidget(
                title: 'ملفات الاصول',
                onFilePicked: (files) => _onFilesPicked(files, 'ملفات الاصول'),
                fileUrls: fileUrls
                    .where((file) => file['folder'] == 'ملفات الاصول')
                    .toList(),
              ),
              FolderWidget(
                title: 'ملفات الماليات',
                onFilePicked: (files) =>
                    _onFilesPicked(files, 'ملفات الماليات'),
                fileUrls: fileUrls
                    .where((file) => file['folder'] == 'ملفات الماليات')
                    .toList(),
              ),
              FolderWidget(
                title: 'العقود',
                onFilePicked: (files) => _onFilesPicked(files, 'العقود'),
                fileUrls: fileUrls
                    .where((file) => file['folder'] == 'العقود')
                    .toList(),
              ),
              FolderWidget(
                title: 'الهويه',
                onFilePicked: (files) => _onFilesPicked(files, 'الهويه'),
                fileUrls: fileUrls
                    .where((file) => file['folder'] == 'الهويه')
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onFilesPicked(List<Map<String, String>> files, String folder) {
    setState(() {
      for (var file in files) {
        fileUrls.add({
          'name': file['name']!,
          'url': file['url']!,
          'folder': folder,
        });
      }
    });
  }

  Future<void> saveProfileImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        imageFile = XFile(file.path!);
      });

      try {
        String uploadedImageUrl = await _uploadFileToFirebase(
            File(imageFile!.path), 'profile_images/${file.name}');
        setState(() {
          imageUrl = uploadedImageUrl;
          isProfileImageUploaded = true;
        });
      } catch (e) {
        print("Error uploading profile image: $e");
      }
    }
  }

  Future<void> pickFiles() async {
    setState(() {
      isUploadingFile = true;
    });

    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.any);

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        if (file.path != null) {
          XFile pickedFile = XFile(file.path!);

          try {
            String fileUrl = await _uploadFileToFirebase(
                File(pickedFile.path), 'documents/${file.name}');
            setState(() {
              fileUrls.add({
                'name': _filterFileName(file.name),
                'url': fileUrl,
              });
            });
          } catch (e) {
            print("Error uploading file: $e");
          }
        }
      }
    } catch (e) {
      print("Error picking file: $e");
    } finally {
      setState(() {
        isUploadingFile = false;
      });
    }
  }

  Future<String> _uploadFileToFirebase(File file, String path) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(path);
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception("Error uploading file: $e");
    }
  }

  String _filterFileName(String originalName) {
    int underscoreIndex = originalName.lastIndexOf('_');
    return (underscoreIndex != -1 && underscoreIndex < originalName.length - 1)
        ? originalName.substring(underscoreIndex + 1)
        : originalName;
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Widget _buildServiceStartForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          FormTextField(
            textEditingController: serviceStartDateController,
            isobsecureText: false,
            hintText: "تاريخ مباشره الخدمه",
            isValidate: true,
            onTap: () => _selectDate(context, serviceStartDateController),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "الحالة",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                ),
              ),
              items: serviceStatusOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  serviceStatus = newValue;
                });
              },
              value: serviceStatus,
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class FormTextField extends StatelessWidget {
  final TextEditingController textEditingController;
  final TextInputType? keyboardType;
  final bool isobsecureText;
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isValidate;
  bool? enable;
  final VoidCallback? onTap;

  FormTextField({
    required this.textEditingController,
    this.keyboardType,
    required this.isobsecureText,
    required this.hintText,
    this.prefixIcon,
    this.enable,
    this.suffixIcon,
    required this.isValidate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: TextFormField(
        controller: textEditingController,
        obscureText: isobsecureText,
        keyboardType: keyboardType,
        enabled: enable,
        validator: (value) {
          if (isValidate && (value == null || value.isEmpty)) {
            return 'الحقل مطلوب';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.only(top: 12, right: 20),
          constraints: BoxConstraints(
            maxWidth: width * 0.6,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class DepartmentsDropdown extends StatefulWidget {
  final TextEditingController textEditingController;
  final List<String> departments;
  final ValueChanged<String?> onChanged;
  final String? selectedValue;
  const DepartmentsDropdown({
    Key? key,
    required this.textEditingController,
    required this.departments,
    required this.onChanged,
    this.selectedValue,
  }) : super(key: key);

  @override
  _DepartmentsDropdownState createState() => _DepartmentsDropdownState();
}

class _DepartmentsDropdownState extends State<DepartmentsDropdown> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'اختيار الادارة',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          constraints: BoxConstraints(
            maxWidth: width * 0.6,
          ),
        ),
        items: widget.departments.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: widget.onChanged,
        value: widget.selectedValue,
      ),
    );
  }
}

class LocationsDropdown extends StatefulWidget {
  final TextEditingController textEditingController;
  final List<String> locations;
  final ValueChanged<String?> onChanged;
  final String? selectedValue;
  const LocationsDropdown({
    Key? key,
    required this.textEditingController,
    required this.locations,
    required this.onChanged,
    this.selectedValue,
  }) : super(key: key);

  @override
  _LocationsDropdownState createState() => _LocationsDropdownState();
}

class _LocationsDropdownState extends State<LocationsDropdown> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'اختيار الموقع',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          constraints: BoxConstraints(
            maxWidth: width * 0.6,
          ),
        ),
        items: widget.locations.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: widget.onChanged,
        value: widget.selectedValue,
      ),
    );
  }
}

class ProjectsDropdown extends StatefulWidget {
  final TextEditingController textEditingController;
  final List<String> projects;
  final ValueChanged<String?> onChanged;
  final String? selectedValue;
  const ProjectsDropdown({
    Key? key,
    required this.textEditingController,
    required this.projects,
    required this.onChanged,
    this.selectedValue,
  }) : super(key: key);

  @override
  _ProjectsDropdownState createState() => _ProjectsDropdownState();
}

class _ProjectsDropdownState extends State<ProjectsDropdown> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'اختيار المشروع',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          constraints: BoxConstraints(
            maxWidth: width * 0.6,
          ),
        ),
        items: widget.projects.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: widget.onChanged,
        value: widget.selectedValue,
      ),
    );
  }
}

class FolderWidget extends StatefulWidget {
  final String title;
  final ValueChanged<List<Map<String, String>>> onFilePicked;
  final List<Map<String, String>> fileUrls;

  const FolderWidget({
    Key? key,
    required this.title,
    required this.onFilePicked,
    required this.fileUrls,
  }) : super(key: key);

  @override
  _FolderWidgetState createState() => _FolderWidgetState();
}

class _FolderWidgetState extends State<FolderWidget> {
  bool _isOpen = false;

  void _toggleFolder() {
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.any);

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        if (file.path != null) {
          XFile pickedFile = XFile(file.path!);

          try {
            String fileUrl = await _uploadFileToFirebase(
                File(pickedFile.path), 'documents/${file.name}');
            widget.onFilePicked([
              {
                'name': file.name,
                'url': fileUrl,
              }
            ]);
          } catch (e) {
            print("Error uploading file: $e");
          }
        }
      }
    } catch (e) {
      print("Error picking file: $e");
    }
  }

  Future<String> _uploadFileToFirebase(File file, String path) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(path);
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception("Error uploading file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(widget.title),
          trailing: Icon(_isOpen ? Icons.expand_less : Icons.expand_more),
          onTap: _toggleFolder,
        ),
        if (_isOpen)
          Column(
            children: [
              ElevatedButton(
                onPressed: _pickFiles,
                child: const Text('ارفق الملفات'),
              ),
              const SizedBox(height: 16),
              ...widget.fileUrls.map((file) {
                return Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.insert_drive_file,
                          size: 40, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          file['name']!,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
      ],
    );
  }
}
