import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/views/main-views/inbox-views/inbox_main_view.dart';

import 'package:stackedtasks/widgets/goal/GoalTile.dart';
import 'package:stackedtasks/constants/models/goal.dart' as goal_constants;
import 'package:stackedtasks/constants/user.dart' as user_constants;
import 'package:stackedtasks/models/Goal.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/widgets/shared/app_error_widget.dart';

class HomeViewSM extends StatefulWidget {
  final StreamController<int> pageIndexStreamController;

  const HomeViewSM({Key key, this.pageIndexStreamController}) : super(key: key);

  @override
  _HomeViewSMState createState() => _HomeViewSMState();
}

class _HomeViewSMState extends State<HomeViewSM>
    with AutomaticKeepAliveClientMixin {
  int elementsCount = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Text(
              'Stackedtasks',
              style: Theme.of(context).textTheme.headline4.copyWith(
                    fontFamily: 'logo',
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size(MediaQuery.of(context).size.width, 54),
            child: Container(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: 0.0,
              ),
              child: TabBar(
                tabs: [
                  Tab(
                    child: Text(
                      'Inbox',
                      style: Theme.of(context).textTheme.headline5.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Goals',
                      style: Theme.of(context).textTheme.headline5.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  InboxMainView(
                    pageIndexStreamController: widget.pageIndexStreamController,
                  ),
                  Container(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection(goal_constants.GOALS_KEY)
                          .where(goal_constants.USER_ID_KEY,
                              isEqualTo: getCurrentUser().uid)
                          .orderBy(goal_constants.CREATION_DATE_KEY,
                              descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          elementsCount = snapshot.data.docs.length;
                          if (snapshot.data.docs.length > 0)
                            return ListView.builder(
                              itemCount: snapshot.data.docs.length,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              itemBuilder: (context, index) {
                                return GoalListTileWidget(
                                  goal: Goal.fromJson(
                                    snapshot.data.docs[index].data(),
                                    id: snapshot.data.docs[index].id,
                                  ),
                                );
                              },
                            );
                          else
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: AppErrorWidget(
                                  status: 404,
                                  customMessage:
                                      'Nothing here. Create a Goal by pressing + to get started',
                                ),
                              ),
                            );
                        }
                        if (snapshot.hasError) {
                          print(snapshot.error);
                          return AppErrorWidget();
                        }
                        return LoadingWidget();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
