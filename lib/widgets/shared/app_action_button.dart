import 'package:flutter/material.dart';

class AppActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final icon;
  final String label;
  final Color backgroundColor;
  final Alignment alignment;
  final double iconSize;
  final TextStyle textStyle;
  final Color iconColor;
  final List<BoxShadow> shadows;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final EdgeInsets iconPadding;
  const AppActionButton({
    Key key,
    @required this.onPressed,
    @required this.icon,
    this.label,
    @required this.backgroundColor,
    this.alignment = Alignment.centerLeft,
    this.iconSize = 20.0,
    this.iconColor,
    this.textStyle,
    this.shadows = const [
      BoxShadow(
        color: Color(0x2F000000),
        blurRadius: 6,
        offset: Offset(0, 3),
      )
    ],
    this.margin = const EdgeInsets.all(8.0),
    this.padding = const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
    this.iconPadding =
        const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: label == null
            ? InkWell(
                onTap: onPressed,
                child: Container(
                  padding: iconPadding,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                  ),
                  child: icon is IconData
                      ? Icon(
                          icon,
                          color: iconColor ?? Theme.of(context).backgroundColor,
                          size: iconSize,
                        )
                      : icon,
                ),
              )
            : TextButton.icon(
                onPressed: onPressed,
                icon: icon is IconData
                    ? Icon(
                        icon,
                        color: iconColor ?? Theme.of(context).backgroundColor,
                        size: iconSize,
                      )
                    : icon,
                style: ButtonStyle(
                  alignment: alignment,
                  backgroundColor: MaterialStateProperty.all(backgroundColor),
                  padding: MaterialStateProperty.all(
                    padding,
                  ),
                ),
                label: Text(
                  label,
                  style: textStyle ??
                      Theme.of(context).textTheme.subtitle1.copyWith(
                            color: Theme.of(context).backgroundColor,
                          ),
                ),
              ),
      ),
    );
  }
}
