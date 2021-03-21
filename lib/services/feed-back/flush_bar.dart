import 'package:flutter/material.dart';
import 'package:get/get.dart';

showFlushBar({
  @required String title,
  @required String message,
  bool success = true,
}) {
  Get.showSnackbar(
    GetBar(
      title: title,
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
