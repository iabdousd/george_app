import 'package:flutter/material.dart';

class AppErrorWidget extends StatelessWidget {
  final int status;
  final String customMessage;
  const AppErrorWidget({Key key, this.status = 500, this.customMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (customMessage != null)
      return Center(
        child: Text(
          customMessage,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyText1.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .color
                    .withOpacity(.75),
              ),
        ),
      );

    if (status == 404) {
      return Center(
        child: Text(
          'No data found',
          textAlign: TextAlign.center,
        ),
      );
    }
    return Center(
      child: Text(
        'Error',
        textAlign: TextAlign.center,
      ),
    );
  }
}
