import 'dart:io';
import 'dart:isolate';
import 'package:stackedtasks/models/cache/cached_image.dart';
import 'package:hive/hive.dart';

void remover(List message) async {
  SendPort _sendPort = message[0];
  for (List image in message[1]) {
    final file = File(image[1]);
    if (file.existsSync()) await file.delete();
    _sendPort.send(image[0]);
  }
}

removeOutdatedImages() async {
  LazyBox<CachedImage> box = Hive.lazyBox<CachedImage>(cachedImagesBoxName);

  List<CachedImage> cachedImages = [];
  for (var key in box.keys) {
    cachedImages.add(await box.get(key));
  }

  ReceivePort _receivePort;

  List<CachedImage> toRemoveImages = cachedImages
      .where(
        (element) => element.lastUseDate.isBefore(
          DateTime.now().subtract(
            Duration(days: 7),
          ),
        ),
      )
      .toList();

  _receivePort = ReceivePort();
  await Isolate.spawn(remover, [
    _receivePort.sendPort,
    List.from(toRemoveImages.map((e) => [e.key, e.filePath]).toList())
  ]);

  _receivePort.listen((message) async {
    await box.delete(message);
  });
}
