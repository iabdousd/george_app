import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';

Future deleteFile(String url) async {
  try {
    await FirebaseStorage.instance.refFromURL(url).delete();
  } catch (e) {}
}

Future<String> uploadFile(Asset _image) async {
  Reference storageReference =
      FirebaseStorage.instance.ref().child('images/${_image.name}');

  Directory appDocDir = await getApplicationDocumentsDirectory();

  File file = File(appDocDir.path + '/' + _image.name);
  await file.writeAsBytes(
      (await _image.getByteData(quality: 80)).buffer.asUint8List());

  UploadTask uploadTask = storageReference.putFile(file);
  await uploadTask;

  String returnURL;
  await storageReference.getDownloadURL().then((fileURL) {
    returnURL = fileURL;
  });
  return returnURL;
}
