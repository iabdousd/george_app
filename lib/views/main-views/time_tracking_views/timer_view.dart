import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stackedtasks/widgets/task/tasks_timer_list.dart';

class TimerView extends StatefulWidget {
  TimerView({Key key}) : super(key: key);

  @override
  _TimerViewState createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView>
    with AutomaticKeepAliveClientMixin {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scrollbar(
      child: Padding(
        padding: kIsWeb
            ? EdgeInsets.symmetric(
                horizontal: (MediaQuery.of(context).size.width - 600) / 2)
            : EdgeInsets.zero,
        child: TasksTimerList(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
