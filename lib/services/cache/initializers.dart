import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:stackedtasks/models/cache/cached_image.dart';
import 'images/removers.dart';

initializeCache() async {
  await initializeHive();
}

initializeHive() async {
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(CachedImageAdapter().typeId))
    Hive.registerAdapter<CachedImage>(CachedImageAdapter());

  if (!Hive.isBoxOpen(cachedImagesBoxName))
    await Hive.openLazyBox<CachedImage>(cachedImagesBoxName);

  await removeOutdatedImages();
}
