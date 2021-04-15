import 'package:flutter/material.dart';
import 'package:stackedtasks/models/Note.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/shared/text/text_to_spans.dart';
import 'package:stackedtasks/views/note/save_note.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class NoteListTileWidget extends StatelessWidget {
  final Note note;
  final String stackColor;

  const NoteListTileWidget(
      {Key key, @required this.note, @required this.stackColor})
      : super(key: key);

  _deleteNote(context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Delete Note',
            style: Theme.of(context).textTheme.headline6,
          ),
          content: Text('Would you really like to delete this note?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            TextButton(
              onPressed: () async {
                toggleLoading(state: true);
                await note.delete();
                toggleLoading(state: false);
                Navigator.of(context).pop();
              },
              child: Text(
                'Delete',
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }

  _editNote(context) {
    Get.to(
      () => SaveNotePage(
        note: note,
        stackRef: note.stackRef,
        goalRef: note.goalRef,
      ),
      popGesture: true,
      transition: Transition.rightToLeftWithFade,
    );
  }

  _tapEvent(context) async {
    //
    _editNote(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8.0,
            offset: Offset(0, 3),
          )
        ],
      ),
      margin: EdgeInsets.only(top: 16.0),
      child: GestureDetector(
        onTap: () => _tapEvent(context),
        child: Slidable(
          actionPane: SlidableScrollActionPane(),
          actionExtentRatio: 0.25,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: textToSpans(
                        note.taskRef != null
                            ? ('%*b' +
                                note.taskTitle +
                                '%*l - Task notes ' +
                                DateFormat('EEE, dd MMM').format(
                                  note.creationDate,
                                ) +
                                '\n%*n' +
                                note.content)
                            : ('%*b' +
                                note.content.split('\n').first +
                                '%*l - created ' +
                                DateFormat('EEE, dd MMM').format(
                                  note.creationDate,
                                ) +
                                (note.content.split('\n').length > 1
                                    ? '\n%*n' +
                                        note.content.substring(
                                          note.content
                                                  .split('\n')
                                                  .first
                                                  .length +
                                              1,
                                        )
                                    : '')),
                        initialTextSize:
                            Theme.of(context).textTheme.subtitle1.fontSize,
                      ),
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                  ),
                  if ((note.attachmentsCount ?? 0) > 0)
                    Text('${note.attachmentsCount} attachment(s)'),
                ],
              ),
            ),
          ),
          secondaryActions: <Widget>[
            IconSlideAction(
              onTap: () => _editNote(context),
              iconWidget: LayoutBuilder(builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  color: Theme.of(context).accentColor,
                  child: Icon(
                    Icons.edit,
                    color: Theme.of(context).backgroundColor,
                    size: 32.0,
                  ),
                );
              }),
              closeOnTap: true,
            ),
            IconSlideAction(
              iconWidget: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                      ),
                    ),
                    child: Icon(
                      Icons.delete,
                      color: Theme.of(context).backgroundColor,
                      size: 32.0,
                    ),
                  );
                },
              ),
              closeOnTap: true,
              onTap: () => _deleteNote(context),
            ),
          ],
        ),
      ),
    );
  }
}
