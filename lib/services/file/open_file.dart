import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:path_provider/path_provider.dart' as pp;

class OpenFileService {
  static void openNetworkFile(String url, String extension) async {
    toggleLoading(state: true);
    final fileName = '/${url.split('/').last.split('?').first}.$extension';
    final tempDir = await pp.getTemporaryDirectory();
    final filePath = tempDir.path + fileName;

    if (File(fileName).existsSync()) {
      toggleLoading(state: false);
      OpenFile.open(filePath);
      return;
    }

    final res = await http.get(Uri.parse(url));
    final file = File(filePath);
    await file.writeAsBytes(
      res.bodyBytes,
    );
    toggleLoading(state: false);
    OpenFile.open(filePath);
  }
}
