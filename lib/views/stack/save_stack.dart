import 'package:flutter/material.dart';
import 'package:stackedtasks/constants/models/inbox_item.dart';
import 'package:stackedtasks/models/Stack.dart' as stack_model;
import 'package:stackedtasks/repositories/inbox/inbox_repository.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';

class SaveStackPage extends StatefulWidget {
  final String goalRef;
  final String goalColor;
  final stack_model.TasksStack stack;
  final List<String> goalPartnerIDs;
  SaveStackPage({
    Key key,
    @required this.goalRef,
    this.stack,
    @required this.goalColor,
    this.goalPartnerIDs,
  }) : super(key: key);

  @override
  _SaveStackPageState createState() => _SaveStackPageState();
}

class _SaveStackPageState extends State<SaveStackPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  _submitStack() async {
    if (!_formKey.currentState.validate()) return;
    toggleLoading(state: true);

    if (widget.goalRef == 'inbox') {
      final res = await InboxRepository.saveInboxItem(
        INBOX_STACK_ITEM_TYPE,
        data: stack_model.TasksStack(
          userID: getCurrentUser().uid,
          partnersIDs: [],
          goalRef: widget.goalRef,
          id: widget.stack?.id,
          title: _titleController.text,
          color: widget.goalColor,
          creationDate: DateTime.now(),
          status: 0,
          goalTitle: 'Inbox',
        ).toJson(),
        reference: widget.stack?.id,
      );
      if (!res.status) {
        await toggleLoading(state: false);
        await showFlushBar(
          title: 'Error',
          message:
              'An error occurred while adding your stack to the inbox. Please try again later.',
          success: false,
        );
        return;
      }
    } else {
      final stack = stack_model.TasksStack(
        id: widget.stack?.id,
        goalRef: widget.goalRef,
        userID: getCurrentUser().uid,
        partnersIDs: widget.stack?.partnersIDs ?? widget.goalPartnerIDs ?? [],
        title: _titleController.text,
        color: widget.goalColor,
        creationDate: DateTime.now(),
        status: 0,
        goalTitle: 'Inbox',
      );

      await stack.save();
    }
    toggleLoading(state: false);
    Navigator.of(context).pop(true);
    showFlushBar(
      title: 'Stack added successfully!',
      message: 'You can now see your stack in stacks list.',
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.stack != null) {
      _titleController.text = widget.stack.title;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).backgroundColor,
      ),
      padding: MediaQuery.of(context).viewInsets +
          EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).padding.bottom + 8,
          ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Color(0xFFB2B6C3),
              width: 28,
              height: 3,
              margin: EdgeInsets.symmetric(vertical: 12),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: Navigator.of(context).pop,
                  child: Text(
                    'CANCEL',
                    style: TextStyle(
                      color: Color(0xFFB2B6C3),
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'New Stack',
                    style: TextStyle(
                      color: Color(0xFF767C8D),
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                TextButton(
                  onPressed: _submitStack,
                  child: Text(
                    'DONE',
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextFormField(
                controller: _titleController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Stack title',
                  hintText: 'The title of the stack',
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 20.0,
                  ),
                  border: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(width: 1),
                  ),
                ),
                validator: (t) =>
                    t.isEmpty ? 'Please enter the stack\'s title' : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
