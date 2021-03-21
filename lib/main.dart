import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:george_project/views/main.dart';
import 'package:get/get.dart';

import 'config/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'George',
      debugShowCheckedModeBanner: false,
      theme: lightThemeData(context),
      darkTheme: darkThemeData(context),
      home: FutureBuilder<FirebaseApp>(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasData) return MainView();
          return Container();
        },
      ),
    );
  }
}
