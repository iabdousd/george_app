import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:stackedtasks/services/cache/images/cached_image.dart';

import '../../models/cache/cached_image.dart';

class CachedImageProvider extends ImageProvider<CachedImageProvider> {
  final String url;
  final List<String> customPathList;
  final int quality, minHeight, minWidth;

  CachedImageProvider(
    this.url, {
    this.customPathList,
    this.quality: 80,
    this.minHeight: 120,
    this.minWidth: 120,
  });

  @override
  ImageStreamCompleter load(CachedImageProvider key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(decode),
      scale: 1.0,
      debugLabel: url,
      informationCollector: () sync* {
        yield ErrorDescription('Path: $url');
      },
    );
  }

  Future<ui.Codec> _loadAsync(DecoderCallback decode) async {
    if (kIsWeb) {
      final res = await http.get(
        Uri.parse(url),
      );

      return await decode(res.bodyBytes);
    }
    try {
      final cachedImage = await getCachedImage(
        url,
        customPathList: this.customPathList,
        quality: this.quality,
      );

      final file = File(cachedImage.filePath);
      final Uint8List bytes = await file.readAsBytes();

      if (bytes.lengthInBytes == 0) {
        PaintingBinding.instance?.imageCache?.evict(this);
        throw StateError('$url is empty and cannot be loaded as an image.');
      }

      return await decode(bytes);
    } on FileSystemException {
      final res = await http.get(
        Uri.parse(url),
      );

      final cachedImage = await cacheImage(
        url,
        res.bodyBytes,
        customPathList: this.customPathList,
        quality: this.quality,
      );

      final file = File(cachedImage.filePath);
      final Uint8List bytes = await file.readAsBytes();

      if (bytes.lengthInBytes == 0) {
        PaintingBinding.instance?.imageCache?.evict(this);
        throw StateError('$url is empty and cannot be loaded as an image.');
      }

      return await decode(bytes);
    }
  }

  @override
  Future<CachedImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CachedImageProvider>(this);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    bool res = other is CachedImageProvider && other.url == url;
    return res;
  }

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() =>
      '${objectRuntimeType(this, 'CacheImageProvider')}("$url")';
}
