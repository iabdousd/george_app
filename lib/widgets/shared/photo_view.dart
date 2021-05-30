import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class AppPhotoView extends StatelessWidget {
  final ImageProvider imageProvider;
  const AppPhotoView({Key key, this.imageProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          PhotoView(
            imageProvider: imageProvider,
            minScale: PhotoViewComputedScale.contained,
          ),
          Positioned(
            left: 0,
            top: 0,
            child: SafeArea(
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
