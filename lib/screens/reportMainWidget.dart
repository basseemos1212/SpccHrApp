import 'dart:io';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:hr_app/components/colors.dart';
import 'package:hr_app/managers/firebaseHelper.dart';
import 'package:hr_app/widgets/status_container.dart';
import 'package:screenshot/screenshot.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';

class ReportMainWidget extends StatefulWidget {
  final String collectionName;
  final String reportTitle;

  const ReportMainWidget({
    super.key,
    required this.collectionName,
    required this.reportTitle,
  });

  @override
  State<ReportMainWidget> createState() => _ReportMainWidgetState();
}

class _ReportMainWidgetState extends State<ReportMainWidget> {
  List<Map<String, dynamic>> docs = [];
  List<Map<String, dynamic>> filteredDocs = [];
  final FirestoreManager _firestoreManager = FirestoreManager();
  Uri _url = Uri();
  ScreenshotController screenshotController = ScreenshotController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  Future<void> _fetchDocuments() async {
    final documents = await _firestoreManager.getAllDocuments("الموظفين");
    setState(() {
      docs = documents;
      filteredDocs = documents; // Initialize filteredDocs with all documents
    });
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  void _handleSearch(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      filteredDocs = docs.where((doc) {
        return doc.values.any(
            (value) => value.toString().toLowerCase().contains(lowerCaseQuery));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
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
                onChanged: _handleSearch,
                decoration: const InputDecoration(
                  hintText: 'بحث...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: headLine(widget.reportTitle),
                ),
                generateEmployeeList(filteredDocs),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Text headLine(String headLine) {
    return Text(
      headLine,
      style: const TextStyle(
          fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 20),
    );
  }

  Widget generateEmployeeList(List<dynamic> docs) {
    return Column(
      children: docs.map((doc) {
        final profileUrl = doc['imageUrl'] ?? '';
        final imageProvider = profileUrl.isNotEmpty
            ? NetworkImage(profileUrl)
            : AssetImage('assets/profile.jpeg') as ImageProvider;

        return GestureDetector(
          onTap: () => _showEmployeeReportDialog(doc, profileUrl),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: imageProvider,
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
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      doc['number'],
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                StatusContainer(status: doc['status']),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showEmployeeReportDialog(Map<String, dynamic> doc, String profileUrl) {
    List<dynamic> list = [];

    _firestoreManager
        .getJobsInSubcollection(widget.collectionName, doc['name'], 'التقارير')
        .then((value) {
      setState(() {
        list = value;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          bool show = true;
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Screenshot(
              controller: screenshotController,
              child: AlertDialog(
                content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height * 0.9,
                      child: Stack(
                        children: [
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Image(
                              image: AssetImage('assets/logo.png'),
                            ),
                          ),
                          SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    widget.collectionName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ReportEmployeeDetail(doc: doc, url: profileUrl),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(list.length, (index) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 20),
                                          child: Text(
                                            list[index],
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                        const Divider(
                                          height: 2,
                                          thickness: 2,
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (show)
                                  TextButton(
                                    onPressed: () async {
                                      setState(() {
                                        show = false;
                                      });
                                      const imagePath = 'F:/';
                                      await screenshotController.captureAndSave(
                                        imagePath,
                                        fileName: 'screenshot.png',
                                      );
                                      final file = File(imagePath);

                                      // Print the file
                                      await Printing.layoutPdf(
                                        onLayout:
                                            (PdfPageFormat format) async =>
                                                file.readAsBytesSync(),
                                      );
                                    },
                                    child: const Text('طباعه التقرير'),
                                  ),
                                if (show)
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('غلق'),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                actions: const <Widget>[],
              ),
            ),
          );
        },
      );
    });
  }

  Future<List<ParseObject>> getGalleryList(String className) async {
    QueryBuilder<ParseObject> queryPublisher =
        QueryBuilder<ParseObject>(ParseObject(className))
          ..orderByAscending('createdAt');
    final ParseResponse apiResponse = await queryPublisher.query();

    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
  }
}

class ReportEmployeeDetail extends StatelessWidget {
  final Map<String, dynamic> doc;
  final String url;

  const ReportEmployeeDetail({super.key, required this.doc, required this.url});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.15,
          width: MediaQuery.of(context).size.height * 0.15,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: url.isNotEmpty
                    ? NetworkImage(url)
                    : AssetImage('assets/profile.jpeg') as ImageProvider,
                fit: BoxFit.fill,
              )),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "الوظيفة: ${doc['job'] ?? 'غير متوفر'}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "الاسم: ${doc['name'] ?? 'غير متوفر'}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "كود الموظف: ${doc['code'] ?? 'غير متوفر'}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "تاريخ مباشره العمل: ${doc['projectStartWork'] ?? 'غير متوفر'}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
