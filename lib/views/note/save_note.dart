import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:george_project/models/Note.dart';
import 'package:george_project/services/feed-back/flush_bar.dart';
import 'package:george_project/services/feed-back/loader.dart';
import 'package:george_project/widgets/shared/app_action_button.dart';
import 'package:george_project/widgets/shared/app_appbar.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

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
  List<Asset> images = [];
  List<File> files = [];

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

  _pickImage() async {
    setState(() {
      images = [];
    });

    List<Asset> resultList;

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        selectedAssets: images,
      );
    } on Exception {
      showFlushBar(title: 'Error', message: 'Unknown error happened while importing your images.', success: false,);
    }
    if (!mounted) return;

    setState(() {
      images = resultList;
    });
  }

  _pickDocument() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf', 'doc'],
    );

    if (result != null) {
      files = result.paths.map((path) => File(path)).toList();
    }
  }

  addAttachment() {
    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      expand: false,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppActionButton(
              onPressed: _pickImage,
              icon: Icons.image_outlined,
              label: 'Image',
              backgroundColor: Theme.of(context).backgroundColor,
              textStyle: Theme.of(context).textTheme.headline6,
              iconColor: Theme.of(context).primaryColor,
              shadows: [],
              margin: EdgeInsets.only(bottom: 4, top: 4),
              iconSize: 28,
            ),
            AppActionButton(
              onPressed: _pickDocument,
              icon: Icons.image_outlined,
              label: 'Document',
              backgroundColor: Theme.of(context).backgroundColor,
              textStyle: Theme.of(context).textTheme.headline6,
              iconColor: Theme.of(context).primaryColor,
              shadows: [],
              margin: EdgeInsets.only(bottom: 4, top: 0),
              iconSize: 28,
            ),
          ],
        ),
      ),
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
              AppActionButton(
                onPressed: addAttachment,
                icon: Icons.attach_file,
                label: 'Add attachment',
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
