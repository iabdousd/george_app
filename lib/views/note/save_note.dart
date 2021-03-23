import 'package:flutter/material.dart';

import 'package:george_project/models/Note.dart';
import 'package:george_project/services/feed-back/flush_bar.dart';
import 'package:george_project/services/feed-back/loader.dart';
import 'package:george_project/widgets/shared/app_appbar.dart';

class SaveNotePage extends StatefulWidget {
  final String goalRef;
  final String stackRef;
  final Note note;
  SaveNotePage(
      {Key key, @required this.goalRef, @required this.stackRef, this.note})
      : super(key: key);

  @override
  _SaveNotePageState createState() => _SaveNotePageState();
}

class _SaveNotePageState extends State<SaveNotePage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _contentController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  _submitNote() async {
    if (!_formKey.currentState.validate()) return;
    toggleLoading(state: true);
    await Note(
      goalRef: widget.goalRef,
      stackRef: widget.stackRef,
      id: widget.note?.id,
      content: _contentController.text,
      creationDate: DateTime.now(),
    ).save();
    toggleLoading(state: false);
    Navigator.of(context).pop();
    showFlushBar(
      title: 'Note added successfully!',
      message: 'You can now see your note in notes list.',
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _contentController.text = widget.note.content ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appAppBar(
        title: widget.note != null ? 'Note details' : 'New Note',
        actions: [
          TextButton(
            onPressed: _submitNote,
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
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: 'Note content',
                    hintText: 'The content of the note',
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
                  validator: (t) {
                    if (t.isEmpty)
                      return 'Please enter the content of the note first';
                    return null;
                  },
                  minLines: 2,
                  maxLines: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
