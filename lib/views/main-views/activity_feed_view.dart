import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:george_project/providers/cache/cached_image_provider.dart';
import 'package:george_project/views/feed/feed_articles_list.dart';
import 'package:george_project/views/feed/goals_summary.dart';
import 'package:george_project/views/profile/profile_page.dart';
import 'package:george_project/widgets/activity_feed/week_progress.dart';
import 'package:get/get.dart';

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
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    super.build(context);
    return NestedScrollView(
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
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  margin: const EdgeInsets.only(top: 32.0, bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                          "Activity feed",
                          style: Theme.of(context)
                              .textTheme
                              .headline5
                              .copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      InkWell(
                        onTap: () => Get.to(
                          () => ProfilePage(name: "George"),
                          transition: Transition.rightToLeft,
                        ),
                        child: Hero(
                          tag: 'progile_logo',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(64),
                            child: Image(
                              image: CachedImageProvider(
                                  'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500'),
                              fit: BoxFit.cover,
                              width: 36,
                              height: 36,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // TodayTasks(),
                WeekProgress(),
              ],
            ),
          ),
          expandedHeight: size.width / 1.7 + 180,
          bottom: TabBar(
            indicatorColor: Colors.black,
            labelColor: Colors.black,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.article_outlined),
                    Text(' Activity'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.stacked_bar_chart),
                    Text(' Goals summary'),
                  ],
                ),
              ),
            ],
            controller: _tabController,
          ),
        ),
      ],
      body: Container(
        child: TabBarView(
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
