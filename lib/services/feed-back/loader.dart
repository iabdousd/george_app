import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingWidget extends StatelessWidget {
  final EdgeInsets padding;
  const LoadingWidget({
    Key key,
    this.padding: const EdgeInsets.symmetric(vertical: 64.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Center(
        child: SpinKitFoldingCube(
          itemBuilder: (BuildContext context, int index) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            );
          },
        ),
      ),
    );
  }
}

toggleLoading({@required bool state}) {
  if (state)
    showDialog(
      context: Get.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.black26,
            ),
            child: LoadingWidget(),
          ),
        );
      },
    );
  else
    Get.back();
}
