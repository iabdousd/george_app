import 'package:flutter/material.dart';
import 'package:stackedtasks/config/extensions/hex_color.dart';
import 'package:stackedtasks/models/Stack.dart';

class LGStackTile extends StatelessWidget {
  final TasksStack stack;
  final bool selected;
  final VoidCallback onSelected;
  const LGStackTile({
    Key key,
    @required this.stack,
    this.selected: false,
    this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected
            ? HexColor.fromHex(stack.color).darken()
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
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(top: 4.0),
      child: GestureDetector(
        onTap: onSelected,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 20.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      color: selected
                          ? Theme.of(context).backgroundColor
                          : HexColor.fromHex(stack.color),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          stack.title.toUpperCase(),
                          style: Theme.of(context).textTheme.headline6.copyWith(
                                color: selected
                                    ? Colors.white
                                    : Theme.of(context)
                                        .textTheme
                                        .headline6
                                        .color,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
