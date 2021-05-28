import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import 'package:stackedtasks/models/Note.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';

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
        child: IntrinsicHeight(
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
                                              : DateFormat('dd/MM/yyyy').format(
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
                          bottom: isLast ? 32 : 8,
                        ),
                        child: Text(
                          note.content,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
