import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:george_project/constants/models/note.dart' as note_constants;

class Attachment {
  String id;
  String path;
  String ext;
  DateTime creationDate;

  Attachment({
    this.id,
    this.path,
    this.ext,
    this.creationDate,
  });

  Attachment.fromJson(jsonObject, {String id}) {
    this.id = id;
    this.path = jsonObject[note_constants.ATTACHMENT_PATH];
    this.ext = jsonObject[note_constants.ATTACHMENT_EXT];
    this.creationDate =
        (jsonObject[note_constants.ATTACHMENT_CREATION_DATE_KEY] as Timestamp)
            .toDate();
  }

  Map<String, dynamic> toJson() {
    return {
      note_constants.ATTACHMENT_PATH: path,
      note_constants.ATTACHMENT_EXT: ext,
      note_constants.ATTACHMENT_CREATION_DATE_KEY: creationDate,
    };
  }
}
