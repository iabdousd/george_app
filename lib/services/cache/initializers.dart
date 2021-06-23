import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:stackedtasks/models/cache/cached_image.dart';
import 'package:stackedtasks/models/cache/contact_user.dart';
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

  // CONTACTS BOXES
  if (!Hive.isAdapterRegistered(ContactUserAdapter().typeId))
    Hive.registerAdapter<ContactUser>(ContactUserAdapter());

  if (!Hive.isBoxOpen(CONTACT_USER_BOX_NAME))
    await Hive.openLazyBox<ContactUser>(CONTACT_USER_BOX_NAME);

  removeOutdatedImages();
}
