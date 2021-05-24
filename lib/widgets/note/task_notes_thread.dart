import 'dart:math';

import 'package:animated_rotation/animated_rotation.dart';
import 'package:flutter/material.dart';
import 'package:stackedtasks/models/Note.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/repositories/stack/note_repository.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';

import 'note_thread_tile.dart';

class TaskNotesThread extends StatelessWidget {
  final Task task;
  final bool allTaskNotes;
  const TaskNotesThread({
    Key key,
    this.task,
    this.allTaskNotes: false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool showAll = false;

    return StreamBuilder<List<Note>>(
      stream: NoteRepository.streamTaskNotes(
        task,
        allTaskNotes: allTaskNotes,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.all(8.0),
            height: 64,
            child: Center(
              child: LoadingWidget(),
            ),
          );
        }

        if (snapshot.data.isEmpty) {
          return Container();
        }

        return StatefulBuilder(
          builder: (context, notesSetState) {
            return Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: showAll
                    ? snapshot.data.length + 1
                    : min(snapshot.data.length,
                        (showAll ? snapshot.data.length : 2)),
                itemBuilder: (context, index) {
                  if ((showAll && index == snapshot.data.length) ||
                      (!showAll && index == 1 && snapshot.data.length > 1))
                    return TextButton(
                      key: Key('SHOW_NOTES_${task.id}'),
                      onPressed: () => notesSetState(
                        () => showAll = !showAll,
                      ),
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: AnimatedRotation(
                              angle: showAll ? 90 : -90,
                              child: Icon(
                                Icons.arrow_back_ios_outlined,
                                size: 18,
                              ),
                            ),
                          ),
                          Text(
                            showAll ? 'Show Less' : 'Show All',
                          ),
                        ],
                      ),
                    );

                  final note = snapshot.data[index];
                  return NoteThreadTile(
                    key: Key(note.id),
                    note: note,
                    index: index,
                    isLast: index != snapshot.data.length - 1,
                    showAll: showAll,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
