import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:george_project/constants/models/note.dart' as note_constants;
import 'Attachment.dart';

class Note {
  String id;
  DateTime creationDate;
  String content;
  List<Attachment> attachments;

  Note.fromJson(jsonObject, {String id}) {
    this.id = id;
    this.creationDate =
        (jsonObject[note_constants.CREATION_DATE_KEY] as Timestamp).toDate();
    this.content = jsonObject[note_constants.CONTENT_KEY];
    attachments = jsonObject[note_constants.ATTACHMENTS_KEY]
        .map((e) => Attachment.fromJson(e));
  }
}
