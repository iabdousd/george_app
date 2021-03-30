import 'dart:io';

import 'package:flutter/material.dart';
import 'package:george_project/providers/cache/cached_image_provider.dart';
import 'package:george_project/services/feed-back/loader.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'package:george_project/models/Attachment.dart';

class ImagesListView extends StatelessWidget {
  final List<String> customPathList;
  final List<PickedFile> images;
  final bool readOnly;
  final List<Attachment> networkImages;
  final Function(dynamic) deleteEvent;
  const ImagesListView({
    Key key,
    @required this.images,
    @required this.deleteEvent,
    this.readOnly = false,
    this.networkImages = const [],
    this.customPathList = const [],
  }) : super(key: key);

  _zooImage(file, {PickedFile asset}) async {
    List<File> fileImages = [];
    for (var e in images)
      fileImages.add(
        File(e.path),
      );

    Get.to(
      () => ZoomedImagesView(
        galleryItems:
            List<dynamic>.from(networkImages) + List<dynamic>.from(fileImages),
        initialIndex: file is Attachment
            ? networkImages.indexOf(file)
            : networkImages.length + images.indexOf(asset),
        customPathList: customPathList,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (images.length > 0)
            Text(
              'Attached images:',
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            childAspectRatio: 1.0,
            mainAxisSpacing: 12.0,
            crossAxisSpacing: 12.0,
            padding: EdgeInsets.all(12.0),
            children: networkImages
                    .map((e) => Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
                            borderRadius: BorderRadius.circular(4.0),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x22000000),
                                blurRadius: 4,
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: GestureDetector(
                              onTap: () => _zooImage(e),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image(
                                    image: CachedImageProvider(
                                      e.path,
                                      customPathList: customPathList,
                                    ),
                                    fit: BoxFit.cover,
                                    gaplessPlayback: true,
                                    loadingBuilder: (ctx, _, chunk) =>
                                        chunk == null ? _ : LoadingWidget(),
                                  ),
                                  if (!readOnly)
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => deleteEvent(e),
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 32.0,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ))
                    .toList() +
                images
                    .map(
                      (file) => Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          borderRadius: BorderRadius.circular(4.0),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 4,
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: GestureDetector(
                            onTap: () => _zooImage(
                              file,
                              asset: file,
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(
                                  File(file.path),
                                  fit: BoxFit.cover,
                                  gaplessPlayback: true,
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => deleteEvent(file),
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 32.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }
}

class ZoomedImagesView extends StatelessWidget {
  final List<String> customPathList;
  final List galleryItems;
  final int initialIndex;
  const ZoomedImagesView({
    Key key,
    @required this.galleryItems,
    this.initialIndex = 0,
    this.customPathList: const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _pageController = PageController(initialPage: initialIndex);

    return Stack(
      children: [
        Container(
            child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: galleryItems[index] is Attachment
                  ? CachedImageProvider(
                      galleryItems[index].path,
                      quality: 100,
                      customPathList: customPathList,
                    )
                  : FileImage(galleryItems[index]),
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained,
            );
          },
          pageController: _pageController,
          itemCount: galleryItems.length,
          gaplessPlayback: true,
          loadingBuilder: (context, event) => Center(
            child: Container(
              width: 20.0,
              height: 20.0,
              child: CircularProgressIndicator(
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes,
              ),
            ),
          ),
        )),
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(8.0),
            color: Color(0x44000000),
            child: Row(
              children: [
                SafeArea(
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.close,
                      color: Theme.of(context).backgroundColor,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
