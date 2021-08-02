import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stackedtasks/constants/feed.dart';
import 'package:stackedtasks/constants/models/stack.dart';
import 'package:stackedtasks/models/Note.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';
import 'package:stackedtasks/widgets/shared/buttons/circular_action_button.dart';

class TaskNoteInput extends StatefulWidget {
  final Task task;
  const TaskNoteInput({
    Key key,
    @required this.task,
  }) : super(key: key);

  @override
  _TaskNoteInputState createState() => _TaskNoteInputState();
}

class _TaskNoteInputState extends State<TaskNoteInput> {
  bool loading = false;
  bool inputActivating = false, inputActivated = false;
  TextEditingController _contentController = TextEditingController();
  List<PickedFile> images = [];
  List<PlatformFile> attachments = [];
  bool privateNotes = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Color.fromRGBO(178, 181, 195, 0.1),
            border: Border.all(
              width: 1,
              color: Color.fromRGBO(178, 181, 195, 0.2),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _contentController,
                  enabled: !loading,
                  decoration: InputDecoration(
                    hintText: 'Add your notes here...',
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0,
                    ),
                    alignLabelWithHint: false,
                    border: InputBorder.none,
                  ),
                  onTap: () => {
                    setState(
                      () => inputActivating = true,
                    ),
                    Future.delayed(Duration(milliseconds: 350)).then(
                      (value) => setState(
                        () => inputActivated = true,
                      ),
                    )
                  },
                  textInputAction: TextInputAction.newline,
                  minLines: 1,
                  maxLines: 10,
                ),
              ),
              if (!inputActivated)
                AnimatedOpacity(
                  duration: Duration(milliseconds: 350),
                  opacity: inputActivating ? 0 : 1,
                  child: IconButton(
                    onPressed: addImage,
                    icon: SvgPicture.asset(
                      'assets/images/icons/picture.svg',
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (images.isNotEmpty || attachments.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(top: 8),
            child: Row(
              children: [
                for (final file in [...attachments, ...images])
                  if (file is PlatformFile)
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ['png', 'jpg', 'jpeg', 'gif']
                                    .contains(file.extension)
                                ? Image.file(
                                    File(file.path),
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 64,
                                    height: 64,
                                    color: Color.fromRGBO(178, 181, 195, 0.2),
                                    alignment: Alignment.center,
                                    child: Text(
                                      file.extension.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                          ),
                          Positioned(
                            child: InkWell(
                              onTap: () => setState(
                                () => attachments.remove(file),
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.red,
                                size: 18,
                              ),
                            ),
                            top: 4,
                            right: 4,
                          ),
                        ],
                      ),
                    )
                  else if (file is PickedFile)
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(file.path),
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            child: InkWell(
                              onTap: () => setState(
                                () => images.remove(file),
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.red,
                                size: 18,
                              ),
                            ),
                            top: 4,
                            right: 4,
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
        if (inputActivating)
          AnimatedOpacity(
            duration: Duration(milliseconds: 350),
            opacity: inputActivating ? 1 : 0,
            child: Container(
              margin: EdgeInsets.only(
                bottom: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: SvgPicture.asset(
                          'assets/images/icons/picture.svg',
                        ),
                      ),
                      IconButton(
                        onPressed: addImage,
                        icon: Icon(Icons.attach_file),
                        color: Color(0xFFB2B5C3),
                      ),
                      Switch(
                        value: privateNotes,
                        inactiveTrackColor: Color(0xFFB2B5C3),
                        activeTrackColor: Theme.of(context).primaryColor,
                        onChanged: (val) => setState(
                          () => privateNotes = val,
                        ),
                      ),
                      Text(
                        'Private',
                        style: TextStyle(
                          color: Color(0xFF767C8D),
                        ),
                      ),
                    ],
                  ),
                  CircularActionButton(
                    onClick: () async {
                      if (loading) return;
                      if (_contentController.text.replaceAll('\n', '').trim() ==
                          '') return;
                      setState(() => loading = true);
                      Note note = Note(
                        userID: getCurrentUser().uid,
                        status: privateNotes ? 1 : 0,
                        content: _contentController.text.trim(),
                        goalRef: widget.task.goalRef,
                        stackRef: widget.task.stackRef,
                        taskRef: widget.task.id,
                        feedArticleID: widget.task.id,
                        taskTitle: widget.task.title,
                        creationDate: DateTime.now(),
                      );
                      await note.save();
                      if (images.isNotEmpty)
                        await note.addAttachments([
                          ...attachments,
                          ...images,
                        ]);

                      if (!privateNotes) {
                        final articleDocument = await FirebaseFirestore.instance
                            .collection(TASKS_KEY)
                            .doc(widget.task.taskID)
                            .get();

                        await articleDocument.reference.update({
                          COMMENTS_COUNT_KEY:
                              (articleDocument.data()[COMMENTS_COUNT_KEY] ??
                                      0) +
                                  1,
                        });
                      }
                      setState(() {
                        _contentController.clear();
                        images.clear();
                        attachments.clear();
                      });
                      setState(() => loading = false);

                      showFlushBar(
                        title: 'Note added successfully!',
                        message: 'You can now see your note in notes list.',
                      );
                    },
                    loading: loading,
                    backgroundColor: Theme.of(context).accentColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 6,
                    ),
                    margin: EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    title: 'ADD',
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 8.0,
          ),
      ],
    );
  }

  addAttachment() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        attachments.addAll(result.files);
      });
    }
  }

  addImage() {
    if (!inputActivating && !inputActivated) {
      setState(
        () => inputActivating = true,
      );
      Future.delayed(Duration(milliseconds: 350)).then(
        (value) => setState(
          () => inputActivated = true,
        ),
      );
    }
    if (kIsWeb) {
      _pickImage(ImageSource.gallery);
      return;
    }

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
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppActionButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: Icons.image_outlined,
                label: 'Photos',
                backgroundColor: Colors.transparent,
                textStyle: Theme.of(context).textTheme.headline6,
                iconColor: Theme.of(context).primaryColor,
                shadows: [],
                margin: EdgeInsets.only(bottom: 0, top: 4),
                iconSize: 28,
              ),
              AppActionButton(
                onPressed: () => addAttachment(),
                icon: Icons.folder_open,
                label: 'Document',
                backgroundColor: Colors.transparent,
                textStyle: Theme.of(context).textTheme.headline6,
                iconColor: Theme.of(context).primaryColor,
                shadows: [],
                margin: EdgeInsets.only(bottom: 4, top: 0),
                iconSize: 28,
              ),
            ],
          ),
        ),
      ),
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
      if (imageSource != ImageSource.gallery)
        _pickImage(ImageSource.gallery);
      else
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
}
