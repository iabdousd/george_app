import 'package:flutter/material.dart';
import 'package:george_project/models/Task.dart';
import 'package:george_project/providers/cache/cached_image_provider.dart';
import 'package:george_project/services/shared/sharing/sharing_task.dart';
import 'package:george_project/views/task/save_task.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class OnetimeTaskArticleWidget extends StatelessWidget {
  final String profilePicture;
  final Task task;

  const OnetimeTaskArticleWidget({
    Key key,
    this.profilePicture,
    this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Color(0x22000000),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(42.0),
                  child: Image(
                    image: CachedImageProvider(profilePicture),
                    fit: BoxFit.cover,
                    width: 42,
                    height: 42,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  DateFormat('EEE, dd MMM yyyy').format(task.startDate) +
                      '   ' +
                      DateFormat('hh a').format(task.startTime) +
                      ' - ' +
                      DateFormat('hh a').format(task.endTime),
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 4.0),
            child: Text(
              task.title,
              style: Theme.of(context).textTheme.headline6.copyWith(
                    decoration: task.status == 1
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 4.0),
            child: Text(
              task.description,
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                    decoration: task.status == 1
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 12.0,
              top: 8.0,
            ),
            child: FutureProvider<String>(
              initialData: '',
              create: (_) {
                return task.fetchNotes();
              },
              child: Consumer<String>(
                builder: (context, data, _) {
                  if (data == null)
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300],
                      highlightColor: Colors.white,
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                              top: 4.0,
                              bottom: 8.0,
                            ),
                            height: 12,
                            color: Theme.of(context).backgroundColor,
                            width: double.infinity,
                          ),
                          Container(
                            height: 12,
                            color: Theme.of(context).backgroundColor,
                            width: double.infinity,
                          ),
                        ],
                      ),
                    );
                  return Text(
                    data,
                    style: Theme.of(context).textTheme.subtitle2.copyWith(),
                  );
                },
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 1,
                  color: Color(0x22000000),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => Get.to(
                    () => SaveTaskPage(
                      goalRef: task.goalRef,
                      stackRef: task.stackRef,
                      stackColor: task.stackColor,
                      task: task,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.edit,
                        size: 24,
                      ),
                      Text(
                        'Edit',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  child: Column(
                    children: [
                      Icon(
                        Icons.more_horiz,
                        size: 24,
                      ),
                      Text(
                        'See more',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => shareTask(task),
                  child: Column(
                    children: [
                      Icon(
                        Icons.share,
                        size: 24,
                      ),
                      Text(
                        'Share',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressIndicatorClipper extends CustomClipper<Rect> {
  final double value;

  _ProgressIndicatorClipper({
    @required this.value,
  });

  @override
  getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * value, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) => false;
}
