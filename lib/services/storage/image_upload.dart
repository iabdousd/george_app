import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

Future deleteFile(String url) async {
  try {
    await FirebaseStorage.instance.refFromURL(url).delete();
  } catch (e) {}
}

Future<String> uploadFile(dynamic _image) async {
  final fileName = _image is PickedFile
      ? _image.path.split("/").last
      : (_image as PlatformFile).name;
  final filePath =
      _image is PickedFile ? _image.path : (_image as PlatformFile).path;

  Reference storageReference =
      FirebaseStorage.instance.ref().child('images/$fileName');

  File file = File(filePath);
  UploadTask uploadTask = storageReference.putFile(file);
  await uploadTask;

  String returnURL = await storageReference.getDownloadURL();
  return returnURL;
}
