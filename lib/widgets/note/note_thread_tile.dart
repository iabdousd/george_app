import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:stackedtasks/models/Note.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/views/note/save_note.dart';
import 'package:stackedtasks/views/user/user_profile.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';
import 'package:stackedtasks/widgets/shared/images_list_view.dart';

class NoteThreadTile extends StatelessWidget {
  final Note note;

  const NoteThreadTile({
    Key key,
    this.note,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      key: Key(note.id),
      duration: Duration(milliseconds: 350),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => Get.to(
                () => UserProfileView(
                  user: note.creator,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(52),
                child: note.creator.photoURL == null
                    ? SvgPicture.asset(
                        'assets/images/profile.svg',
                        fit: BoxFit.cover,
                        width: 44.0,
                        height: 44.0,
                      )
                    : Image(
                        image: CachedImageProvider(
                          note.creator.photoURL,
                        ),
                        width: 44.0,
                        height: 44.0,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.creator.fullName.split(' ').first,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3B404A),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            ' • ' + timeago.format(note.creationDate),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3B404A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (note.content.isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(
                          top: 4,
                          bottom: 4.0,
                        ),
                        child: Text(
                          note.content,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF767C8D),
                          ),
                        ),
                      ),
                    if (note?.attachments != null &&
                        note.attachments.length > 0)
                      Container(
                        child: ImagesListView(
                          images: [],
                          readOnly: true,
                          networkImages: note.attachments,
                          deleteEvent: null,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (note.userID == getCurrentUser().uid)
              PopupMenuButton<String>(
                onSelected: handleClick,
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 24,
                  color: Color(0xFFB2B5C3),
                ),
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ];
                },
              ),
          ],
        ),
      ),
    );
  }

  void handleClick(String action) async {
    if (action == 'delete') {
      await showDialog(
        context: Get.context,
        builder: (context) => AlertDialog(
          title: Text('Are you sure to delete this note ?'),
          buttonPadding: EdgeInsets.zero,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppActionButton(
                  onPressed: Get.back,
                  label: 'Cancel',
                  margin: EdgeInsets.only(right: 8),
                ),
                AppActionButton(
                  onPressed: () => {
                    note.delete(),
                    Get.back(),
                  },
                  label: 'Delete',
                  backgroundColor: Colors.red,
                  margin: EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
      );
    } else if (action == 'edit') {
      Get.to(
        () => SaveNotePage(
          goalRef: note.goalRef,
          stackRef: note.stackRef,
          note: note,
          taskRef: note.taskRef,
          taskTitle: note.taskTitle,
        ),
      );
    }
  }
}
