import 'dart:async';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackedtasks/constants/models/stack.dart';
import 'package:stackedtasks/models/Note.dart';

import 'package:stackedtasks/constants/models/note.dart' as note_constants;
import 'package:stackedtasks/constants/models/stack.dart' as stack_constants;
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/services/user/user_service.dart';

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

  static Stream<List<Note>> streamTaskNotes(
    Task task, {
    bool bothNotes: false,
    bool allTaskNotes: false,
  }) {
    if (!bothNotes &&
        !allTaskNotes &&
        (task.taskNotes == null || task.taskNotes.isEmpty)) {
      return Stream.value([]);
    }
    if (bothNotes) {
      return StreamGroup.merge(
        [
          FirebaseFirestore.instance
              .collection(NOTES_KEY)
              .where(note_constants.TASK_REF_KEY, isEqualTo: task.id)
              .orderBy(
                note_constants.CREATION_DATE_KEY,
                descending: true,
              )
              .snapshots()
              .asyncMap((event) async {
            List<Note> notes = [];
            for (final noteRaw in event.docs) {
              Note note = Note.fromJson(
                noteRaw.data(),
                id: noteRaw.id,
              );
              if (note.userID != getCurrentUser().uid) {
                final userModel = await UserService.getUser(note.userID);
                note.creator = userModel;
              } else {
                note.creator = UserModel(
                  uid: getCurrentUser().uid,
                  fullName: getCurrentUser().displayName,
                  email: getCurrentUser().email,
                  photoURL: getCurrentUser().photoURL,
                );
              }
              notes.add(note);
            }
            return notes;
          }),
          if (task.taskNotes != null && task.taskNotes.isNotEmpty)
            FirebaseFirestore.instance
                .collection(NOTES_KEY)
                .where(
                  note_constants.NOTE_ID_KEY,
                  whereIn: task.taskNotes,
                )
                .orderBy(
                  note_constants.CREATION_DATE_KEY,
                  descending: true,
                )
                .snapshots()
                .asyncMap((event) async {
              List<Note> notes = [];
              for (final noteRaw in event.docs) {
                Note note = Note.fromJson(
                  noteRaw.data(),
                  id: noteRaw.id,
                );
                if (note.userID != getCurrentUser().uid) {
                  final userModel = await UserService.getUser(note.userID);
                  note.creator = userModel;
                } else {
                  note.creator = UserModel(
                    uid: getCurrentUser().uid,
                    fullName: getCurrentUser().displayName,
                    email: getCurrentUser().email,
                    photoURL: getCurrentUser().photoURL,
                  );
                }
                notes.add(note);
              }
              print(notes);
              return notes;
            })
        ],
      );
    }

    Query ref = FirebaseFirestore.instance.collection(NOTES_KEY);

    if (allTaskNotes) {
      ref = ref.where(note_constants.TASK_REF_KEY, isEqualTo: task.id).orderBy(
            note_constants.CREATION_DATE_KEY,
            descending: true,
          );
    } else {
      ref = ref
          .where(
            note_constants.NOTE_ID_KEY,
            whereIn: task.taskNotes,
          )
          .orderBy(
            note_constants.CREATION_DATE_KEY,
            descending: true,
          );
    }

    return ref.snapshots().asyncMap((event) async {
      List<Note> notes = [];
      for (final noteRaw in event.docs) {
        Note note = Note.fromJson(
          noteRaw.data(),
          id: noteRaw.id,
        );
        if (note.userID != getCurrentUser().uid) {
          final userModel = await UserService.getUser(note.userID);
          note.creator = userModel;
        } else {
          note.creator = UserModel(
            uid: getCurrentUser().uid,
            fullName: getCurrentUser().displayName,
            email: getCurrentUser().email,
            photoURL: getCurrentUser().photoURL,
          );
        }
        notes.add(note);
      }
      return notes;
    });
  }
}
