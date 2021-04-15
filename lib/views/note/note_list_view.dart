import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:stackedtasks/constants/models/goal.dart' as goal_constants;
import 'package:stackedtasks/constants/user.dart' as user_constants;
import 'package:stackedtasks/constants/models/stack.dart' as stack_constants;
import 'package:stackedtasks/constants/models/note.dart' as note_constants;
import 'package:stackedtasks/models/Note.dart';
import 'package:stackedtasks/models/Stack.dart' as stack_model;
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/views/note/save_note.dart';
import 'package:stackedtasks/widgets/note/note_lsit_tile.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';
import 'package:stackedtasks/widgets/shared/app_error_widget.dart';
import 'package:get/get.dart';

class NoteListView extends StatefulWidget {
  final stack_model.Stack stack;
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
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(user_constants.USERS_KEY)
                  .doc(getCurrentUser().uid)
                  .collection(goal_constants.GOALS_KEY)
                  .doc(widget.stack.goalRef)
                  .collection(goal_constants.STACKS_KEY)
                  .doc(widget.stack.id)
                  .collection(stack_constants.NOTES_KEY)
                  .orderBy(note_constants.CREATION_DATE_KEY, descending: true)
                  .limit(10)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) if (snapshot.data.docs.length > 0)
                  return ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                    ),
                    itemCount: snapshot.data.docs.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      Note note = Note.fromJson(
                        snapshot.data.docs[index].data(),
                        id: snapshot.data.docs[index].id,
                      );
                      return NoteListTileWidget(
                        note: note
                          ..goalRef = widget.stack.goalRef
                          ..stackRef = widget.stack.id,
                        stackColor: widget.stack.color,
                      );
                    },
                  );
                else
                  return Container();

                return LoadingWidget();
              }),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
