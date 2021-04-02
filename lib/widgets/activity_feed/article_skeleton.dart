import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ArticleSkeletonWidget extends StatelessWidget {
  const ArticleSkeletonWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Color(0x22000000),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(4),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300],
        highlightColor: Colors.grey[100],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    left: 8.0,
                    right: 12.0,
                    bottom: 8.0,
                    top: 4.0,
                  ),
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(
                      left: 0.0,
                      right: 8.0,
                      bottom: 8.0,
                      top: 4.0,
                    ),
                    height: 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                bottom: 8.0,
                top: 4.0,
              ),
              height: 24,
              color: Theme.of(context).backgroundColor,
              width: double.infinity,
            ),
            Container(
              margin: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                bottom: 8.0,
                top: 4.0,
              ),
              height: 18,
              color: Theme.of(context).backgroundColor,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
