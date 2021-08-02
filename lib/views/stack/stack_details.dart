import 'package:flutter/material.dart';
import 'package:stackedtasks/models/Stack.dart';
import 'package:stackedtasks/views/stack/stack_body_view.dart';
import 'package:stackedtasks/views/task/save_task.dart';
import 'package:stackedtasks/widgets/shared/foundation/app_app_bar.dart';

class StackDetailsPage extends StatefulWidget {
  final TasksStack stack;

  StackDetailsPage({
    Key key,
    @required this.stack,
  }) : super(key: key);

  @override
  _StackDetailsPageState createState() => _StackDetailsPageState();
}

class _StackDetailsPageState extends State<StackDetailsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        context: context,
        leading: IconButton(
          onPressed: Navigator.of(context).pop,
          icon: Icon(Icons.arrow_back_ios),
          color: Theme.of(context).backgroundColor,
        ),
        customTitle: Text(
          '${widget.stack.goalTitle} > ${widget.stack.title}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: StackBodyView(
          stack: widget.stack,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => SaveTaskPage(
            stackRef: widget.stack.id,
            stackTitle: widget.stack.title,
            stackColor: widget.stack.color,
            stackPartners: widget.stack.partnersIDs,
            goalRef: widget.stack.goalRef,
            goalTitle: widget.stack.goalTitle,
          ),
        ),
        child: Icon(
          Icons.add,
          color: Theme.of(context).backgroundColor,
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }
}
