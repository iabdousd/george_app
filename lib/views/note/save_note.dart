import 'package:flutter/material.dart';
import 'package:george_project/services/shared/text/text_to_spans.dart';
import 'package:image_picker/image_picker.dart';

import 'package:george_project/models/Note.dart';
import 'package:george_project/services/feed-back/flush_bar.dart';
import 'package:george_project/services/feed-back/loader.dart';
import 'package:george_project/widgets/shared/app_action_button.dart';
import 'package:george_project/widgets/shared/app_appbar.dart';
import 'package:george_project/widgets/shared/images_list_view.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class SaveNotePage extends StatefulWidget {
  final String goalRef;
  final String stackRef;
  final Note note;
  final String taskRef;
  final String taskTitle;
  SaveNotePage({
    Key key,
    @required this.goalRef,
    @required this.stackRef,
    this.note,
    this.taskRef,
    this.taskTitle,
  }) : super(key: key);

  @override
  _SaveNotePageState createState() => _SaveNotePageState();
}

class _SaveNotePageState extends State<SaveNotePage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _contentController = TextEditingController();

  List<TextSpan> displaySpans = [];

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  List<PickedFile> images = [];
  bool editing = false;

  _submitNote() async {
    if (!editing) {
      Navigator.of(context).pop();
      return;
    }
    if (!_formKey.currentState.validate()) return;
    toggleLoading(state: true);
    Note note = Note(
      goalRef: widget.goalRef,
      stackRef: widget.stackRef,
      id: widget.note?.id,
      taskRef: widget.taskRef,
      taskTitle: widget.taskTitle,
      content: _contentController.text,
      creationDate: DateTime.now(),
      attachmentsCount: widget.note?.attachmentsCount ?? 0,
    );
    await note.save();

    await note.addAttachments(images);

    toggleLoading(state: false);
    Navigator.of(context).pop();
    showFlushBar(
      title: 'Note added successfully!',
      message: 'You can now see your note in notes list.',
    );
  }

  _pickImage(ImageSource imageSource) async {
    PickedFile image;

    try {
      image = await ImagePicker().getImage(
        imageQuality: 80,
        source: imageSource,
      );
    } on Exception catch (e) {
      print(e);
      showFlushBar(
        title: 'Error',
        message: 'Unknown error happened while importing your images.',
        success: false,
      );
    }
    if (image != null)
      setState(() {
        images.add(image);
      });
  }

  addAttachment() {
    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      expand: false,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.0),
            topRight: Radius.circular(12.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppActionButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: Icons.image_outlined,
              label: 'Photos',
              backgroundColor: Theme.of(context).backgroundColor,
              textStyle: Theme.of(context).textTheme.headline6,
              iconColor: Theme.of(context).primaryColor,
              shadows: [],
              margin: EdgeInsets.only(bottom: 0, top: 4),
              iconSize: 28,
            ),
            AppActionButton(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: Icons.camera_alt_outlined,
              label: 'Camera',
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

  init() async {
    await widget.note.fetchAttachments();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    editing = widget.note == null;
    if (widget.note != null) {
      List<TextSpan> textSpans = textToSpans(
        widget.note.taskRef != null
            ? ('%*b' +
                widget.note.taskTitle +
                '%*l - Task notes ' +
                DateFormat('EEE, dd MMM').format(
                  widget.note.creationDate,
                ) +
                '\n%*n' +
                widget.note.content)
            : ('%*b' +
                widget.note.content +
                '%*l - created ' +
                DateFormat('EEE, dd MMM').format(
                  widget.note.creationDate,
                )),
        initialTextSize: 16,
      );
      displaySpans = textSpans;

      _contentController.text = widget.note.content;
      init();
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
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: !editing
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 10.0,
                        ),
                        margin: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            width: 1,
                            color: Color(0x55000000),
                          ),
                        ),
                        child: RichText(
                          text: TextSpan(
                            children: displaySpans,
                            style:
                                Theme.of(context).textTheme.subtitle1.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 4,
                        ),
                      )
                    : TextFormField(
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
                        enabled: editing,
                        validator: (t) {
                          if (t.isEmpty)
                            return 'Please enter the content of the note first';
                          return null;
                        },
                        minLines: 2,
                        maxLines: 100,
                      ),
              ),
              AppActionButton(
                onPressed: editing
                    ? addAttachment
                    : () => setState(
                          () {
                            editing = true;
                          },
                        ),
                icon: editing ? Icons.attach_file : Icons.edit,
                label: editing ? 'Add attachment' : 'Edit',
                backgroundColor: editing
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).accentColor,
              ),
              ImagesListView(
                images: images,
                readOnly: !editing,
                networkImages: widget.note?.attachments ?? [],
                deleteEvent: _deleteImage,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _deleteImage(image) async {
    if (image is PickedFile)
      setState(() {
        images.remove(image);
      });
    else {
      toggleLoading(state: true);
      await widget.note.deleteAttachment(image);
      setState(() {});
      toggleLoading(state: false);
    }
  }
}
