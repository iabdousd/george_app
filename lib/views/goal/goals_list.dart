import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:stackedtasks/models/Goal.dart';
import 'package:stackedtasks/repositories/goal/goal_repository.dart';
import 'package:stackedtasks/views/goal/save_goal/save_goal.dart';
import 'package:stackedtasks/widgets/goal/GoalTile.dart';
import 'package:stackedtasks/widgets/shared/errors-widgets/not_found.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/widgets/shared/app_error_widget.dart';

class GoalsList extends StatefulWidget {
  GoalsList({Key key}) : super(key: key);

  @override
  _GoalsListState createState() => _GoalsListState();
}

class _GoalsListState extends State<GoalsList>
    with AutomaticKeepAliveClientMixin {
  List<Goal> goals = [];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: StreamBuilder<List<Goal>>(
        stream: GoalRepository.streamGoals(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            goals = snapshot.data;
            if (snapshot.data.length > 0)
              return StatefulBuilder(
                builder: (BuildContext context, setState) {
                  return ReorderableListView.builder(
                    onReorder: (oldIndex, newIndex) async {
                      List<Future> futures = [];

                      Goal old = goals[oldIndex];
                      if (oldIndex > newIndex) {
                        for (int i = oldIndex; i > newIndex; i--) {
                          futures.add(
                            GoalRepository.changeGoalOrder(goals[i - 1], i),
                          );
                          goals[i] = goals[i - 1];
                        }
                        futures.add(
                          GoalRepository.changeGoalOrder(old, newIndex),
                        );
                        goals[newIndex] = old;
                      } else {
                        for (int i = oldIndex; i < newIndex - 1; i++) {
                          futures.add(
                            GoalRepository.changeGoalOrder(goals[i + 1], i),
                          );
                          goals[i] = goals[i + 1];
                        }
                        futures.add(
                          GoalRepository.changeGoalOrder(old, newIndex - 1),
                        );
                        goals[newIndex - 1] = old;
                      }
                      setState(() {});
                      await Future.wait(futures);
                    },
                    itemCount: goals.length,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    proxyDecorator: (widget, extent, animation) => Material(
                      child: widget,
                      shadowColor: Colors.transparent,
                      color: Colors.transparent,
                      elevation: animation.value,
                    ),
                    itemBuilder: (context, index) {
                      return GoalListTileWidget(
                        key: Key(goals[index].id),
                        goal: goals[index],
                      );
                    },
                  );
                },
              );
            else
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: NotFoundErrorWidget(
                    title: 'Nothing is here',
                    message: 'Create a Project by pressing + to get started',
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
      floatingActionButton: FadeInUp(
        duration: Duration(milliseconds: 300),
        child: FloatingActionButton(
          child: Icon(
            Icons.add,
            color: Theme.of(context).backgroundColor,
          ),
          backgroundColor: Theme.of(context).accentColor,
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => SaveGoalPage(),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
