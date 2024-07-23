import 'package:flutter/material.dart';
import 'package:hr_app/menu/menu_details.dart';
import 'package:hr_app/screens/downloadEmployeeData.dart';
import 'package:hr_app/screens/files.dart';
import 'package:hr_app/screens/reports.dart';
import 'package:hr_app/screens/transactions.dart';

class MenuItems {
  List<MenuDetails> items = [
    MenuDetails(
        title: "معاملات",
        icon: Icons.monetization_on,
        widget: const Transactions(
          direction: 'menu',
        )),
    MenuDetails(
        title: "ملفات",
        icon: Icons.folder_copy,
        widget: const Files(
          direction: '',
        )),
    MenuDetails(
        title: "تقارير",
        icon: Icons.description,
        widget: const Reports(
          direction: '',
        )),
    MenuDetails(
        title: "تحميل بيانات الموظف",
        icon: Icons.download_for_offline_sharp,
        widget: const DownloadEmployeeData(
          direction: '',
        )),
  ];
}
