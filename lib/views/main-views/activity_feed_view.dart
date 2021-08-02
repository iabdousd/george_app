import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/views/feed/feed_articles_list.dart';
import 'package:stackedtasks/views/feed/goal_summary_list.dart';
import 'package:stackedtasks/views/profile/profile_page.dart';
import 'package:stackedtasks/widgets/activity_feed/week_progress.dart';
import 'package:get/get.dart';
import 'package:stackedtasks/widgets/shared/foundation/app_app_bar.dart';

class ActivityFeedView extends StatefulWidget {
  ActivityFeedView({Key key}) : super(key: key);

  @override
  _ActivityFeedViewState createState() => _ActivityFeedViewState();
}

class _ActivityFeedViewState extends State<ActivityFeedView>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  ScrollController _scrollViewController;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _scrollViewController = ScrollController();
    _tabController = TabController(vsync: this, length: 2)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    super.build(context);
    return Scaffold(
      appBar: AppAppBar(
        context: context,
      ),
      body: NestedScrollView(
        controller: _scrollViewController,
        headerSliverBuilder: (context, bool) => [
          SliverAppBar(
            pinned: false,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    margin: const EdgeInsets.only(top: 16.0, bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: Text(
                            "Activity feed",
                            style: TextStyle(
                              color: Color(0xFF3B404A),
                              fontWeight: FontWeight.w600,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => Get.to(
                            () => ProfilePage(),
                            transition: Transition.rightToLeft,
                          ),
                          child: Hero(
                            tag: 'progile_logo',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(64),
                              child:
                                  FirebaseAuth.instance.currentUser.photoURL !=
                                          null
                                      ? Image(
                                          image: CachedImageProvider(
                                            FirebaseAuth
                                                .instance.currentUser.photoURL,
                                          ),
                                          fit: BoxFit.cover,
                                          width: 28,
                                          height: 28,
                                        )
                                      : SvgPicture.asset(
                                          'assets/images/profile.svg',
                                          fit: BoxFit.cover,
                                          width: 28,
                                          height: 28,
                                        ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!kIsWeb) WeekProgress(),
                ],
              ),
            ),
            expandedHeight: kIsWeb ? 90 : size.width / 2 + 172,
            bottom: PreferredSize(
              preferredSize: Size(size.width, 34),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                child: TabBar(
                  indicatorColor: Colors.transparent,
                  labelColor: Theme.of(context).backgroundColor,
                  unselectedLabelColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(
                    fontSize: 16,
                  ),
                  labelPadding: EdgeInsets.zero,
                  tabs: [
                    Tab(
                      child: Container(
                        decoration: BoxDecoration(
                          color: _tabController.index == 0
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).backgroundColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            bottomLeft: Radius.circular(32),
                            topRight: Radius.circular(0),
                            bottomRight: Radius.circular(0),
                          ),
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        constraints: BoxConstraints.expand(),
                        alignment: Alignment.center,
                        child: Text(
                          'Activity',
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        decoration: BoxDecoration(
                          color: _tabController.index == 1
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).backgroundColor,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                            topLeft: Radius.circular(0),
                            bottomLeft: Radius.circular(0),
                          ),
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        constraints: BoxConstraints.expand(),
                        alignment: Alignment.center,
                        child: Text(
                          'Projects summary',
                        ),
                      ),
                    ),
                  ],
                  controller: _tabController,
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            FeedArticlesList(),
            GoalsSummaryView(),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
