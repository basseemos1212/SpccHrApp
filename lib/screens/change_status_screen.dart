import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';

class ChangeStatusScreen extends StatefulWidget {
  const ChangeStatusScreen({super.key});

  @override
  State<ChangeStatusScreen> createState() => _ChangeStatusScreenState();
}

class _ChangeStatusScreenState extends State<ChangeStatusScreen> {
  String? _selectedEmployeeId;
  String? _selectedEmployeeName;
  String? _selectedEmployeeImage;
  String? _selectedStatus;

  final List<String> statuses = [
    'نشط',
    'غير نشط',
    'موقوف',
    'اجازه عمل',
    'اجازه مرضيه',
    'اجازه استثنائيه',
    'هروب',
    'خرج و لم يعد',
    'موقوف'
  ];

  final Map<String, Color> statusColors = {
    'نشط': Colors.green,
    'غير نشط': Colors.red,
    'معلق': Colors.orange,
    'موقوف': Colors.yellow,
    'منتهي': Colors.grey,
    'اجازه عمل': Colors.blue,
    'اجازه مرضيه': Colors.purple,
    'اجازه استثنائيه': Colors.cyan,
    'هروب': Colors.brown,
    'خرج و لم يعد': Colors.pink,
  };

  final Map<String, IconData> statusIcons = {
    'نشط': Icons.check_circle,
    'غير نشط': Icons.cancel,
    'معلق': Icons.hourglass_empty,
    'موقوف': Icons.pause_circle_filled,
    'منتهي': Icons.stop_circle,
    'اجازه عمل': Icons.work,
    'اجازه مرضيه': Icons.local_hospital,
    'اجازه استثنائيه': Icons.airline_seat_flat,
    'هروب': Icons.directions_run,
    'خرج و لم يعد': Icons.block,
  };

  Future<void> _fetchEmployeeDetails(String employeeName) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('الموظفين')
        .where('name', isEqualTo: employeeName)
        .get();
    if (result.docs.isNotEmpty) {
      final data = result.docs.first.data() as Map<String, dynamic>;
      setState(() {
        _selectedEmployeeId = result.docs.first.id;
        _selectedEmployeeName = data['name'];
        _selectedEmployeeImage = data['imageUrl'];
      });
    }
  }

  Future<void> _updateEmployeeStatus() async {
    if (_selectedEmployeeId != null && _selectedStatus != null) {
      try {
        await FirebaseFirestore.instance
            .collection('الموظفين')
            .doc(_selectedEmployeeId)
            .update({'status': _selectedStatus});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تحديث حالة الموظف بنجاح')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء تحديث البيانات: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى تحديد الموظف والحالة')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                const Text('تغيير حالة الموظف'),
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('الموظفين')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const CircularProgressIndicator();
                  var employeeList = snapshot.data!.docs.map((doc) {
                    return {
                      'id': doc.id,
                      'name': doc['name'],
                      'imageUrl': doc['imageUrl'],
                    };
                  }).toList();
                  return DropdownSearch<Map<String, dynamic>>(
                    items: employeeList,
                    itemAsString: (item) => item!['name'],
                    onChanged: (item) {
                      setState(() {
                        _selectedEmployeeName = item!['name'];
                        _selectedEmployeeImage = item['imageUrl'];
                        _fetchEmployeeDetails(_selectedEmployeeName!);
                      });
                    },
                    selectedItem: _selectedEmployeeName == null
                        ? null
                        : {
                            'name': _selectedEmployeeName,
                          },
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: 'اختر الموظف',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    popupProps: PopupProps.dialog(
                      showSearchBox: true,
                      itemBuilder: (context, item, isSelected) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: item['imageUrl'] != null
                                ? Image.network(item['imageUrl'],
                                    width: 50, height: 50, fit: BoxFit.cover)
                                : Image.asset('assets/profile.jpeg',
                                    width: 50, height: 50, fit: BoxFit.cover),
                            title: Text(item['name']),
                          ),
                        );
                      },
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          hintText: 'بحث',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: statuses.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final status = statuses[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStatus = status;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedStatus == status
                            ? statusColors[status]!.withOpacity(0.7)
                            : statusColors[status]!,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            statusIcons[status],
                            color: Colors.white,
                            size: 30,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _updateEmployeeStatus,
                  child: const Text('تحديث الحالة'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
