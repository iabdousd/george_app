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
          style: TextStyle(
            color: Color(0xFF3B404A),
            fontSize: 14,
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
        'Unknown error, please try again!',
        textAlign: TextAlign.center,
      ),
    );
  }
}
