import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NotFoundErrorWidget extends StatelessWidget {
  final String title, message;
  final bool showBanner;
  const NotFoundErrorWidget({
    Key key,
    @required this.title,
    @required this.message,
    this.showBanner: true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          if (showBanner)
            Expanded(
              child: SvgPicture.asset(
                'assets/images/not-found.svg',
                alignment: Alignment.bottomCenter,
              ),
            ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFF3B404A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF767C8D),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
