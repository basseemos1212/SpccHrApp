import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  PickedFile? pickedFile;

  List<ParseObject> results = <ParseObject>[];
  double selectedDistance = 3000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              child: Image.network(
                  'https://blog.back4app.com/wp-content/uploads/2017/11/logo-b4a-1-768x175-1.png'),
            ),
            const SizedBox(
              height: 16,
            ),
            const Center(
              child: Text('Flutter on Back4app - Save File',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              height: 50,
              child: ElevatedButton(
                child: const Text('Upload File'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SavePage()),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
                height: 50,
                child: ElevatedButton(
                  child: const Text('Display File'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DisplayPage()),
                    );
                  },
                ))
          ],
        ),
      ),
    );
  }
}

class SavePage extends StatefulWidget {
  @override
  _SavePageState createState() => _SavePageState();
}

class _SavePageState extends State<SavePage> {
  XFile? pickedFile;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload File'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            GestureDetector(
              child: pickedFile != null
                  ? Container(
                      width: 250,
                      height: 250,
                      decoration:
                          BoxDecoration(border: Border.all(color: Colors.blue)),
                      child: Image.file(File(pickedFile!.path)))
                  : Container(
                      width: 250,
                      height: 250,
                      decoration:
                          BoxDecoration(border: Border.all(color: Colors.blue)),
                      child: const Center(
                        child: Text('Click here to pick image from Gallery'),
                      ),
                    ),
              onTap: () async {
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles(type: FileType.image);

                if (result != null) {
                  PlatformFile file = result.files.first;
                  setState(() {
                    pickedFile = XFile(file.path.toString());
                    print(file.path.toString());
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Container(
              height: 50,
              child: ElevatedButton(
                child: const Text('Upload File'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: isLoading || pickedFile == null
                    ? null
                    : () async {
                        setState(() {
                          isLoading = true;
                        });
                        ParseFileBase? parseFile;

                        if (kIsWeb) {
                          //Flutter Web
                          parseFile = ParseWebFile(
                              await pickedFile!.readAsBytes(),
                              name:
                                  pickedFile!.name); //Name for file is required
                        } else {
                          //Flutter Mobile/Desktop
                          parseFile = ParseFile(File(pickedFile!.path));
                        }
                        await parseFile.save();
                        final gallery = ParseObject('baby')
                          ..set('file', parseFile);
                        await gallery.save();
                        setState(() {
                          isLoading = false;
                          pickedFile = null;
                        });
                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(const SnackBar(
                            content: Text(
                              'File uploaded successfully!',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            duration: Duration(seconds: 3),
                            backgroundColor: Colors.blue,
                          ));
                      },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DisplayPage extends StatefulWidget {
  @override
  _DisplayPageState createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Display Gallery"),
      ),
      body: FutureBuilder<List<ParseObject>>(
          future: getGalleryList(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Container(
                      width: 100,
                      height: 100,
                      child: const CircularProgressIndicator()),
                );
              default:
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Error..."),
                  );
                } else {
                  return ListView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        //Web/Mobile/Desktop
                        ParseFileBase? varFile =
                            snapshot.data![index].get<ParseFileBase>('file');

                        //Only iOS/Android/Desktop
                        /*
                        ParseFile? varFile =
                            snapshot.data![index].get<ParseFile>('file');
                        */
                        return varFile!.name.toString() !=
                                "0c3a902f2bd81f6016c8fd7b54657309_WhatsApp Image 2023-07-08 at 9.00.22 AM.jpeg"
                            ? const SizedBox()
                            : Image.network(
                                varFile.url!,
                                width: 200,
                                height: 200,
                                fit: BoxFit.fitHeight,
                              );
                      });
                }
            }
          }),
    );
  }

  Future<List<ParseObject>> getGalleryList() async {
    QueryBuilder<ParseObject> queryPublisher =
        QueryBuilder<ParseObject>(ParseObject('baby'))
          ..orderByAscending('createdAt');
    final ParseResponse apiResponse = await queryPublisher.query();

    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
  }
}
