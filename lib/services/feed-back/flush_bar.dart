import 'package:flutter/material.dart';
import 'package:get/get.dart';

showFlushBar({
  @required String title,
  @required String message,
  bool success = true,
}) {
  Get.showSnackbar(
    GetBar(
      titleText: Text(
        title,
        style: Theme.of(Get.context).textTheme.headline6.copyWith(
              color: Colors.white,
              fontSize: 18,
            ),
      ),
      message: message,
      icon: success
          ? Icon(
              Icons.done,
              color: Colors.green[400],
            )
          : Icon(
              Icons.error_outline,
              color: Colors.red,
            ),
      duration: Duration(seconds: 3),
    ),
  );
}
