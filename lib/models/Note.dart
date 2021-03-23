import 'package:cloud_firestore/cloud_firestore.dart';

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
  DateTime creationDate;
  String content;
  List<Attachment> attachments;

  Note({
    this.id,
    this.goalRef,
    this.stackRef,
    this.creationDate,
    this.content,
    this.attachments,
  });

  Note.fromJson(jsonObject, {String id}) {
    this.id = id;
    this.creationDate =
        (jsonObject[note_constants.CREATION_DATE_KEY] as Timestamp).toDate();
    this.content = jsonObject[note_constants.CONTENT_KEY];
  }

  Map<String, dynamic> toJson() {
    return {
      note_constants.CONTENT_KEY: this.content,
      note_constants.CREATION_DATE_KEY: this.creationDate,
    };
  }

  save() async {
    assert(goalRef != null && stackRef != null);
    if (id == null) {
      await FirebaseFirestore.instance
          .collection(user_constants.USERS_KEY)
          .doc(getCurrentUser().uid)
          .collection(goal_constants.GOALS_KEY)
          .doc(goalRef)
          .collection(goal_constants.STACKS_KEY)
          .doc(stackRef)
          .collection(stack_constants.NOTES_KEY)
          .add(toJson());
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
}
