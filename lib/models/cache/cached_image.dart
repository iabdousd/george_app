import 'package:hive/hive.dart';

part 'cached_image.g.dart';

String cachedImagesBoxName = 'cached_images_bpx';

@HiveType(typeId: 0)
class CachedImage extends HiveObject {
  @HiveField(0)
  String url;
  @HiveField(1)
  String filePath;
  @HiveField(2)
  DateTime creationDate;
  @HiveField(3)
  DateTime lastUseDate;
  @HiveField(4)
  int usesCount;
  @HiveField(5)
  int quality;

  CachedImage({
    this.url,
    this.filePath,
    this.creationDate,
    this.lastUseDate,
    this.usesCount,
    this.quality,
  });

  Future declareUsage() async {
    this.usesCount = this.usesCount ?? 0;
    this.usesCount++;
    this.lastUseDate = DateTime.now();
    await this.save();
  }
}
