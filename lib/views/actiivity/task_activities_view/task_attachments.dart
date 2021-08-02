import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stackedtasks/config/app_preferences.dart';
import 'package:stackedtasks/constants/feed.dart';
import 'package:stackedtasks/constants/models/stack.dart';
import 'package:stackedtasks/models/Note.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/repositories/note/note_repository.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/user/user_service.dart';
import 'package:stackedtasks/widgets/note/note_thread_tile.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';
import 'package:stackedtasks/widgets/shared/app_text_field.dart';

class TaskAttachments extends StatefulWidget {
  final Task task;
  const TaskAttachments({
    Key key,
    @required this.task,
  }) : super(key: key);

  @override
  _TaskAttachmentsState createState() => _TaskAttachmentsState();
}

class _TaskAttachmentsState extends State<TaskAttachments> {
  final _commentController = TextEditingController();
  List<PickedFile> _images = [];
  List<PlatformFile> attachments = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Attchments',
            style: TextStyle(
              color: Color(0xFF3B404A),
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Note>>(
            stream: NoteRepository.streamFeedAttachmentComments(widget.task),
            builder: (context, snapshot) {
              print(snapshot.error);
              if (snapshot.hasData) {
                if (snapshot.data.isEmpty)
                  return Center(
                    child: Text(
                      'No attachments, be the first one to send an attachments!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF767C8D),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                final notes = snapshot.data;
                return ListView.builder(
                  itemCount: notes.length,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    return NoteThreadTile(
                      note: notes[index],
                    );
                  },
                );
              } else
                return LoadingWidget();
            },
          ),
        ),
        if (_images.isNotEmpty || attachments.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final file in [...attachments, ..._images])
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
                                () => _images.remove(file),
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
        Row(
          children: [
            InkWell(
              onTap: _addAttachment,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.attach_file_rounded,
                  color: Theme.of(context).accentColor,
                  size: 24,
                ),
              ),
            ),
            Expanded(
              child: AppTextField(
                controller: _commentController,
                hint: 'Type something...',
                containerDecoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: Color.fromRGBO(241, 240, 243, 1),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(22.0),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.newline,
              ),
            ),
            InkWell(
              onTap: _sendAttachment,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                    colors: [
                      Theme.of(context).accentColor,
                      Theme.of(context).primaryColor,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(left: 16),
                child: Icon(
                  Icons.send_rounded,
                  color: Theme.of(context).backgroundColor,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  _addAttachment() {
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
                onPressed: () => _pickImage(ImageSource.camera),
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                backgroundColor: Colors.transparent,
                textStyle: Theme.of(context).textTheme.headline6,
                iconColor: Theme.of(context).primaryColor,
                shadows: [],
                margin: EdgeInsets.only(bottom: 4, top: 0),
                iconSize: 28,
              ),
              AppActionButton(
                onPressed: _pickAttachment,
                icon: Icons.attach_file_rounded,
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

  _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        attachments.addAll(result.files);
      });
    }
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
        _images.add(image);
      });
  }

  void _sendAttachment() async {
    if (_images.isEmpty && attachments.isEmpty) {
      return;
    }
    toggleLoading(state: true);
    Note note = Note(
      userID: getCurrentUser().uid,
      status: 0,
      content: _commentController.text.trim(),
      goalRef: widget.task.goalRef,
      stackRef: widget.task.stackRef,
      taskRef: widget.task.taskID,
      feedArticleID: widget.task.id,
      taskTitle: widget.task.title,
      creationDate: DateTime.now(),
    );

    await note.save();

    if (_images.isNotEmpty || attachments.isNotEmpty)
      await note.addAttachments([
        ...attachments,
        ..._images,
      ]);

    final articleDocument = await FirebaseFirestore.instance
        .collection(TASKS_KEY)
        .doc(widget.task.taskID)
        .get();

    await articleDocument.reference.update({
      COMMENTS_COUNT_KEY: (articleDocument.data()[COMMENTS_COUNT_KEY] ?? 0) + 1,
    });

    await AppPreferences.preferences.setInt(
      '${widget.task.id}_comments_count',
      (AppPreferences.preferences.getInt('${widget.task.id}_comments_count') ??
              0) +
          1,
    );

    setState(() {
      _images.clear();
      _commentController.clear();
      attachments.clear();
    });

    toggleLoading(state: false);
    showFlushBar(
      title: 'Note added successfully!',
      message: 'You can now see your note in notes list.',
    );
  }
}
