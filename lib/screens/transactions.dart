import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hr_app/classes/departments.dart';
import 'package:hr_app/classes/employee.dart';
import 'package:hr_app/classes/job.dart';
import 'package:hr_app/classes/project.dart';
import 'package:hr_app/classes/workLocation.dart';
import 'package:hr_app/components/colors.dart';
import 'package:hr_app/screens/TestScreen.dart';
import 'package:hr_app/screens/add_employee_files.dart';
import 'package:hr_app/screens/apply_transaction.dart';
import 'package:hr_app/screens/asset_delievery_form.dart';
import 'package:hr_app/screens/change_status_screen.dart';
import 'package:hr_app/screens/contractFormPage.dart';
import 'package:hr_app/screens/deliver_advance_payment.dart';
import 'package:hr_app/screens/deliver_salary.dart';
import 'package:hr_app/screens/home_alt_screen.dart';
import 'package:hr_app/screens/house_allowance.dart';
import 'package:hr_app/screens/rating_transaction.dart';
import 'package:hr_app/screens/recieve_advance_payment.dart';
import 'package:hr_app/screens/reciever_asset_form.dart';
import 'package:hr_app/screens/responsabiltyAcceptanceScreen.dart';
import 'package:hr_app/screens/responsabiltyScreen.dart';
import 'package:hr_app/screens/stepper_form.dart';
import 'package:hr_app/screens/transefer_employee.dart';
import 'package:hr_app/screens/upgrade_salary.dart';
import 'package:hr_app/screens/vacation_request_form.dart';
import 'package:hr_app/screens/vacation_return_form.dart';
import 'package:hr_app/widgets/employee_transaction_list.dart';

const List<Color> colorPalette = [
  Colors.lightBlue, // Light Blue
  Colors.lightGreen, // Light Green
  Colors.orangeAccent, // Orange
];

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
  Icons.handshake, // for "اتسلام سلفه"
  Icons.business_center, // for "تسليم عهده"
  Icons.receipt, // for "استلام عهده"
  Icons.beach_access, // for "ذهاب اجازه"
  Icons.flight_land, // for "عودة اجازه"
  Icons.upload_file, // for "اضافه ملفات الموظف
];

const List<String> transactionList = [
  "إضافة موظف",
  "مباشره عمل",
  "تقيم الموظفين",
  "ترقيه راتب الموظف",
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
  "استلام سلفه",
  "تسليم عهده",
  "استلام عهده",
  "ذهاب اجازه",
  "عودة اجازه",
  "اضافه ملفات الموظف"
];

class Transactions extends StatefulWidget {
  final String direction;
  const Transactions({Key? key, required this.direction}) : super(key: key);

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions>
    with TickerProviderStateMixin {
  bool isOpen = false;
  int selectedIndex = -1;
  int expandedIndex = -1;
  String searchQuery = '';
  late List<AnimationController> _controllers;
  late List<Animation<double>> _opacityAnimations;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _controllers =
        List<AnimationController>.generate(transactionList.length, (index) {
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

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = transactionList
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
                        'المعاملات',
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
          if (isOpen)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isOpen = !isOpen;
                    selectedIndex = -1;
                  });
                },
                child: selectedIndex == 0
                    ? const SizedBox()
                    : const Icon(
                        Icons.arrow_back,
                        color: primaryColor,
                        size: 25,
                      ),
              ),
            ),
          if (isOpen)
            Expanded(
              child: _getSelectedScreen(selectedIndex),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(filteredList.length + 5, (index) {
                      if (index < 3) {
                        return _buildAnimatedGridItem(filteredList[index],
                            transactionIcons[index], index);
                      } else if (index == 3) {
                        return _buildExpandableContainer(
                          'تحركات الموظف',
                          Icons.directions_walk,
                          [
                            _buildAnimatedGridItem(
                                filteredList[3], transactionIcons[3], 3,
                                isChild: true),
                            _buildAnimatedGridItem(
                                filteredList[4], transactionIcons[4], 4,
                                isChild: true),
                          ],
                          3,
                        );
                      } else if (index == 9) {
                        return _buildAnimatedGridItem(
                            filteredList[19], transactionIcons[19], 14);
                      } else if (index == 4) {
                        return _buildAnimatedGridItem(
                            filteredList[5], transactionIcons[5], 5);
                      } else if (index == 5) {
                        return _buildAnimatedGridItem(
                          'حاله الموظف',
                          Icons.person,
                          6,
                        );
                      } else if (index == 6) {
                        return _buildExpandableContainer(
                          'ماليات',
                          Icons.money,
                          [
                            _buildAnimatedGridItem(
                                filteredList[12], transactionIcons[12], 7,
                                isChild: true),
                            _buildAnimatedGridItem(
                                filteredList[13], transactionIcons[13], 8,
                                isChild: true),
                            _buildAnimatedGridItem(
                                filteredList[14], transactionIcons[14], 9,
                                isChild: true),
                          ],
                          11,
                        );
                      } else if (index == 7) {
                        return _buildExpandableContainer(
                          'العهد',
                          Icons.business_center,
                          [
                            _buildAnimatedGridItem(
                                filteredList[15], transactionIcons[15], 10,
                                isChild: true),
                            _buildAnimatedGridItem(
                                filteredList[16], transactionIcons[16], 11,
                                isChild: true),
                          ],
                          13,
                        );
                      } else if (index == 8) {
                        return _buildExpandableContainer(
                          'الاجازه',
                          Icons.beach_access,
                          [
                            _buildAnimatedGridItem(
                                filteredList[17], transactionIcons[17], 12,
                                isChild: true),
                            _buildAnimatedGridItem(
                                filteredList[18], transactionIcons[18], 13,
                                isChild: true),
                          ],
                          15,
                        );
                      } else {
                        return Container();
                      }
                    }),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedGridItem(String title, IconData icon, int index,
      {bool isChild = false}) {
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
      child: InkWell(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });

          switch (selectedIndex) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StepperForm()),
              );
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const StartWorkTransaction(
                          transaction: "startWork",
                        )),
              );
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RatingTransaction()),
              );
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UpgradeSalary()),
              );
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TransferEmployee()),
              );
            case 5:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HousingAllowanceScreen()),
              );
            case 6:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ChangeStatusScreen()),
              );
            case 7:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DeliverSalary()),
              );
            case 8:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DeliverAdvancePayment()),
              );
            case 9:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ReceiveAdvancePayment()),
              );
            case 10:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AssetDeliveryForm()),
              );
            case 11:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ReceiveAssetForm()),
              );
            case 12:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const VacationRequestForm()),
              );
            case 13:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const VacationReturnForm()),
              );
            case 14:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddEmployeeFiles()),
              );

            default:
              print(selectedIndex);
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width / 6,
          height: isChild
              ? MediaQuery.of(context).size.width / 10
              : MediaQuery.of(context).size.width / 6,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20), // Adjust the border radius
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 36, color: Colors.white), // Adjusted icon size
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14, // Adjusted font size
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableContainer(
      String title, IconData icon, List<Widget> children, int index) {
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
          if (mounted) {
            setState(() {
              expandedIndex = (expandedIndex == index) ? -1 : index;
            });
          }
        },
        child: AnimatedSize(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          child: Container(
            width: MediaQuery.of(context).size.width / 6,
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.width / 6,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius:
                  BorderRadius.circular(20), // Adjust the border radius
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon,
                        size: 36, color: Colors.white), // Adjusted icon size
                    const SizedBox(width: 8),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14, // Adjusted font size
                      ),
                    ),
                  ],
                ),
                if (expandedIndex == index)
                  Column(
                    children: children,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getSelectedScreen(int index) {
    switch (index) {
      case 0:
        return StepperForm();
      case 1:
        return const StartWorkTransaction(
          transaction: "startWork",
        );
      case 2:
        return const EmployeeTransactionList(transaction: "editRate");
      case 3:
        return const EmployeeTransactionList(transaction: "upgradeSalary");
      case 4:
        return const EmployeeTransactionList(transaction: "transportEmployee");
      case 5:
        return const HomeAltcreen();
      case 6:
        return const EmployeeTransactionList(transaction: "run");
      case 7:
        return const EmployeeTransactionList(transaction: "workInjury");
      case 8:
        return const EmployeeTransactionList(transaction: "stopWorkInjury");
      case 9:
        return const EmployeeTransactionList(transaction: "stopEmployee");
      case 10:
        return const EmployeeTransactionList(transaction: "activate");
      case 11:
        return const EmployeeTransactionList(transaction: "out");
      case 12:
        return const EmployeeTransactionList(transaction: "paySalary");
      case 13:
        return const EmployeeTransactionList(transaction: "advancePayment");
      case 14:
        return const ResponsabiltyDeliveryScreen();
      case 15:
        return const ResponsabiltyAcceptanceScreen();
      case 16:
        return const EmployeeTransactionList(transaction: "requestVacation");
      case 17:
        return const EmployeeTransactionList(transaction: "endVacation");
      case 18:
        return TestScreen();
      default:
        return Container();
    }
  }
}
