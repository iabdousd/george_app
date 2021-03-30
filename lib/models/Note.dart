import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:george_project/services/storage/image_upload.dart';
import 'package:image_picker/image_picker.dart';

import 'package:george_project/constants/models/note.dart' as note_constants;
import 'package:george_project/constants/user.dart' as user_constants;
import 'package:george_project/constants/models/stack.dart' as stack_constants;
import 'package:george_project/constants/models/goal.dart' as goal_constants;
import 'package:george_project/services/user/user_service.dart';
import 'Attachment.dart';

class Note {
  String id;
  String goalRef;
  String stackRef;
  String taskRef;
  String taskTitle;
  DateTime creationDate;
  String content;
  List<Attachment> attachments;
  int attachmentsCount;

  Note({
    this.id,
    this.goalRef,
    this.stackRef,
    this.taskRef,
    this.taskTitle,
    this.creationDate,
    this.content,
    this.attachments,
    this.attachmentsCount = 0,
  });

  Note.fromJson(jsonObject, {String id}) {
    this.id = id;
    this.taskRef = jsonObject[note_constants.TASK_REF_KEY];
    this.taskTitle = jsonObject[note_constants.TASK_TITLE_KEY];
    this.creationDate =
        (jsonObject[note_constants.CREATION_DATE_KEY] as Timestamp).toDate();
    this.content = jsonObject[note_constants.CONTENT_KEY];
    this.attachmentsCount = jsonObject[note_constants.ATTACHMENTS_COUNT_KEY];
  }

  Map<String, dynamic> toJson() {
    return {
      note_constants.TASK_REF_KEY: this.taskRef,
      note_constants.TASK_TITLE_KEY: this.taskTitle,
      note_constants.CONTENT_KEY: this.content,
      note_constants.CREATION_DATE_KEY: this.creationDate,
      note_constants.ATTACHMENTS_COUNT_KEY: this.attachmentsCount,
    };
  }

  save() async {
    assert(goalRef != null && stackRef != null);
    if (id == null) {
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection(user_constants.USERS_KEY)
          .doc(getCurrentUser().uid)
          .collection(goal_constants.GOALS_KEY)
          .doc(goalRef)
          .collection(goal_constants.STACKS_KEY)
          .doc(stackRef)
          .collection(stack_constants.NOTES_KEY)
          .add(toJson());
      this.id = docRef.id;
    } else {
      await FirebaseFirestore.instance
          .collection(user_constants.USERS_KEY)
          .doc(getCurrentUser().uid)
          .collection(goal_constants.GOALS_KEY)
          .doc(goalRef)
          .collection(goal_constants.STACKS_KEY)
          .doc(stackRef)
          .collection(stack_constants.NOTES_KEY)
          .doc(id)
          .update(toJson());
    }
  }

  delete() async {
    assert(id != null);
    await FirebaseFirestore.instance
        .collection(user_constants.USERS_KEY)
        .doc(getCurrentUser().uid)
        .collection(goal_constants.GOALS_KEY)
        .doc(goalRef)
        .collection(goal_constants.STACKS_KEY)
        .doc(stackRef)
        .collection(stack_constants.NOTES_KEY)
        .doc(id)
        .delete();
  }

  fetchAttachments() async {
    attachments = [];
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(user_constants.USERS_KEY)
        .doc(getCurrentUser().uid)
        .collection(goal_constants.GOALS_KEY)
        .doc(goalRef)
        .collection(goal_constants.STACKS_KEY)
        .doc(stackRef)
        .collection(stack_constants.NOTES_KEY)
        .doc(id)
        .collection(note_constants.ATTACHMENTS_KEY)
        .get();
    snapshot.docs.forEach((doc) {
      attachments.add(Attachment.fromJson(doc.data(), id: doc.id));
    });
    this.attachmentsCount = snapshot.docs.length;
  }

  Future deleteAttachment(Attachment attachment) async {
    await deleteFile(attachment.path);
    await FirebaseFirestore.instance
        .collection(user_constants.USERS_KEY)
        .doc(getCurrentUser().uid)
        .collection(goal_constants.GOALS_KEY)
        .doc(goalRef)
        .collection(goal_constants.STACKS_KEY)
        .doc(stackRef)
        .collection(stack_constants.NOTES_KEY)
        .doc(id)
        .collection(note_constants.ATTACHMENTS_KEY)
        .doc(attachment.id)
        .delete();
    attachments.remove(attachment);
    this.attachmentsCount--;
    await save();
  }

  Future addAttachments(List<PickedFile> images) async {
    attachments = attachments ?? [];
    for (PickedFile img in images) {
      String url = await uploadFile(img);
      Attachment attachment = Attachment(
        path: url,
        creationDate: DateTime.now(),
        ext: img.path.split('.').last,
      );
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection(user_constants.USERS_KEY)
          .doc(getCurrentUser().uid)
          .collection(goal_constants.GOALS_KEY)
          .doc(goalRef)
          .collection(goal_constants.STACKS_KEY)
          .doc(stackRef)
          .collection(stack_constants.NOTES_KEY)
          .doc(id)
          .collection(note_constants.ATTACHMENTS_KEY)
          .add(
            Map<String, dynamic>.from(attachment.toJson()),
          );
      attachments.add(attachment..id = docRef.id);
    }

    this.attachmentsCount += images.length;
    await save();
  }
}
