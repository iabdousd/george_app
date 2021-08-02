import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/widgets/shared/bottom_sheet_head.dart';

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
  bool publicPost;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  _submitArticle() async {
    if (!_formKey.currentState.validate()) return;
    toggleLoading(state: true);
    final allPartners = await widget.task.getAllPartners();
    await (widget.task
          ..status = 2
          ..title = _titleController.text
          ..description = _descriptionController.text)
        .saveAsFeed(
      (publicPost ? ['*'] : <String>[]) + allPartners,
    );
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
      publicPost = widget.task.to?.contains('*') ?? false;
      _titleController.text = widget.task.title ?? '';
      _descriptionController.text = widget.task.description ?? '';
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
      margin: EdgeInsets.only(
        top: 50,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            BottomSheetHead(
              title: 'Feed Article',
              onSubmit: _submitArticle,
            ),
            Container(
              margin: EdgeInsets.only(top: 16),
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
            // Row(
            //   children: [
            //     Switch(
            //       value: publicPost,
            //       onChanged: (val) => setState(() => publicPost = val),
            //     ),
            //     Text(
            //       'Share To Public',
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
