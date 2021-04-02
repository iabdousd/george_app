import 'package:george_project/models/Task.dart';
import 'package:share/share.dart';

shareTask(Task task) async {
  await Share.share(
    'I have just reached ${task.completionRate}% of my task ${task.title}!',
  );
}
