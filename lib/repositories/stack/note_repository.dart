import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackedtasks/models/Note.dart';

import 'package:stackedtasks/constants/models/note.dart' as note_constants;
import 'package:stackedtasks/constants/user.dart' as user_constants;
import 'package:stackedtasks/constants/models/stack.dart' as stack_constants;
import 'package:stackedtasks/services/user/user_service.dart';

class NoteRepository {
  static Future<List<Note>> getStackNotes(String stackRef) async {
    final notesRaw = await FirebaseFirestore.instance
        .collection(user_constants.USERS_KEY)
        .doc(getCurrentUser().uid)
        .collection(stack_constants.NOTES_KEY)
        .where(note_constants.STACK_REF_KEY, isEqualTo: stackRef)
        .get();
    return notesRaw.docs
        .map(
          (e) => Note.fromJson(
            e.data(),
            id: e.id,
          ),
        )
        .toList();
  }
}
