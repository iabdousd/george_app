import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CenteredNotFound extends StatelessWidget {
  final String image;
  final String title, subTitle;
  final double imageWidth;

  const CenteredNotFound({
    Key key,
    this.image: 'assets/images/not-found.svg',
    @required this.title,
    @required this.subTitle,
    this.imageWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            image,
            width: imageWidth ?? (MediaQuery.of(context).size.width - 66),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
              bottom: 8.0,
            ),
            child: Text(
              title,
              style: TextStyle(
                color: Color(0xFF3B404A),
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            subTitle,
            style: TextStyle(
              color: Color(0xFF767C8D),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
