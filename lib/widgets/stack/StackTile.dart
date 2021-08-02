import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackedtasks/config/extensions/hex_color.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/views/stack/save_stack.dart';
import 'package:stackedtasks/views/stack/stack_details.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:stackedtasks/models/Stack.dart';
import 'package:stackedtasks/views/task/save_task.dart';

class StackListTileWidget extends StatelessWidget {
  final TasksStack stack;
  final VoidCallback onLongPress;
  final VoidCallback onClickEvent;
  final bool selected;

  const StackListTileWidget({
    Key key,
    @required this.stack,
    this.onLongPress,
    this.onClickEvent,
    this.selected: false,
  }) : super(key: key);

  _deleteStack(context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Delete Stack',
            style: Theme.of(context).textTheme.headline6,
          ),
          content: Text(
              'Would you really like to delete \'${stack.title.toUpperCase()}\' ?'),
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
                await stack.delete();
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

  _editStack(context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SaveStackPage(
        stack: stack,
        goalRef: stack.goalRef,
        goalColor: stack.color,
      ),
    );
  }

  void _openStackDetailsPage() => Get.to(
        () => StackDetailsPage(
          stack: stack,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: onClickEvent ?? _openStackDetailsPage,
        onLongPress: onLongPress,
        child: Slidable(
          actionPane: SlidableScrollActionPane(),
          actionExtentRatio: 0.25,
          child: Container(
            decoration: BoxDecoration(
              color: selected
                  ? Color.lerp(
                      Theme.of(context).primaryColor,
                      Theme.of(context).backgroundColor,
                      .5,
                    )
                  : Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 8.0,
                  offset: Offset(0, 3),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Center(
                  child: Container(
                    width: 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      color: HexColor.fromHex(stack.color),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          stack.title,
                          style: Theme.of(context).textTheme.headline6.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => SaveTaskPage(
                      stackRef: stack.id,
                      goalRef: stack.goalRef,
                      stackPartners: stack.partnersIDs ?? [],
                      stackColor: stack.color,
                      goalTitle: stack.goalTitle,
                      stackTitle: stack.title,
                    ),
                  ).then((value) =>
                      value != null && value ? _openStackDetailsPage() : null),
                  child: Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: SvgPicture.asset(
                      'assets/images/icons/add.svg',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SvgPicture.asset(
                    'assets/images/icons/drag_indicator.svg',
                  ),
                ),
              ],
            ),
          ),
          secondaryActions: <Widget>[
            IconSlideAction(
              onTap: () => _editStack(context),
              iconWidget: LayoutBuilder(builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth - 24,
                  height: constraints.maxWidth - 24,
                  margin: EdgeInsets.only(
                    left: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 6.0,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  child: Icon(
                    Icons.edit,
                    color: Theme.of(context).backgroundColor,
                    size: 32.0,
                  ),
                );
              }),
              closeOnTap: true,
            ),
            IconSlideAction(
              iconWidget: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: constraints.maxWidth - 24,
                    height: constraints.maxWidth - 24,
                    margin: EdgeInsets.only(
                      right: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 6.0,
                          offset: Offset(0, 3),
                        )
                      ],
                    ),
                    child: Icon(
                      Icons.delete,
                      color: Theme.of(context).backgroundColor,
                      size: 32.0,
                    ),
                  );
                },
              ),
              closeOnTap: true,
              onTap: () => _deleteStack(context),
            ),
          ],
        ),
      ),
    );
  }
}
