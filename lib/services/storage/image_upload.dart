import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

Future deleteFile(String url) async {
  try {
    await FirebaseStorage.instance.refFromURL(url).delete();
  } catch (e) {}
}

Future<String> uploadFile(PickedFile _image) async {
  Reference storageReference = FirebaseStorage.instance
      .ref()
      .child('images/${_image.path.split("/").last}');

  File file = File(_image.path);
  UploadTask uploadTask = storageReference.putFile(file);
  await uploadTask;

  String returnURL;
  await storageReference.getDownloadURL().then((fileURL) {
    returnURL = fileURL;
  });
  return returnURL;
}
