import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:george_project/constants/models/goal.dart' as goal_constants;
import 'package:george_project/constants/user.dart' as user_constants;
import 'package:george_project/constants/models/stack.dart' as stack_constants;
import 'package:george_project/models/Stack.dart' as stack_model;
import 'package:george_project/models/Goal.dart';
import 'package:george_project/services/feed-back/loader.dart';
import 'package:george_project/services/user/user_service.dart';
import 'package:george_project/views/stack/save_stack.dart';
import 'package:george_project/widgets/shared/app_error_widget.dart';
import 'package:george_project/widgets/stack/StackTile.dart';
import 'package:get/get.dart';

class StacksListView extends StatelessWidget {
  final Goal goal;
  const StacksListView({Key key, @required this.goal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
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
                      fontWeight: FontWeight.w900,
                    ),
              ),
              InkWell(
                onTap: () => Get.to(
                  () => SaveStackPage(goalRef: goal.id),
                ),
                child: Icon(
                  Icons.add_circle_outline_rounded,
                  size: 32.0,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
        StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(user_constants.USERS_KEY)
                .doc(getCurrentUser().uid)
                .collection(goal_constants.GOALS_KEY)
                .doc(goal.id)
                .collection(goal_constants.STACKS_KEY)
                .orderBy(stack_constants.CREATION_DATE_KEY, descending: true)
                .limit(10)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) if (snapshot.data.docs.length > 0)
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return StackListTileWidget(
                      stack: stack_model.Stack.fromJson(
                        snapshot.data.docs[index].data(),
                        goalRef: goal.id,
                        id: snapshot.data.docs[index].id,
                      ),
                    );
                  },
                );
              else
                return AppErrorWidget(status: 404);

              return LoadingWidget();
            }),
      ],
    );
  }
}
