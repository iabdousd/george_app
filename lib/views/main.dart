import 'package:flutter/material.dart';
import 'package:george_project/services/user/user_service.dart';

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text(getCurrentUser().uid),
          ],
        ),
      ),
    );
  }
}
