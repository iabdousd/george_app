import 'package:flutter/material.dart';
import 'package:stackedtasks/models/Note.dart';
import 'package:stackedtasks/models/Stack.dart' as stack_model;
import 'package:stackedtasks/repositories/note/note_repository.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/views/note/save_note.dart';
import 'package:stackedtasks/widgets/note/note_lsit_tile.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';
import 'package:get/get.dart';
import 'package:stackedtasks/widgets/shared/app_error_widget.dart';

class NoteListView extends StatefulWidget {
  final stack_model.TasksStack stack;
  const NoteListView({Key key, this.stack}) : super(key: key);

  @override
  _NoteListViewState createState() => _NoteListViewState();
}

class _NoteListViewState extends State<NoteListView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
      child: ListView(
        children: [
          SizedBox(
            height: 8.0,
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                width: constraints.maxWidth,
                child: AppActionButton(
                  onPressed: () => Get.to(
                    () => SaveNotePage(
                      goalRef: widget.stack.goalRef,
                      stackRef: widget.stack.id,
                    ),
                  ),
                  icon: Icons.add,
                  label: 'NEW NOTE',
                  backgroundColor: Theme.of(context).primaryColor,
                  alignment: Alignment.center,
                  textStyle: Theme.of(context).textTheme.headline6.copyWith(
                        color: Theme.of(context).backgroundColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                  iconSize: 26.0,
                ),
              );
            },
          ),
          FutureBuilder<List<Note>>(
              future: NoteRepository.getStackNotes(widget.stack.id),
              builder: (context, snapshot) {
                if (snapshot.hasData) if (snapshot.data.length > 0)
                  return ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                    ),
                    itemCount: snapshot.data.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      Note note = snapshot.data[index];
                      return NoteListTileWidget(
                        note: note,
                        stackColor: widget.stack.color,
                      );
                    },
                  );
                else
                  return Container();
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return AppErrorWidget();
                }
                return LoadingWidget();
              }),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
