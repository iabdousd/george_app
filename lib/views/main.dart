import 'package:flutter/material.dart';
import 'package:plandoraslist/services/user/user_service.dart';

import 'auth/main.dart';
import 'main-views/main.dart';

class AppViews extends StatefulWidget {
  AppViews({Key key}) : super(key: key);

  @override
  _AppViewsState createState() => _AppViewsState();
}

class _AppViewsState extends State<AppViews> {
  final Future<bool> _initialization = checkAuthorization();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasData) if (snapshot.data)
          return MainView();
        else
          return AuthViews();

        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Center(
            child: Container(
              child: Icon(Icons.error_outline, color: Colors.red),
            ),
          );
        }

        return Container(
          color: Colors.white,
        );
      },
    );
  }
}
