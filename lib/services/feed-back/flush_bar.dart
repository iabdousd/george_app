import 'package:flutter/material.dart';
import 'package:get/get.dart';

showFlushBar({
  @required String title,
  @required String message,
  bool success = true,
}) {
  // ScaffoldMessenger.of(Get.context).showSnackBar(
  //   SnackBar(
  //     padding: EdgeInsets.all(8),
  //     backgroundColor: Colors.transparent,
  //     elevation: 0,
  //     content: Container(
  //       decoration: BoxDecoration(
  //         color: Theme.of(Get.context).backgroundColor,
  //         borderRadius: BorderRadius.circular(16.0),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Color(0x22000000),
  //             blurRadius: 6,
  //             offset: Offset(0, 2),
  //           ),
  //         ],
  //       ),
  //       padding: EdgeInsets.symmetric(
  //         horizontal: 12,
  //         vertical: 8,
  //       ),
  //       child: Row(
  //         children: [
  //           Padding(
  //             padding: EdgeInsets.only(right: 8),
  //             child: success
  //                 ? Icon(
  //                     Icons.done,
  //                     color: Colors.green[400],
  //                   )
  //                 : Icon(
  //                     Icons.error_outline,
  //                     color: Colors.red,
  //                   ),
  //           ),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Text(
  //                   title,
  //                   style: Theme.of(Get.context).textTheme.subtitle1.copyWith(
  //                         fontWeight: FontWeight.w600,
  //                         fontSize: 14,
  //                         color: success ? Colors.green[400] : Colors.red,
  //                       ),
  //                 ),
  //                 Text(
  //                   message,
  //                   style: Theme.of(Get.context).textTheme.subtitle1.copyWith(
  //                         fontWeight: FontWeight.w400,
  //                         fontSize: 12,
  //                       ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   ),
  // );
  Get.showSnackbar(
    GetBar(
      backgroundColor: success ? Color(0xFF67DA6C) : Colors.red,
      margin: EdgeInsets.all(20),
      borderRadius: 14.0,
      titleText: Text(
        title,
        style: Theme.of(Get.context).textTheme.headline6.copyWith(
              color: Theme.of(Get.context).backgroundColor,
              fontSize: 18,
            ),
      ),
      messageText: Text(
        message,
        style: Theme.of(Get.context).textTheme.subtitle1.copyWith(
              color: Theme.of(Get.context).backgroundColor,
              fontSize: 14,
            ),
      ),
      icon: success
          ? Icon(
              Icons.done,
              color: Theme.of(Get.context).backgroundColor,
            )
          : Icon(
              Icons.error_outline,
              color: Theme.of(Get.context).backgroundColor,
            ),
      duration: Duration(seconds: 3),
    ),
  );
}
