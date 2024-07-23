import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:hr_app/screens/employeeDetailsPage.dart';
import 'package:hr_app/screens/profile_screen.dart';
import 'package:hr_app/widgets/status_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hr_app/classes/employee.dart';
import 'package:hr_app/managers/firebaseHelper.dart';

class EmployeeList extends StatefulWidget {
  const EmployeeList({Key? key}) : super(key: key);

  @override
  State<EmployeeList> createState() => _EmployeeListState();
}

class _EmployeeListState extends State<EmployeeList> {
  final List<Map<String, dynamic>> _docs = [];
  final FirestoreManager _firestoreManager = FirestoreManager();
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('الموظفين');

  bool _loading = true;
  bool _isOpen = false;
  int _selectedIndex = -10;
  String _searchQuery = '';

  Employee _employee = Employee(
      name: "",
      department: "",
      endDate: "",
      enterDate: "",
      vacationsTime: "",
      number: "",
      image: "",
      job: "",
      status: "",
      rate: 0,
      salary: 0,
      nationality: "",
      relegion: "",
      vacations: "",
      salaryAlternatives: {},
      workStatus: "",
      finalJobPrize: "",
      workLocation: "");

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
    _simulateLoading();
  }

  Future<void> _fetchDocuments() async {
    final documents = await _firestoreManager.getAllDocuments("الموظفين");
    setState(() {
      _docs.addAll(documents);
    });
  }

  void _simulateLoading() {
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        _loading = false;
      });
    });
  }

  void _handleSearch(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _handleTap(int index, Map<String, dynamic> doc) {
    setState(() {
      _isOpen = true;
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredDocs = _docs
        .where((doc) =>
            doc['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
            doc['job'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
            doc['idNumber']
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            doc['status'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return _loading
        ? _buildLoadingScreen()
        : _isOpen && _selectedIndex != -10
            ? ProfileScreen(
                doc: _docs[_selectedIndex],
              ) //EmployeeDetailPage(doc: _docs[_selectedIndex])
            : _buildEmployeeList(filteredDocs);
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Lottie.asset(
        'assets/lottie/loading.json',
        height: 1200,
        width: 1200,
        fit: BoxFit.contain,
        repeat: false,
      ),
    );
  }

  Widget _buildEmployeeList(List<Map<String, dynamic>> filteredDocs) {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: ListView.builder(
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final doc = filteredDocs[index];
              return _buildEmployeeTile(index, doc);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: TextField(
          onChanged: _handleSearch,
          decoration: const InputDecoration(
            hintText: 'بحث...',
            border: InputBorder.none,
            icon: Icon(Icons.search),
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeTile(int index, Map<String, dynamic> doc) {
    final profileUrl = doc['imageUrl'] ?? '';
    final imageProvider = profileUrl.isNotEmpty
        ? NetworkImage(profileUrl)
        : AssetImage('assets/logo.png') as ImageProvider;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => _handleTap(index, doc),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: imageProvider,
              backgroundColor: Colors.white,
              radius: MediaQuery.of(context).size.height * 0.04,
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${doc['job']} :  ${doc['name']}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  doc['idNumber'],
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.normal),
                ),
              ],
            ),
            const SizedBox(width: 10),
            StatusContainer(status: doc['status']),
          ],
        ),
      ),
    );
  }
}
