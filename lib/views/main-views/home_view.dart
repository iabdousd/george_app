import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stackedtasks/views/main-views/home/home_view_lg.dart';
import 'package:stackedtasks/views/main-views/home/home_view_sm.dart';

class HomeView extends StatefulWidget {
  final StreamController<int> pageIndexStreamController;

  const HomeView({Key key, this.pageIndexStreamController}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with AutomaticKeepAliveClientMixin {
  int elementsCount = 10;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return HomeViewLG();
        }
        return HomeViewSM(
          pageIndexStreamController: widget.pageIndexStreamController,
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
