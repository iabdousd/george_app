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
          SizedBox(
            height: 16,
          ),
          Text(
            'You haven\'t completed any tasks!',
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ],
      ),
    );
  }
}
