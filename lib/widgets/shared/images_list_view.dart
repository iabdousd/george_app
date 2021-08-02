import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stackedtasks/providers/cache/cached_image_provider.dart';
import 'package:stackedtasks/services/feed-back/loader.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'package:stackedtasks/models/Attachment.dart';
import 'package:stackedtasks/services/file/open_file.dart';

class ImagesListView extends StatelessWidget {
  final List<String> customPathList;
  final List<PickedFile> images;
  final bool readOnly;
  final double imageHeight;
  final List<Attachment> networkImages;
  final Function(dynamic) deleteEvent;
  const ImagesListView({
    Key key,
    @required this.images,
    @required this.deleteEvent,
    this.readOnly = false,
    this.networkImages = const [],
    this.customPathList = const [],
    this.imageHeight,
  }) : super(key: key);

  _zoomImage(BuildContext context, file, {PickedFile asset}) async {
    List<File> fileImages = [];
    for (var e in images)
      fileImages.add(
        File(e.path),
      );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ZoomedImagesView(
          galleryItems: List<dynamic>.from(networkImages)
                  .where(
                    (element) =>
                        ['png', 'jpg', 'jpeg', 'gif'].contains(element.ext),
                  )
                  .toList() +
              List<dynamic>.from(fileImages),
          initialIndex: file is Attachment
              ? networkImages.indexOf(file)
              : networkImages.length + images.indexOf(asset),
          customPathList: customPathList,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.0,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          mainAxisExtent: imageHeight,
        ),
        padding: EdgeInsets.only(top: 4.0),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: networkImages
                .map((e) => !['png', 'jpg', 'jpeg', 'gif'].contains(e.ext)
                    ? InkWell(
                        onTap: () => OpenFileService.openNetworkFile(
                          e.path,
                          e.ext,
                        ),
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(178, 181, 195, 0.2),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            e.ext?.toUpperCase() ?? '?',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : Container(
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
                            onTap: () => _zoomImage(context, e),
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
                                if (!readOnly && deleteEvent != null)
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
                        onTap: () => _zoomImage(
                          context,
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
                            if (!readOnly && deleteEvent != null)
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
            final item = galleryItems[index];
            return PhotoViewGalleryPageOptions(
              imageProvider: item is Attachment
                  ? CachedImageProvider(
                      item.path,
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
