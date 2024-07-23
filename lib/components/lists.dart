import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hr_app/classes/departments.dart';
import 'package:hr_app/classes/employee.dart';
import 'package:hr_app/classes/job.dart';
import 'package:hr_app/classes/project.dart';
import 'package:hr_app/classes/workLocation.dart';

List<Color> generateRandomGradient() {
  final Random random = Random();
  final int baseColorValue = 150 +
      random.nextInt(55); // Generate a base color closer to blue but darker
  final Color color1 = Color.fromARGB(255, baseColorValue, baseColorValue, 255);
  final Color color2 = Color.fromARGB(
      255, 50 + random.nextInt(100), 50 + random.nextInt(100), 200);
  return [color1, color2];
}

const List<IconData> transactionIcons = [
  Icons.person_add, // for "إضافة موظف"
  Icons.work, // for "مباشره عمل"
  Icons.star, // for "تقيم الموظفين"
  Icons.upgrade, // for "ترقيه موظف"
  Icons.transfer_within_a_station, // for "نقل موظف"
  Icons.home, // for "بدلات سكن"
  Icons.run_circle, // for "هروب"
  Icons.healing, // for "اصابات العمل"
  Icons.local_hospital, // for "انهاء اصابه عمل"
  Icons.block, // for "إيقاف موظف"
  Icons.check_circle, // for "إنهاء إيقاف موظف"
  Icons.exit_to_app, // for "خرج و لم يعد"
  Icons.attach_money, // for "تسليم راتب"
  Icons.money, // for "تسليم سلفه"
  Icons.business_center, // for "تسليم عهده"
  Icons.receipt, // for "استلام عهده"
  Icons.beach_access, // for "ذهاب اجازه"
  Icons.flight_land, // for "عودة اجازه"
];

const List<String> transactionList = [
  "إضافة موظف",
  "مباشره عمل",
  "تقيم الموظفين",
  "ترقيه موظف",
  "نقل موظف",
  "بدلات سكن",
  "هروب",
  "اصابات العمل",
  "انهاء اصابه عمل",
  "إيقاف موظف",
  "إنهاء إيقاف موظف",
  "خرج و لم يعد",
  "تسليم راتب",
  "تسليم سلفه",
  "تسليم عهده",
  "استلام عهده",
  "ذهاب اجازه",
  "عودة اجازه",
];

const List<String> formsList = [
  "نماذج إدارية",
  "نماذج ماليه",
  "نماذج حكوميه",
];

const List<String> filesList = [
  "الموظفين",
  "الإدارات",
  "المواقع",
  "الوظائف",
];

const List<String> reportsList = [
  "تقارير حركه الموظف",
  "تقارير الماليه للموظف",
  "تقارير الاصول للموظف",
  "إصابات العمل",
  "تقارير الاجازات للموظفين",
];
final List<Employee> employees = [
  Employee(
      name: "مهندس محمد سعيد",
      department: "اداره الشركه",
      endDate: "20/12/2025",
      enterDate: "20/1/2024",
      vacationsTime: "1/1/2026",
      number: "555-555-5555",
      image: "assets/profile.jpeg",
      job: "مدير الموارد البشريه",
      status: "تمت مباشره العمل يوم 13/11/2023",
      rate: 3,
      salary: 7000,
      nationality: "سعودي",
      relegion: "مسلم",
      vacations: "يستحق اجازه يوم 5/5/2024",
      salaryAlternatives: {},
      workStatus: "workStatus",
      finalJobPrize: "250000",
      workLocation: "المقر الرئيسي"),
  Employee(
      name: "مهندس محمد سعيد",
      department: "اداره الشركه",
      endDate: "20/12/2025",
      enterDate: "20/1/2024",
      vacationsTime: "1/1/2026",
      number: "555-555-5555",
      image: "assets/profile.jpeg",
      job: "مدير الموارد البشريه",
      status: "تمت مباشره العمل يوم 13/11/2023",
      rate: 3,
      salary: 7000,
      nationality: "سعودي",
      relegion: "مسلم",
      vacations: "يستحق اجازه يوم 5/5/2024",
      salaryAlternatives: {},
      workStatus: "workStatus",
      finalJobPrize: "250000",
      workLocation: "المقر الرئيسي"),
  Employee(
      name: "مهندس محمد سعيد",
      department: "اداره الشركه",
      endDate: "20/12/2025",
      enterDate: "20/1/2024",
      vacationsTime: "1/1/2026",
      number: "555-555-5555",
      image: "assets/profile.jpeg",
      job: "مدير الموارد البشريه",
      status: "تمت مباشره العمل يوم 13/11/2023",
      rate: 3,
      salary: 7000,
      nationality: "سعودي",
      relegion: "مسلم",
      vacations: "يستحق اجازه يوم 5/5/2024",
      salaryAlternatives: {},
      workStatus: "workStatus",
      finalJobPrize: "250000",
      workLocation: "المقر الرئيسي"),
];
final List<Departments> departmentsList = [
  Departments(
      name: "إدارة الموارد البشريه",
      manager: "مهندس محمد سعيد",
      location: "مقر الشركه",
      projects: [
        Project(
            name: "مشروع س", department: "اداره المشاريع", employees: employees)
      ]),
  Departments(
      name: "إدارة المعدات",
      manager: "مهندس س",
      location: "مقر الشركه",
      projects: [
        Project(
            name: "مشروع س",
            department: "اداره المشاريع",
            employees: employees),
        Project(
            name: "مشروع ص", department: "اداره المشاريع", employees: employees)
      ]),
  Departments(
      name: "إدارة المشتريات و العقود",
      manager: "مهندس س",
      location: "مقر الشركه",
      projects: [
        Project(
            name: "مشروع س",
            department: "اداره المشاريع",
            employees: employees),
        Project(
            name: "مشروع ص", department: "اداره المشاريع", employees: employees)
      ]),
  Departments(
      name: "إداره الماليات",
      manager: "مهندس س",
      location: "مقر الشركه",
      projects: [
        Project(
            name: "مشروع س",
            department: "اداره المشاريع",
            employees: employees),
        Project(
            name: "مشروع ص", department: "اداره المشاريع", employees: employees)
      ]),
  Departments(
      name: "إدارة المكتب الفني",
      manager: "مهندس س",
      location: "مقر الشركه",
      projects: [
        Project(
            name: "مشروع س",
            department: "اداره المشاريع",
            employees: employees),
        Project(
            name: "مشروع ص", department: "اداره المشاريع", employees: employees)
      ])
];
final List<WorkLocation> workLocationsList = [
  WorkLocation(
      name: "جده", department: "إداره المشاريع", employeeList: employees),
  WorkLocation(
      name: "الرياض", department: "إداره الماليات", employeeList: employees),
  WorkLocation(
      name: "موقع الخبر", department: "إدارة المعدات", employeeList: employees),
  WorkLocation(
      name: "اداره الشركه",
      department: "إدارة المعدات",
      employeeList: employees)
];
final List<Job> jobList = [
  Job(
      name: "مدير مشروع",
      department: "إداره الماليات",
      employeeList: employees),
  Job(
      name: "مهندس معماري",
      department: "إداره الماليات",
      employeeList: employees),
  Job(name: "مهندس مدني", department: "department", employeeList: employees),
  Job(name: "مراقب موقع", department: "department", employeeList: employees),
  Job(name: "مهندس كهربائي", department: "department", employeeList: employees),
  Job(
      name: "مهندس ميكانيكي",
      department: "department",
      employeeList: employees),
  Job(name: "مسؤول مشتريات", department: "department", employeeList: employees),
  Job(
      name: "مسؤول تخطيط وجدولة",
      department: "department",
      employeeList: employees),
  Job(
      name: "مهندس تصميم داخلي",
      department: "department",
      employeeList: employees),
  Job(name: "فني تنفيذي", department: "department", employeeList: employees),
  Job(
      name: "مدير سلامة وصحة مهنية",
      department: "department",
      employeeList: employees),
  Job(name: "مهندس إنشاءات", department: "department", employeeList: employees),
  Job(
      name: "مدير عمليات الموقع",
      department: "department",
      employeeList: employees),
  Job(name: "مسؤول جودة", department: "department", employeeList: employees),
  Job(name: "محاسب مالي", department: "department", employeeList: employees)
];
final List<String> jobNamesList = jobList.map((job) => job.name).toList();
final List<String> workLocationNamesList =
    workLocationsList.map((workLocation) => workLocation.name).toList();
final List<String> departmentNamesList =
    departmentsList.map((department) => department.name).toList();
