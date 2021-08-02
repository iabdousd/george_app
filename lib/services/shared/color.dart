import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stackedtasks/config/extensions/hex_color.dart';
import 'package:get/get.dart';

const List<String> availableColors = [
  '#2F80ED',
  '#56CCF2',
  '#8E2DE2',
  '#4A00E0',
  '#334B66',
  '#141E30',
  '#1B7592',
  '#8B89D4',
  '#35008C',
  '#CEB7FF',
  '#56F2DF',
  '#56F2A7',
];

get randomColor => availableColors[Random().nextInt(availableColors.length)];

pickColor(Function(String) update) {
  showDialog(
    context: Get.context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Please choose a color',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * .7,
                // height: 90,
                child: GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    childAspectRatio: 1,
                  ),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: availableColors
                      .map(
                        (e) => InkWell(
                          onTap: () {
                            update(e);
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.brightness_1,
                              color: HexColor.fromHex(e),
                              size: 32,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
