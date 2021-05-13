import 'package:flutter/material.dart';
import 'package:get/get.dart';

AppBar appAppBar({
  @required String title,
  List<Widget> actions,
  icon = Icons.close,
  canPop: true,
}) {
  return AppBar(
    iconTheme: Theme.of(Get.context).iconTheme,
    leading: canPop
        ? IconButton(
            icon: Icon(icon),
            onPressed: () => Get.back(),
          )
        : null,
    automaticallyImplyLeading: canPop,
    title: Text(
      title,
      style: Theme.of(Get.context).textTheme.headline6,
    ),
    backgroundColor: Theme.of(Get.context).backgroundColor,
    actions: actions,
    centerTitle: true,
  );
}
