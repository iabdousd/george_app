import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stackedtasks/models/Task.dart';
import 'package:stackedtasks/repositories/task/task_repository.dart';
import 'package:stackedtasks/services/feed-back/flush_bar.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:stackedtasks/services/storage/image_upload.dart';
import 'package:stackedtasks/widgets/activity_feed/cards/onetime_task_article.dart';
import 'package:stackedtasks/widgets/activity_feed/cards/recurring_task_article.dart';
import 'package:stackedtasks/widgets/shared/app_action_button.dart';

class AddPostPhoto extends StatefulWidget {
  final Task task;
  AddPostPhoto({Key key, this.task}) : super(key: key);

  @override
  _AddPostPhotoState createState() => _AddPostPhotoState();
}

class _AddPostPhotoState extends State<AddPostPhoto> {
  PickedFile image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Post Photo'),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 16.0,
          ),
          children: [
            if (widget.task.repetition != null)
              RecurringTaskArticleWidget(
                name: widget.task.userName,
                profilePicture: widget.task.userPhoto,
                showAuthorRow: true,
                task: widget.task.copyWith(
                  taskPhoto: image?.path,
                ),
                showActions: false,
                showNotes: false,
                localTaskPhoto: image != null,
              )
            else
              OnetimeTaskArticleWidget(
                name: widget.task.userName,
                profilePicture: widget.task.userPhoto,
                showAuthorRow: true,
                task: widget.task.copyWith(
                  taskPhoto: image?.path,
                ),
                showActions: false,
                showNotes: false,
                localTaskPhoto: image != null,
              ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: AppActionButton(
                      onPressed: choosePhoto,
                      label: 'Choose Photo',
                      icon: Icons.image_search_rounded,
                      margin: EdgeInsets.zero,
                    ),
                  ),
                  SizedBox(width: 16),
                  AppActionButton(
                    onPressed: submitImage,
                    label: 'Save',
                    icon: Icons.done,
                    margin: EdgeInsets.zero,
                    backgroundColor: Colors.green[500],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  submitImage() async {
    toggleLoading(state: true);
    String taskPhoto = await uploadFile(image);
    final res = await TaskRepository.addTaskPostPhoto(widget.task, taskPhoto);
    toggleLoading(state: false);
    if (res) {
      Navigator.pop(context);
      showFlushBar(
        title: 'Photo Added',
        message: 'The Photo was Added Successfully',
      );
    } else
      showFlushBar(
        title: 'Error',
        message: 'Couldn\'t add the Photo',
        success: false,
      );
  }

  _pickImage(ImageSource imageSource) async {
    PickedFile _image;

    try {
      _image = await ImagePicker().getImage(
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
    if (_image != null)
      setState(() {
        image = _image;
        Navigator.pop(context);
      });
  }

  choosePhoto() {
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
          color: Theme.of(context).backgroundColor,
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
      ),
    );
  }
}

/**
 * Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
                borderRadius: BorderRadius.circular(8.0),
                color: Theme.of(context).backgroundColor,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: InkWell(
                  onTap: choosePhoto,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.image_search_rounded,
                            color:
                                Theme.of(context).primaryColor.withOpacity(.66),
                            size: 20,
                          ),
                        ),
                        Text(
                          'Choose Image',
                          style: Theme.of(context).textTheme.subtitle1.copyWith(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(.66),
                                fontWeight: FontWeight.w600,
                              ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
 */
