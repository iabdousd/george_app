import 'package:flutter/material.dart';
import 'package:george_project/models/Goal.dart';
import 'package:george_project/providers/cache/cached_image_provider.dart';
import 'package:intl/intl.dart';

class GoalSummaryWidget extends StatelessWidget {
  final Goal goal;
  final String name, profilePicture;
  const GoalSummaryWidget({
    Key key,
    @required this.goal,
    @required this.name,
    @required this.profilePicture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Color(0x22000000),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(42.0),
                  child: Image(
                    image: CachedImageProvider(profilePicture),
                    fit: BoxFit.cover,
                    width: 42,
                    height: 42,
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      DateFormat('EEE, dd MMM yyyy   hh:mm a')
                          .format(goal.creationDate),
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
            child: Table(
              columnWidths: {
                0: FractionColumnWidth(.25),
              },
              border: TableBorder(
                verticalInside: BorderSide(
                  color: Color(0x22000000),
                ),
                horizontalInside: BorderSide(
                  color: Color(0x22000000),
                ),
              ),
              children: [
                TableRow(
                  children: [
                    FittedBox(
                      child: Text(
                        'Time allocated',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ),
                    Container(),
                    Container(),
                  ],
                ),
                TableRow(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 8.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              'Goal 1 is too bigG!!',
                              style: Theme.of(context).textTheme.subtitle1,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Text(
                            '2h 45m',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Container(),
                    Container(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
