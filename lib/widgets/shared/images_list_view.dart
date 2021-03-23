import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:george_project/models/Attachment.dart';
import 'package:george_project/services/feed-back/loader.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class ImagesListView extends StatelessWidget {
  final List<Asset> images;
  final List<Attachment> networkImages;
  final Function(dynamic) deleteEvent;
  const ImagesListView(
      {Key key,
      @required this.images,
      @required this.deleteEvent,
      this.networkImages = const []})
      : super(key: key);

  Future _zooImage(file) {
    //
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
                                  Image.network(
                                    e.path,
                                    fit: BoxFit.cover,
                                    gaplessPlayback: true,
                                  ),
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
                        child: FutureBuilder<ByteData>(
                          future: file.getByteData(quality: 80),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: GestureDetector(
                                  onTap: () => _zooImage(
                                      snapshot.data.buffer.asUint8List()),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.memory(
                                        snapshot.data.buffer.asUint8List(),
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
                              );
                            }
                            return LoadingWidget();
                          },
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
