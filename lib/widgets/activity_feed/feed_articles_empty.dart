import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FeedArticlesEmptyWidget extends StatelessWidget {
  const FeedArticlesEmptyWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/tasks_empty.svg',
            width: MediaQuery.of(context).size.width / 4,
            height: MediaQuery.of(context).size.width / 4,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'You have no activity yet!',
              style: TextStyle(
                color: Color(0xFF3B404A),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
