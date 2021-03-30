import 'package:flutter/material.dart';
import 'package:george_project/services/cache/initializers.dart';
import 'package:george_project/services/user/user_service.dart';
import 'package:george_project/views/main.dart';
import 'package:get/get.dart';

import 'config/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeCache();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future _initialization = Future.wait([
    createUser(),
  ]);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'George',
      debugShowCheckedModeBanner: false,
      theme: lightThemeData(context),
      darkTheme: darkThemeData(context),
      home: FutureBuilder<dynamic>(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasData) return MainView();

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
      ),
    );
  }
}
