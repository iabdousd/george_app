import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CircularActionButton extends StatelessWidget {
  final VoidCallback onClick;
  final Widget icon;
  final String title;
  final TextStyle titleStyle;
  final Color backgroundColor;
  final BoxDecoration decoration;
  final EdgeInsets padding, margin;
  final bool expandWidth, loading;
  final double width, height;
  const CircularActionButton({
    Key key,
    @required this.onClick,
    this.icon,
    @required this.title,
    this.titleStyle,
    this.backgroundColor: Colors.transparent,
    this.decoration,
    this.padding: const EdgeInsets.all(10),
    this.margin: const EdgeInsets.only(
      top: 16,
      bottom: 10,
      left: 6,
      right: 6,
    ),
    this.width,
    this.height,
    this.expandWidth: false,
    this.loading: false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: margin,
      decoration: decoration ??
          BoxDecoration(
            color: backgroundColor ?? Theme.of(context).accentColor,
            borderRadius: BorderRadius.circular(64),
          ),
      width: expandWidth ? double.infinity : width,
      height: expandWidth ? double.infinity : height,
      child: InkWell(
        onTap: onClick,
        child: Padding(
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) icon,
              Padding(
                padding: EdgeInsets.only(left: icon == null ? 0 : 6.0),
                child: loading
                    ? Container(
                        height: 22,
                        width: 22,
                        child: SpinKitFadingCircle(
                          size: 22,
                          itemBuilder: (BuildContext context, int index) {
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                color: titleStyle?.color ??
                                    Theme.of(context).backgroundColor,
                                shape: BoxShape.circle,
                              ),
                            );
                          },
                        ),
                      )
                    : Text(
                        title,
                        style: titleStyle ??
                            TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).backgroundColor,
                            ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
