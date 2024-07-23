import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class FileViewer extends StatefulWidget {
  final String className;
  final String fileName;

  const FileViewer({
    Key? key,
    required this.className,
    required this.fileName,
  }) : super(key: key);

  @override
  _FileViewerState createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer> {
  ParseFile? _file;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _launchInBrowser(String url) async {
    if (await UrlLauncherPlatform.instance.canLaunch(url)) {
      await UrlLauncherPlatform.instance.launch(
        url,
        useSafariVC: false,
        useWebView: false,
        enableJavaScript: false,
        enableDomStorage: false,
        universalLinksOnly: false,
        headers: <String, String>{},
      );
    } else {
      throw Exception('Could not launch $url');
    }
  }

  Widget _launchStatus(BuildContext context, AsyncSnapshot<void> snapshot) {
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      return const Text('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : _file != null
            ? GestureDetector(
                onTap: () async {
                  // Open the file URL in a web browser
                  await _launchInBrowser(_file!.url!);
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Open File: ${_file!.name}',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
              )
            : Center(
                child: Text('File not found.'),
              );
  }
}
