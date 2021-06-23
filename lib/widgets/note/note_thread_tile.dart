import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:stackedtasks/models/Note.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/views/note/save_note.dart';
import 'package:stackedtasks/views/user/user_profile.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';
import 'package:stackedtasks/widgets/shared/images_list_view.dart';

class NoteThreadTile extends StatelessWidget {
  final Note note;
  final int index;
  final bool isLast, showAll;

  const NoteThreadTile({
    Key key,
    this.note,
    this.index,
    this.isLast: false,
    this.showAll: false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return FadeIn(
      key: Key(note.id),
      duration: Duration(milliseconds: 350),
      child: Container(
        decoration: BoxDecoration(
            // border: index == 0
            //     ? null
            //     : Border(
            //         top: BorderSide(
            //           color: Colors.black26,
            //         ),
            //       ),
            ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 4.0,
                          bottom: 4.0,
                          left: 8.0,
                          right: 8.0,
                        ),
                        child: InkWell(
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
                                    width: 32,
                                    height: 32,
                                  )
                                : Image(
                                    image: CachedImageProvider(
                                      note.creator.photoURL,
                                    ),
                                    width: 32,
                                    height: 32,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                      if (isLast && (showAll || (!showAll && index != 0)))
                        Expanded(
                          child: Container(
                            width: 1.5,
                            color: Color(0xFFAAAAAA),
                          ),
                        ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
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
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  ' - ' +
                                      (note.creationDate.year == now.year &&
                                              note.creationDate.month ==
                                                  now.month &&
                                              note.creationDate.day == now.day
                                          ? 'Today'
                                          : note.creationDate
                                                      .difference(now)
                                                      .abs() <
                                                  Duration(days: 1)
                                              ? 'Yesterday'
                                              : note.creationDate
                                                          .difference(now)
                                                          .abs() <
                                                      Duration(days: 7)
                                                  ? DateFormat('EEE').format(
                                                      note.creationDate,
                                                    )
                                                  : DateFormat('dd/MM/yyyy')
                                                      .format(
                                                      note.creationDate,
                                                    )),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              top: 4,
                              bottom: (isLast &&
                                      (note?.attachments == null ||
                                          note.attachments.length == 0))
                                  ? 32
                                  : 8,
                            ),
                            child: Text(
                              note.content,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          if (note?.attachments != null &&
                              note.attachments.length > 0)
                            Container(
                              margin: EdgeInsets.only(
                                top: 8.0,
                                bottom: isLast ? 32 : 8,
                              ),
                              height: ((note.attachments.length / 2)
                                                  .toStringAsFixed(1)
                                                  .split('.')[1] ==
                                              '5'
                                          ? (note.attachments.length ~/ 2) + 1
                                          : (note.attachments.length ~/ 2)) *
                                      70.0 +
                                  48.0,
                              child: ImagesListView(
                                images: [],
                                readOnly: true,
                                networkImages: note.attachments ?? [],
                                deleteEvent: null,
                                imageHeight: 64,
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
                        size: 18,
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
