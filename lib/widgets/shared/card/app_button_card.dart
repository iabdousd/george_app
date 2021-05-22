import 'package:flutter/material.dart';

class AppButtonCard extends StatelessWidget {
  final String text;
  final Widget icon;
  final VoidCallback onPressed;
  final TextStyle textStyle;
  final EdgeInsets margin;

  const AppButtonCard({
    Key key,
    @required this.text,
    @required this.icon,
    @required this.onPressed,
    this.textStyle,
    this.margin: const EdgeInsets.all(16.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 4,
            ),
          ],
        ),
        margin: margin,
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            IconTheme(
              data: IconThemeData(
                color: Theme.of(context).primaryColor,
              ),
              child: icon,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                text,
                style: Theme.of(context).textTheme.headline6.merge(textStyle),
              ),
            )
          ],
        ),
      ),
    );
  }
}
