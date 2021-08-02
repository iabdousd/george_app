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
                                      widget.user.photoURL,
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(96),
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
                            onPressed: () => !snapshot.hasData
                                ? null
                                : UserService.followUser(widget.user),
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
                  return ListView(
                    addAutomaticKeepAlives: true,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    children: snapshot.data.map(
                      (task) {
                        bool showDate = false;
                        if (lastDate == null) {
                          showDate = true;
                        } else
                          showDate = !(lastDate.day == task.creationDate.day &&
                              lastDate.month == task.creationDate.month &&
                              lastDate.year == task.creationDate.year);

                        lastDate = task.creationDate;
                        return Column(
                          children: [
                            if (showDate)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 16.0,
                                  bottom: 8.0,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        DateFormat('EEEE, MMMM dd')
                                            .format(lastDate),
                                        style: TextStyle(
                                          color: Color(0xFFB2B5C3),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      DateFormat('hh:mm').format(lastDate),
                                      style: TextStyle(
                                        color: Color(0xFFB2B5C3),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (task.repetition == null)
                              OnetimeTaskArticleWidget(
                                name: task.userName,
                                profilePicture: task.userPhoto,
                                task: task,
                                showAuthorRow: true,
                              )
                            else
                              RecurringTaskArticleWidget(
                                name: task.userName,
                                profilePicture: task.userPhoto,
                                task: task,
                                showAuthorRow: true,
                              ),
                          ],
                        );
                      },
                    ).toList(),
                  );
                return Center(child: LoadingWidget());
              }),
        ),
      ),
    );
  }
}
