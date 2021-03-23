import 'package:flutter/material.dart';

class AppErrorWidget extends StatelessWidget {
  final int status;

  const AppErrorWidget({Key key, this.status = 500}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
