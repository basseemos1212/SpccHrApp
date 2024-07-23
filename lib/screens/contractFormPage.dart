import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:hr_app/components/colors.dart';
import 'package:hr_app/managers/firebaseHelper.dart';
import 'package:hr_app/widgets/customTextField.dart';
import 'package:hr_app/widgets/departmentDropDown.dart';
import 'package:hr_app/widgets/jobsDropDownMenu.dart';
import 'package:hr_app/widgets/locationDropDown.dart';
import 'package:hr_app/widgets/startServiceRow.dart';
import 'package:hr_app/widgets/uploadButton.dart';

class ContractFormPage extends StatefulWidget {
  static String galery = '';
  static String employee = '';
  const ContractFormPage({super.key});

  @override
  State<ContractFormPage> createState() => _ContractFormPageState();
}

class _ContractFormPageState extends State<ContractFormPage>
    with TickerProviderStateMixin {
  final FirestoreManager _firestoreManager = FirestoreManager();
  final _formKey = GlobalKey<FormState>();
  TextEditingController numberController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController nationalityController = TextEditingController();

  TextEditingController departmentTextEditingController =
      TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController workEndDateController = TextEditingController();
  TextEditingController vacationStatusController = TextEditingController();
  TextEditingController vacationTimeController = TextEditingController();
  TextEditingController mainSalaryController = TextEditingController();
  TextEditingController homeAlternativeSalaryController =
      TextEditingController();
  TextEditingController transportaionAlternativeSalaryController =
      TextEditingController();
  TextEditingController livingAlternativeSalaryController =
      TextEditingController();
  TextEditingController responsabilityAlternativeController =
      TextEditingController();
  TextEditingController plusAlternativeSalaryController =
      TextEditingController();
  TextEditingController jobController = TextEditingController();
  TextEditingController totalSalaryController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController idNumberController = TextEditingController();
  String? selectedLicenseType;
  String? selectedCarType;
  bool isStart = true;
  XFile? pickedFile;
  XFile? imageFile;
  bool isLoading = false;
  String date = "";
  dynamic emplyeeGallery = ParseObject("s");
  dynamic picGallery = ParseObject("s");
  ParseFileBase? employee;
  ParseFileBase? pic;
  String url = '';

  bool isProfileImageUploaded = false;
  bool isContractUploaded = false;

  final List<String> licenseTypes = [
    'خاصه',
    'نقل ثقيل',
    'عمومي',
    'لا يوجد',
  ];

  final List<String> carTypes = [
    'خاصه',
    'تابعه للشركه',
    'لا يوجد',
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    numberController.dispose();
    startDateController.dispose();
    departmentTextEditingController.dispose();
    locationTextEditingController.dispose();
    nameController.dispose();
    workEndDateController.dispose();
    vacationStatusController.dispose();
    vacationTimeController.dispose();
    mainSalaryController.dispose();
    homeAlternativeSalaryController.dispose();
    transportaionAlternativeSalaryController.dispose();
    livingAlternativeSalaryController.dispose();
    responsabilityAlternativeController.dispose();
    plusAlternativeSalaryController.dispose();
    jobController.dispose();
    totalSalaryController.dispose();
    codeController.dispose();
    idNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FadeTransition(
          opacity: _animation,
          child: ScaleTransition(
            scale: _animation,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: customText(),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            saveProfileImage();
                          },
                          child: Stack(
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                width: MediaQuery.of(context).size.height * 0.2,
                                decoration: BoxDecoration(
                                    color: Colors.black12,
                                    image: imageFile == null
                                        ? null
                                        : DecorationImage(
                                            image: FileImage(
                                                File(imageFile!.path)),
                                            fit: BoxFit.cover),
                                    borderRadius: BorderRadius.circular(15)),
                                child: Center(
                                  child: imageFile == null
                                      ? const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "ارفق صوره الموظف",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Icon(
                                              Icons.add,
                                              size: 30,
                                            )
                                          ],
                                        )
                                      : const SizedBox(),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: isProfileImageUploaded
                                      ? const Icon(Icons.check_circle,
                                          color: Colors.green)
                                      : const SizedBox(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            textEditingController: nameController,
                            isobsecureText: false,
                            hintText: "اسم الموظف",
                            isValidate: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'هذا الحقل مطلوب';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            textEditingController: codeController,
                            isobsecureText: false,
                            hintText: "كود الموظف",
                            isValidate: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'هذا الحقل مطلوب';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: IntlPhoneField(
                                controller: numberController,
                                enabled: true,
                                showCountryFlag: true,
                                languageCode: "ar",
                                decoration: InputDecoration(
                                  labelText: 'رقم الموظف',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.number.isEmpty) {
                                    return 'هذا الحقل مطلوب';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );

                              if (pickedDate != null) {
                                String formattedDate =
                                    "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                                setState(() {
                                  startDateController.text = formattedDate;
                                });
                              }
                            },
                            child: AbsorbPointer(
                              child: CustomTextField(
                                textEditingController: startDateController,
                                isobsecureText: false,
                                hintText: "التاريخ",
                                isValidate: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'هذا الحقل مطلوب';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            child: JobsDropdown(
                                textEditingController: jobController)),
                        const SizedBox(width: 16),
                        Expanded(
                            child: DepartmentsDropdown(
                                textEditingController:
                                    departmentTextEditingController)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            child: LocationsDropdown(
                                textEditingController:
                                    locationTextEditingController)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );

                              if (pickedDate != null) {
                                String formattedDate =
                                    "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                                setState(() {
                                  workEndDateController.text = formattedDate;
                                });
                              }
                            },
                            child: AbsorbPointer(
                              child: CustomTextField(
                                textEditingController: workEndDateController,
                                isobsecureText: false,
                                hintText: "تاريخ انتهاء العقد",
                                isValidate: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'هذا الحقل مطلوب';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            textEditingController: vacationStatusController,
                            isobsecureText: false,
                            hintText: "يملك اجازه بعد كم شهر من مباشرة العمل",
                            isValidate: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'هذا الحقل مطلوب';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            textEditingController: vacationTimeController,
                            isobsecureText: false,
                            hintText: "مده الاجازه السنويه",
                            isValidate: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'هذا الحقل مطلوب';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            textEditingController: mainSalaryController,
                            isobsecureText: false,
                            hintText: "الراتب الاساسي",
                            isValidate: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'هذا الحقل مطلوب';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            textEditingController:
                                homeAlternativeSalaryController,
                            isobsecureText: false,
                            hintText: "بدل السكن",
                            isValidate: false,
                            validator: (value) {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            textEditingController:
                                transportaionAlternativeSalaryController,
                            isobsecureText: false,
                            hintText: "بدل النقل",
                            isValidate: false,
                            validator: (value) {},
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            textEditingController:
                                livingAlternativeSalaryController,
                            isobsecureText: false,
                            hintText: "بدل الاعاشه",
                            isValidate: false,
                            validator: (value) {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            textEditingController:
                                responsabilityAlternativeController,
                            isobsecureText: false,
                            hintText: "بدل المسئوليه",
                            isValidate: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'هذا الحقل مطلوب';
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            textEditingController:
                                plusAlternativeSalaryController,
                            isobsecureText: false,
                            hintText: "بدل اضافي مقطوع",
                            isValidate: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'هذا الحقل مطلوب';
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            textEditingController: idNumberController,
                            isobsecureText: false,
                            hintText: "رقم الهويه",
                            isValidate: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'هذا الحقل مطلوب';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.22,
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: "نوع الرخصه",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
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
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.22,
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: "سياره",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                items: carTypes.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedCarType = newValue;
                                  });
                                },
                                value: selectedCarType,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: getTotalSalary,
                            child: CustomTextField(
                              textEditingController: totalSalaryController,
                              isobsecureText: false,
                              enable: false,
                              isValidate: true,
                              hintText: "اجمالي الراتب",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'هذا الحقل مطلوب';
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Stack(
                          children: [
                            UploadButton(
                              buttonText: "ارفق عقد الموظف",
                              onPressed: () async {
                                await saveToDB('employeecontracts', employee,
                                    emplyeeGallery, 1);
                              },
                              buttonColor: secondaryColor.withOpacity(0.6),
                              textColor: Colors.white,
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: isContractUploaded
                                    ? const Icon(Icons.check_circle,
                                        color: Colors.green)
                                    : const SizedBox(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomRow(date: date, isStart: isStart),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          customButton("اجمالي الراتب", getTotalSalary),
                          const SizedBox(width: 10),
                          customButton("حفظ بيانات الموظف", saveEmployeeData),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void saveEmployeeData() {
    if (_formKey.currentState?.validate() ?? false) {
      String name = nameController.text;
      String code = codeController.text;
      String number = numberController.text;
      String date = startDateController.text;
      String department = departmentTextEditingController.text;
      String job = jobController.text;
      String location = locationTextEditingController.text;
      String endDate = workEndDateController.text;
      String vacationStatus = vacationStatusController.text;
      String vacationTime = vacationTimeController.text;
      String mainSalary = mainSalaryController.text;
      String homeAltSalary = homeAlternativeSalaryController.text;
      String transportAlt = transportaionAlternativeSalaryController.text;
      String livingAltSalary = livingAlternativeSalaryController.text;
      String responsabilityAlt = responsabilityAlternativeController.text;
      String plusAltSalary = plusAlternativeSalaryController.text;
      String totalSalary = totalSalaryController.text;
      String idNumber = idNumberController.text;
      String licenseType = selectedLicenseType ?? 'لا يوجد';
      String carType = selectedCarType ?? 'لا يوجد';

      final employee = <String, dynamic>{
        "name": nameController.text,
        "code": codeController.text,
        "number": numberController.text,
        "date": startDateController.text,
        "department": departmentTextEditingController.text,
        "job": jobController.text,
        "location": locationTextEditingController.text,
        "endDate": workEndDateController.text,
        "vacationStatus": vacationStatusController.text,
        "vacationTime": vacationTimeController.text,
        "mainSalary": mainSalaryController.text,
        "homeAltSalary": homeAlternativeSalaryController.text,
        "workStatus": "لم تتم مباشره العمل بعد",
        "status": "موقوف",
        "transportAlt": transportaionAlternativeSalaryController.text,
        "livingAltSalary": livingAlternativeSalaryController.text,
        "responsabilityAlt": responsabilityAlternativeController.text,
        "plusAltSalary": plusAlternativeSalaryController.text,
        "totalSalary": totalSalaryController.text,
        "idNumber": idNumberController.text,
        "licenseType": licenseType,
        "carType": carType,
        "isStart": isStart,
        "startDate": date,
        "rate": 0,
        "employment_contract": ContractFormPage.employee,
        "profile_image": ContractFormPage.galery,
        "profile_url": url
      };

      _firestoreManager.addDocument("الموظفين", employee).then((value) {
        showDialog(
          context: context,
          builder: (context) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: const Text('نجاح'),
                content: const Text('تمت الاضافه بنجاح'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('حسناً'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      });
    }
  }

  Future<void> saveProfileImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        imageFile = XFile(file.path.toString());
        pickedFile = XFile(file.path.toString());
      });

      ParseFileBase parseFile;
      if (kIsWeb) {
        parseFile = ParseWebFile(await pickedFile!.readAsBytes(),
            name: pickedFile!.name);
      } else {
        parseFile = ParseFile(File(pickedFile!.path));
      }

      await parseFile.save();
      picGallery = ParseObject("profileImages")
        ..set('file', parseFile, forceUpdate: true);
      await picGallery.save();

      setState(() {
        ContractFormPage.galery = picGallery.objectId;
        isProfileImageUploaded = true;
      });

      String profileImageUrl = parseFile.url!;
      url = profileImageUrl;
    }
  }

  Future<void> saveToDB(String className, ParseFileBase? parseFile,
      dynamic gallery, int mode) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: className == "profileImages" ? FileType.image : FileType.any);

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        pickedFile = XFile(file.path.toString());
      });

      if (kIsWeb) {
        parseFile = ParseWebFile(await pickedFile!.readAsBytes(),
            name: pickedFile!.name);
      } else {
        parseFile = ParseFile(File(pickedFile!.path));
      }

      await parseFile.save();
      gallery = ParseObject(className)
        ..set('file', parseFile, forceUpdate: true);
      await gallery.save();

      if (mode == 1) {
        setState(() {
          ContractFormPage.employee = gallery.objectId;
          isContractUploaded = true;
        });
      } else {
        setState(() {
          ContractFormPage.galery = gallery.objectId;
          isProfileImageUploaded = true;
        });
      }
    }
  }

  getTotalSalary() {
    setState(() {
      int total = 0;
      if (mainSalaryController.text.isNotEmpty) {
        total += int.parse(mainSalaryController.text);
        totalSalaryController.text = total.toString();
      }
      if (homeAlternativeSalaryController.text.isNotEmpty) {
        total += int.parse(homeAlternativeSalaryController.text);
        totalSalaryController.text = total.toString();
      }
      if (transportaionAlternativeSalaryController.text.isNotEmpty) {
        total += int.parse(transportaionAlternativeSalaryController.text);
        totalSalaryController.text = total.toString();
      }
      if (livingAlternativeSalaryController.text.isNotEmpty) {
        total += int.parse(livingAlternativeSalaryController.text);
        totalSalaryController.text = total.toString();
      }
      if (responsabilityAlternativeController.text.isNotEmpty) {
        total += int.parse(responsabilityAlternativeController.text);
        totalSalaryController.text = total.toString();
      }
      if (plusAlternativeSalaryController.text.isNotEmpty) {
        total += int.parse(plusAlternativeSalaryController.text);
        totalSalaryController.text = total.toString();
      }
    });
  }

  ElevatedButton customButton(String text, VoidCallback function) {
    return ElevatedButton(
      onPressed: function,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Container(
        alignment: Alignment.center,
        width: 140,
        height: 50,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Text customText() {
    return const Text(
      "إضافة الموظف",
      textAlign: TextAlign.start,
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}
