import 'package:flutter/material.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';

import 'main-views/main.dart';
import 'start_guide/guides_screen.dart';

class AppViews extends StatefulWidget {
  AppViews({Key key}) : super(key: key);

  @override
  _AppViewsState createState() => _AppViewsState();
}

class _AppViewsState extends State<AppViews> {
  Future<bool> _initialization = checkAuthorization();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasData) if (snapshot.data)
          return MainView();
        else
          return GuidesScreen();

        if (snapshot.hasError) {
          return Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error ocurred, please try again!',
                    textAlign: TextAlign.center,
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () => setState(
                      () {
                        // toggleLoading(state: true);
                        _initialization = checkAuthorization();
                        // .then(
                        //   (value) => toggleLoading(state: false),
                        // );
                      },
                    ),
                    child: Text(
                      'Try again',
                    ),
                  ),
                ),
              ],
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
