import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/widgets/shared/app_appbar.dart';

class SaveTaskFeedArticle extends StatefulWidget {
  final Task task;
  SaveTaskFeedArticle({
    Key key,
    @required this.task,
  }) : super(key: key);

  @override
  _SaveTaskFeedArticleState createState() => _SaveTaskFeedArticleState();
}

class _SaveTaskFeedArticleState extends State<SaveTaskFeedArticle> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  _submitArticle() async {
    if (!_formKey.currentState.validate()) return;
    toggleLoading(state: true);

    await (widget.task
          ..title = _titleController.text
          ..description = _descriptionController.text
          ..status = 2)
        .saveAsFeed(widget.task.partnersIDs);
    toggleLoading(state: false);
    Navigator.of(context).pop();
    showFlushBar(
      title: 'Article edited successfully!',
      message: 'You can now see your article edited in the activity feed.',
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task.title ?? '';
      _descriptionController.text = widget.task.description ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appAppBar(
        title: 'Feed Article',
        actions: [
          TextButton(
            onPressed: _submitArticle,
            child: Text(
              'Done',
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Article title',
                    hintText: 'The title of the article',
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 20.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(width: 1),
                    ),
                  ),
                  validator: (t) {
                    if (t.isEmpty) return 'The article title is required';
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Article description',
                    hintText: 'The description of the article',
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 20.0,
                    ),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(width: 1),
                    ),
                  ),
                  minLines: 5,
                  maxLines: 7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
