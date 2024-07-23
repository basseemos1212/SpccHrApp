import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingTransaction extends StatefulWidget {
  const RatingTransaction({super.key});

  @override
  State<RatingTransaction> createState() => _RatingTransactionState();
}

class _RatingTransactionState extends State<RatingTransaction>
    with SingleTickerProviderStateMixin {
  String? _selectedEmployeeId;
  String? _selectedEmployeeName;
  String? _selectedEmployeeImage;
  String? _selectedMonth;
  double? _currentRating;
  List<double> _ratings = List<double>.filled(5, 0.0);
  double _averageRating = 0.0;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
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

  void _calculateAverageRating() {
    setState(() {
      _averageRating = _ratings.reduce((a, b) => a + b) / _ratings.length;
    });
  }

  Future<void> _fetchEmployeeRating() async {
    if (_selectedEmployeeId != null) {
      final employeeDoc = await FirebaseFirestore.instance
          .collection('الموظفين')
          .doc(_selectedEmployeeId)
          .get();
      setState(() {
        _currentRating = employeeDoc['rating']?.toDouble() ?? 0.0;
        _controller.reset();
        _controller.forward();
      });
    }
  }

  Future<void> _submitRating() async {
    try {
      if (_selectedEmployeeId != null && _selectedMonth != null) {
        await FirebaseFirestore.instance
            .collection('الموظفين')
            .doc(_selectedEmployeeId)
            .update({
          "rating": _averageRating,
          "monthlyRatings": {
            _selectedMonth!: _averageRating,
          },
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تحديث تقييم الموظف بنجاح')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تحديث التقييم')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

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
                const Text(
                  'تقييم موظف',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'اختيار الموظف',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
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
                        _selectedEmployeeId = item!['id'];
                        _selectedEmployeeName = item['name'];
                        _selectedEmployeeImage = item['imageUrl'];
                        _fetchEmployeeRating();
                      });
                    },
                    selectedItem: _selectedEmployeeName == null
                        ? null
                        : {
                            'id': _selectedEmployeeId,
                            'name': _selectedEmployeeName
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
              const Text(
                'اختيار الشهر',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                isExpanded: true,
                value: _selectedMonth,
                items: months.map((String month) {
                  return DropdownMenuItem<String>(
                    value: month,
                    child: Text(month),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedMonth = newValue;
                  });
                },
                hint: const Text('اختر الشهر'),
              ),
              const SizedBox(height: 20),
              if (_currentRating != null) ...[
                Text(
                  'التقييم الحالي: ${_currentRating!.toStringAsFixed(1)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return RatingBarIndicator(
                      rating: (_currentRating! * _animation.value).clamp(0, 5),
                      itemBuilder: (context, index) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 40.0,
                      direction: Axis.horizontal,
                    );
                  },
                ),
              ],
              const SizedBox(height: 20),
              if (_selectedEmployeeId != null && _selectedMonth != null) ...[
                const Text(
                  'تقييم الموظف',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRatingBar('تقيم اخلاقي', 0),
                    _buildRatingBar('الالتزام بالتعليمات', 1),
                    _buildRatingBar('تقيم الاداء', 2),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRatingBar("العمل مع الفريق", 3),
                    _buildRatingBar("التزام المواعيد", 4),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTotalRatingBar(),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitRating,
                    child: Text('تحديث التقييم'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingBar(String title, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
        RatingBar.builder(
          initialRating: _ratings[index],
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: false,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {
            setState(() {
              _ratings[index] = rating;
              _calculateAverageRating();
            });
          },
        ),
      ],
    );
  }

  Widget _buildTotalRatingBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'إجمالي التقييم',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        RatingBarIndicator(
          rating: _averageRating,
          itemBuilder: (context, index) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          itemCount: 5,
          itemSize: 40.0,
          direction: Axis.horizontal,
        ),
      ],
    );
  }
}
