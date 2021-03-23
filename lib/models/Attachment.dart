import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:george_project/constants/models/note.dart' as note_constants;

class Attachment {
  String path;
  String ext;
  DateTime creationDate;

  Attachment.fromJson(jsonObject) {
    this.path = jsonObject[note_constants.ATTACHMENT_PATH];
    this.ext = jsonObject[note_constants.ATTACHMENT_EXT];
    this.creationDate =
        (jsonObject[note_constants.ATTACHMENT_CREATION_DATE_KEY] as Timestamp)
            .toDate();
  }
}
