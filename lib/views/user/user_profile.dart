import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/models/UserModel.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/repositories/feed/feed_repository.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/widgets/activity_feed/cards/onetime_task_article.dart';
import 'package:stackedtasks/widgets/activity_feed/cards/recurring_task_article.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';
import 'package:stackedtasks/widgets/shared/app_error_widget.dart';
import 'package:stackedtasks/widgets/shared/photo_view.dart';

class UserProfileView extends StatefulWidget {
  final UserModel user;
  UserProfileView({
    Key key,
    @required this.user,
  }) : super(key: key);

  @override
  _UserProfileViewState createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  @override
  Widget build(BuildContext context) {
    DateTime lastDate;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(),
      body: NestedScrollView(
        headerSliverBuilder: (context, bool) => [
          SliverAppBar(
            pinned: false,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Column(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: widget.user.photoURL == null
                          ? SvgPicture.asset(
                              'assets/images/profile.svg',
                              width: 96,
                              height: 96,
                            )
                          : InkWell(
                              onTap: () {
                                Get.to(
                                  () => AppPhotoView(
                                    imageProvider: CachedImageProvider(
                                      getCurrentUser().photoURL,
                                    ),
                                  ),
                                );
                              },
                              child: Image(
                                image:
                                    CachedImageProvider(widget.user.photoURL),
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      widget.user.fullName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StreamBuilder(
                        stream: UserService.streamIsFollowed(widget.user),
                        builder: (context, snapshot) {
                          final followed = snapshot.data ?? false;
                          return ElevatedButton(
                            onPressed: () =>
                                UserService.followUser(widget.user),
                            child: Text(followed ? 'Unfollow' : 'Follow'),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                followed
                                    ? Colors.red[600]
                                    : Theme.of(context).primaryColor,
                              ),
                              padding: MaterialStateProperty.all(
                                EdgeInsets.symmetric(horizontal: 32),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: StreamBuilder<int>(
                            stream:
                                UserService.countUserFollowers(widget.user.uid),
                            builder: (context, snapshot) {
                              final count = snapshot.data ?? 0;
                              return Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Text(
                                      'Followers',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          .copyWith(
                                              fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Text('$count'),
                                ],
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: StreamBuilder<int>(
                            stream: UserService.countUserFollowing(
                              widget.user.uid,
                            ),
                            builder: (context, snapshot) {
                              final count = snapshot.data ?? 0;
                              return Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Text(
                                      'Following',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          .copyWith(
                                              fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Text('$count'),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            expandedHeight: 326,
          ),
        ],
        body: SafeArea(
          child: StreamBuilder<List<Task>>(
              stream: FeedRepository.fetchUserArticles(widget.user.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return AppErrorWidget();
                }
                if (snapshot.hasData)
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    itemBuilder: (context, index) {
                      final task = snapshot.data[index];

                      bool showDate = false;
                      if (lastDate == null) {
                        showDate = true;
                      } else
                        showDate = !(lastDate.day == task.creationDate.day &&
                            lastDate.month == task.creationDate.month &&
                            lastDate.year == task.creationDate.year);

                      lastDate = task.creationDate;
                      return Row(
                        key: Key(task.id),
                        crossAxisAlignment: showDate
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              left: 8.0,
                              right: 8.0,
                              top: 8.0,
                            ),
                            width: 80,
                            child: showDate
                                ? Column(
                                    children: [
                                      Text(
                                        DateFormat('EEEE\nMMMM d')
                                            .format(task.creationDate)
                                            .toUpperCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .headline6
                                                  .color
                                                  .withOpacity(.6),
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 12.0),
                                        child: Text(
                                          DateFormat('hh:mm a')
                                              .format(task.startTime),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              .copyWith(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headline6
                                                    .color
                                                    .withOpacity(.5),
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    DateFormat('hh:mm a')
                                        .format(task.creationDate),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              .color
                                              .withOpacity(.5),
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                          ),
                          if (task.repetition == null)
                            Expanded(
                              child: OnetimeTaskArticleWidget(
                                name: task.userName,
                                profilePicture: task.userPhoto,
                                task: task,
                                showAuthorRow: showDate,
                              ),
                            )
                          else
                            Expanded(
                              child: RecurringTaskArticleWidget(
                                name: task.userName,
                                profilePicture: task.userPhoto,
                                task: task,
                                showAuthorRow: showDate,
                              ),
                            ),
                        ],
                      );
                    },
                  );
                return Center(child: LoadingWidget());
              }),
        ),
      ),
    );
  }
}
