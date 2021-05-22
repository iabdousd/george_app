import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackedtasks/models/Note.dart';

import 'package:stackedtasks/constants/models/note.dart' as note_constants;
import 'package:stackedtasks/constants/models/stack.dart' as stack_constants;

class NoteRepository {
  static Future<List<Note>> getStackNotes(String stackRef) async {
    final notesRaw = await FirebaseFirestore.instance
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
