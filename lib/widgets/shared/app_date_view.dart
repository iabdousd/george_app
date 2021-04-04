import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppDateView extends StatelessWidget {
  final String label;
  final DateTime date;
  final String format;
  const AppDateView(
      {Key key,
      @required this.label,
      @required this.date,
      this.format: 'dd MMM yyyy'})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.subtitle2.copyWith(
                  fontWeight: FontWeight.w300,
                ),
          ),
          Text(
            DateFormat(format).format(date),
            style: Theme.of(context).textTheme.subtitle1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
