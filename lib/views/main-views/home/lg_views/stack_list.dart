import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stackedtasks/config/extensions/hex_color.dart';
import 'package:stackedtasks/models/Goal.dart';
import 'package:stackedtasks/models/Stack.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/views/goal/save_goal/save_goal.dart';
import 'package:stackedtasks/views/stack/save_stack.dart';
import 'package:stackedtasks/widgets/home/tiles/lg_stack_tile.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';
import 'package:stackedtasks/widgets/shared/app_date_view.dart';
import 'package:get/get.dart';
import 'package:stackedtasks/widgets/shared/app_error_widget.dart';
import 'package:stackedtasks/constants/models/goal.dart' as goal_constants;
import 'package:stackedtasks/constants/models/stack.dart' as stack_constants;

class HomeLGStackListView extends StatefulWidget {
  final Goal goal;
  final TasksStack selectedStack;
  final Function(TasksStack) onSelectStack;

  HomeLGStackListView({
    Key key,
    this.goal,
    this.selectedStack,
    this.onSelectStack,
  }) : super(key: key);

  @override
  _HomeLGStackListViewState createState() => _HomeLGStackListViewState();
}

class _HomeLGStackListViewState extends State<HomeLGStackListView> {
  _editGoal() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SaveGoalPage(goal: widget.goal),
    );
  }

  _deleteGoal() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Delete Goal',
            style: Theme.of(context).textTheme.headline6,
          ),
          content: Text(
              'Would you really like to delete \'${widget.goal.title.toUpperCase()}\' ?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            TextButton(
              onPressed: () async {
                toggleLoading(state: true);
                await widget.goal.delete();
                toggleLoading(state: false);
                Navigator.of(context).pop();
              },
              child: Text(
                'Delete',
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }

  int limit = 10;
  int elementsCount = 10;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          elementsCount == limit)
        setState(() {
          limit += 10;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Color(0xFFAAAAAA),
            width: .5,
          ),
          left: BorderSide(
            color: Color(0xFFAAAAAA),
            width: .5,
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 16.0,
        ),
        controller: _scrollController,
        children: [
          Row(
            children: [
              Expanded(
                child: Hero(
                  tag: widget.goal.id,
                  child: Text(
                    widget.goal.title.toUpperCase(),
                    style: Theme.of(context).textTheme.headline5.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AppDateView(
                    label: 'From:',
                    date: widget.goal.startDate,
                  ),
                ),
                Expanded(
                  child: AppDateView(
                    label: 'To:',
                    date: widget.goal.endDate,
                  ),
                ),
                AppActionButton(
                  icon: Icons.edit,
                  onPressed: _editGoal,
                  backgroundColor: Theme.of(context).accentColor,
                  margin: EdgeInsets.only(left: 8, right: 4),
                ),
                AppActionButton(
                  icon: Icons.delete,
                  onPressed: _deleteGoal,
                  backgroundColor: Colors.red,
                  margin: EdgeInsets.only(left: 4),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Stacks:',
                      style: Theme.of(context).textTheme.headline5.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    InkWell(
                      onTap: () => Get.to(
                        () => SaveStackPage(
                          goalRef: widget.goal.id,
                          goalColor: widget.goal.color,
                        ),
                      ),
                      child: Icon(
                        Icons.add_circle_outline_rounded,
                        size: 32.0,
                        color: HexColor.fromHex(widget.goal.color),
                      ),
                    ),
                  ],
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection(goal_constants.STACKS_KEY)
                      .where(
                        stack_constants.GOAL_REF_KEY,
                        isEqualTo: widget.goal.id,
                      )
                      .orderBy(stack_constants.CREATION_DATE_KEY,
                          descending: true)
                      .limit(limit)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.docs.length > 0)
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.docs.length,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final stack = TasksStack.fromJson(
                              snapshot.data.docs[index].data(),
                              goalRef: widget.goal.id,
                              goalTitle: widget.goal.title,
                              id: snapshot.data.docs[index].id,
                            );

                            return LGStackTile(
                              stack: stack,
                              selected: widget.selectedStack?.id == stack.id,
                              onSelected: () => widget.onSelectStack(stack),
                            );
                          },
                        );
                      else
                        return AppErrorWidget(
                          status: 404,
                          customMessage: 'No tasks added yet',
                        );
                    }

                    return LoadingWidget();
                  }),
            ],
          )
        ],
      ),
    );
  }
}
