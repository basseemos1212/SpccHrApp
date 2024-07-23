import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:hr_app/components/colors.dart';
import 'package:hr_app/managers/firebaseHelper.dart';
import 'package:hr_app/screens/employeeDataPage.dart';
import 'package:hr_app/widgets/uploadButton.dart';
import 'package:url_launcher/url_launcher.dart';

class EmployeeDetailPage extends StatefulWidget {
  final Map<String, dynamic>? doc;
  EmployeeDetailPage({Key? key, this.doc}) : super(key: key);

  @override
  State<EmployeeDetailPage> createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends State<EmployeeDetailPage> {
  Uri _url = Uri();
  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  final FirestoreManager _firestoreManager = FirestoreManager();
  bool isBack = false;

  @override
  Widget build(BuildContext context) {
    String name = widget.doc?['name'] ?? 'لا يوجد';
    String idNumber = widget.doc?['idNumber'] ?? 'لا يوجد';
    String job = widget.doc?['job'] ?? 'لا يوجد';
    String workStatus = widget.doc?['workStatus'] ?? 'لا يوجد';
    String licenseType = widget.doc?['licenseType'] ?? 'لا يوجد';
    String carType = widget.doc?['carType'] ?? 'لا يوجد';
    String imageUrl = widget.doc?['imageUrl'] ?? '';
    String enterDate = widget.doc?['startDate'] ?? 'لا يوجد';
    String salary = widget.doc?['mainSalary']?.toString() ?? 'لا يوجد';
    String vacations = widget.doc?['vacationStatus'] ?? 'لا يوجد';
    String vacationsTime = widget.doc?['vacationDuration'] ?? 'لا يوجد';
    String workLocation = widget.doc?['location'] ?? 'لا يوجد';
    String finalJobPrize = "لم يتم حسابها بعد";
    double rate = double.parse(widget.doc?['rate']?.toString() ?? '0');
    String housingAllowance =
        widget.doc?["housingAllowance"]?.toString() ?? 'لا يوجد';
    String livingAllowance =
        widget.doc?["livingAllowance"]?.toString() ?? 'لا يوجد';
    String transportAllowance =
        widget.doc?["transportAllowance"]?.toString() ?? 'لا يوجد';
    String extraAllowance =
        widget.doc?["extraAllowance"]?.toString() ?? 'لا يوجد';
    String responsibilityAllowance =
        widget.doc?["responsibilityAllowance"]?.toString() ?? 'لا يوجد';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isBack
            ? const EmployeeDataPage()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.height * 0.03),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isBack = true;
                                });
                              },
                              child: const Icon(
                                Icons.arrow_back,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            CircleAvatar(
                              backgroundImage: imageUrl.isNotEmpty
                                  ? NetworkImage(imageUrl)
                                  : const AssetImage('assets/logo.png')
                                      as ImageProvider,
                              radius: 30,
                              backgroundColor: Colors.white,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              name,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  UploadButton(
                                    buttonText: "عقد الموظف",
                                    onPressed: () async {
                                      // await getGalleryList('employeecontracts')
                                      //     .then((value) {
                                      //   for (final parseobject in value) {
                                      //     if (parseobject.objectId.toString() ==
                                      //         widget.doc?['employment_contract']
                                      //             .toString()) {
                                      //       ParseFileBase? varFile = parseobject
                                      //           .get<ParseFileBase>('file');
                                      //       _url = Uri.parse(varFile!.url!);
                                      //       _launchUrl();
                                      //     }
                                      //   }
                                      // });
                                    },
                                    buttonColor:
                                        secondaryColor.withOpacity(0.6),
                                    textColor: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "تمت اضافته $enterDate",
                              style: const TextStyle(
                                  fontSize: 12, color: secondaryColor),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                _firestoreManager.deleteDocument(
                                    "الموظفين", name);
                                setState(() {
                                  isBack = true;
                                });
                              },
                              icon: const Icon(
                                Icons.delete, // Add delete icon
                                color: Colors.red, // Set icon color to white
                              ),
                              label: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Text(
                                  'حذف الموظف',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.withOpacity(
                                    0.2), // Set button background color to red
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8), // Set border radius to 15
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                // showDialog(
                                //   context: context,
                                //   builder: (BuildContext context) {
                                //     return const EditEmployeeDialog(
                                //      doc: {},
                                //     );
                                //   },
                                // );
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blue,
                              ),
                              label: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Text(
                                  'تعديل الموظف',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.withOpacity(0.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 40),
                    child: headLine("الصورة الشخصية"),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.height * 0.2,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        image: DecorationImage(
                            image: imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : const AssetImage('assets/logo.png')
                                    as ImageProvider,
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 40),
                    child: headLine("بيانات الموظف"),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          customTile(
                            context: context,
                            headLine: "اسم الموظف",
                            line: name,
                          ),
                          customTile(
                            context: context,
                            headLine: "رقم الموظف",
                            line: idNumber,
                          ),
                          customTile(
                            context: context,
                            headLine: "الوظيفه",
                            line: job,
                          ),
                          customTile(
                            context: context,
                            headLine: "مباشره العمل",
                            line: workStatus,
                          ),
                          customTile(
                            context: context,
                            headLine: "رقم الهويه",
                            line: idNumber,
                          ),
                          customTile(
                            context: context,
                            headLine: "نوع الرخصه",
                            line: licenseType,
                          ),
                          customTile(
                            context: context,
                            headLine: "سياره",
                            line: carType,
                          ),
                          ratingTile(
                              context: context,
                              headLine: "التقييم",
                              rating: rate),
                          customTile(
                            context: context,
                            headLine: "الراتب",
                            line: salary,
                          ),
                          customTile(
                            context: context,
                            headLine: "معاد الأجازة السنوية",
                            line: vacations,
                          ),
                          customTile(
                            context: context,
                            headLine: "مده الأجازة السنوية",
                            line: vacationsTime,
                          ),
                          customTile(
                            context: context,
                            headLine: "بدل السكن",
                            line: housingAllowance,
                          ),
                          customTile(
                            context: context,
                            headLine: "بدل المعيشه",
                            line: livingAllowance,
                          ),
                          customTile(
                            context: context,
                            headLine: "بدل المواصلات",
                            line: transportAllowance,
                          ),
                          customTile(
                            context: context,
                            headLine: "بدل إضافي مقطوع",
                            line: extraAllowance,
                          ),
                          customTile(
                            context: context,
                            headLine: "بدل المسئوليه",
                            line: responsibilityAllowance,
                          ),
                          customTile(
                            context: context,
                            headLine: "موقع العمل",
                            line: workLocation,
                          ),
                          customTile(
                            context: context,
                            headLine: "مكأفاة نهاية الخدمة",
                            line: finalJobPrize,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Padding customTile(
      {required BuildContext context,
      required String headLine,
      required String line}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.2,
        decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headLine,
                  style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                Text(line,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16))
              ],
            ),
            Row(
              children: [
                headLine == "مباشره العمل"
                    ? Container(
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
                        child: IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () async {
                            // await getGalleryList('startWorkDoc').then((value) {
                            //   for (final parseobject in value) {
                            //     if (parseobject.objectId.toString() ==
                            //         widget.doc?['work_start_file']) {
                            //       ParseFileBase? varFile =
                            //           parseobject.get<ParseFileBase>('file');
                            //       _url = Uri.parse(varFile!.url!);
                            //       _launchUrl();
                            //     }
                            //   }
                            // });
                          },
                          color: primaryColor,
                        ),
                      )
                    : const SizedBox(),
                const SizedBox(
                  width: 20,
                ),
                getIconForHeadLine(headLine),
              ],
            )
          ],
        ),
      ),
    );
  }

  Icon getIconForHeadLine(String headLine) {
    switch (headLine) {
      case "اسم الموظف":
        return const Icon(Icons.person);
      case "رقم الموظف":
        return const Icon(Icons.phone);
      case "الوظيفه":
        return const Icon(Icons.work);
      case "مباشره العمل":
        return const Icon(Icons.check);
      case "التقييم":
        return const Icon(Icons.star);
      case "الجنسية":
        return const Icon(Icons.flag);
      case "الراتب":
        return const Icon(Icons.wallet);
      case "معاد الأجازة السنوية":
        return const Icon(Icons.calendar_month);
      case "مده الأجازة السنوية":
        return const Icon(Icons.airplane_ticket);
      case "البدائل":
        return const Icon(Icons.restart_alt);
      case "موقع العمل":
        return const Icon(Icons.location_on);
      case "مكأفاة نهاية الخدمة":
        return const Icon(Icons.gif_outlined);
      case "رقم الهويه":
        return const Icon(Icons.badge);
      case "نوع الرخصه":
        return const Icon(Icons.drive_eta);
      case "سياره":
        return const Icon(Icons.directions_car);
      default:
        return const Icon(Icons.info);
    }
  }
}

Text headLine(String headLine) {
  return Text(
    headLine,
    style: const TextStyle(
        fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 20),
  );
}

Padding ratingTile({
  required BuildContext context,
  required String headLine,
  required double rating,
}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      width: MediaQuery.of(context).size.width * 0.2,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headLine,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              RatingBarIndicator(
                rating: rating,
                itemBuilder: (context, index) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 20.0,
                direction: Axis.horizontal,
              ),
            ],
          ),
          const Icon(Icons.star)
        ],
      ),
    ),
  );
}
