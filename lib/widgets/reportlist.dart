// lib/widgets/reportList.dart

import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:hr_app/managers/firebaseHelper.dart';
import 'package:hr_app/widgets/status_container.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailReportedList extends StatefulWidget {
  final String reportType;
  final String collectionName;
  final String headline;
  final List<String> displayFields;
  final List<String> detailFields;
  final FirestoreManager firestoreManager;
  final Future<List<ParseObject>> Function(String) fetchGalleryList;

  const DetailReportedList({
    Key? key,
    required this.reportType,
    required this.collectionName,
    required this.headline,
    required this.displayFields,
    required this.detailFields,
    required this.firestoreManager,
    required this.fetchGalleryList,
  }) : super(key: key);

  @override
  _DetailReportedListState createState() => _DetailReportedListState();
}

class _DetailReportedListState extends State<DetailReportedList> {
  List<Map<String, dynamic>> docs = [];
  List<ParseObject> imagesList = [];

  @override
  void initState() {
    super.initState();
    widget.firestoreManager
        .getAllDocuments(widget.collectionName)
        .then((value) => setState(() {
              docs = value;
            }));
    widget.fetchGalleryList('profileImages').then((value) => setState(() {
          imagesList = value;
        }));
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildHeadline(widget.headline),
          ),
          _buildEmployeeList(docs),
        ],
      ),
    );
  }

  Text _buildHeadline(String headline) {
    return Text(
      headline,
      style: const TextStyle(
          fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 20),
    );
  }

  Widget _buildEmployeeList(List<Map<String, dynamic>> docs) {
    List<Widget> employeeWidgets = [];

    for (var doc in docs) {
      ParseFileBase? varFile = imagesList
          .firstWhere(
            (element) => element.objectId == doc['profile_image'],
            orElse: () => imagesList[1],
          )
          .get<ParseFileBase>('file');

      employeeWidgets.add(
        GestureDetector(
          onTap: () => _showReportDialog(context, doc, varFile),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                if (varFile != null)
                  CircleAvatar(
                    backgroundImage: NetworkImage(varFile.url!),
                    radius: MediaQuery.of(context).size.height * 0.055,
                  ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.displayFields
                      .map((field) => Text(
                            doc[field],
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ))
                      .toList(),
                ),
                const SizedBox(width: 10),
                StatusContainer(status: doc['status']),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: employeeWidgets,
    );
  }

  void _showReportDialog(
      BuildContext context, Map<String, dynamic> doc, ParseFileBase? varFile) {
    List<dynamic> list = [];
    List<dynamic> objectIds = [];

    widget.firestoreManager
        .getObjectId(widget.reportType, doc['name'], 'التقارير')
        .then((value) {
      setState(() {
        objectIds = value;
      });
    });

    widget.firestoreManager
        .getJobsInSubcollection(widget.reportType, doc['name'], 'التقارير')
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
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  "تقرير الاجازات",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              _buildReportEmployeeDetail(doc, varFile!.url!),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(list.length, (index) {
                                  return _buildReportListEntry(
                                      context, list, objectIds, index, show);
                                }),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: _buildDialogActions(context, setState, show),
                        ),
                      ],
                    ),
                  );
                },
              ),
              actions: const <Widget>[],
            ),
          );
        },
      );
    });
  }

  Widget _buildReportEmployeeDetail(Map<String, dynamic> doc, String imageUrl) {
    return Column(
      children: widget.detailFields.map((field) {
        return Text(
          doc[field],
          style: const TextStyle(fontSize: 18),
        );
      }).toList(),
    );
  }

  Widget _buildReportListEntry(BuildContext context, List<dynamic> list,
      List<dynamic> objectIds, int index, bool show) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Text(
            list[index],
            style: const TextStyle(fontSize: 18),
          ),
        ),
        if (show)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.download),
                    tooltip: "تحميل المستند",
                    onPressed: () async {
                      await widget.fetchGalleryList('vacation').then((value) {
                        for (final parseObject in value) {
                          if (parseObject.objectId == objectIds[index]) {
                            ParseFileBase? varFile =
                                parseObject.get<ParseFileBase>('file');
                            _launchUrl(Uri.parse(varFile!.url!));
                          }
                        }
                      });
                    },
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        const Divider(
          height: 2,
          thickness: 2,
        )
      ],
    );
  }

  Widget _buildDialogActions(
      BuildContext context, StateSetter setState, bool show) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (show)
          TextButton(
            onPressed: () {
              setState(() {
                show = false;
              });
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
    );
  }
}
