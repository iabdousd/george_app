import 'package:flutter/material.dart';
import 'package:george_project/config/extensions/hex_color.dart';
import 'package:george_project/models/Goal.dart';

class GoalListTileWidget extends StatelessWidget {
  final Goal goal;

  const GoalListTileWidget({Key key, @required this.goal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 12.0,
        color: HexColor.fromHex(goal.color),
        margin: EdgeInsets.symmetric(vertical: 4),
      ),
      title: Text(goal.title),
    );
  }
}
