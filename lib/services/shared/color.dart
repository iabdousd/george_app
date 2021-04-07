import 'package:flutter/material.dart';
import 'package:plandoraslist/config/extensions/hex_color.dart';
import 'package:get/get.dart';

const List<String> availableColors = [
  '#f7f13b',
  '#ed5858',
  '#70f065',
  '#eba373',
  '#eb73d7',
  '#4b9ede',
  '#DAEDBD',
  '#7DBBC3',
  '#E5B181',
  '#DE6B48',
  '#750D37',
  '#210124',
  '#B3DEC1',
  '#E5FCF5',
  '#FEFFFE',
  '#759FBC',
  '#1F5673',
  '#463730',
  '#04F06A',
];

pickColor(Function update) {
  showDialog(
    context: Get.context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'The color of your goal item',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 18.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * .7,
              height: 40.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: availableColors
                    .map(
                      (e) => Center(
                        child: InkWell(
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
                      ),
                    )
                    .toList(),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              'Scroll horizontally to see more colors',
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    fontWeight: FontWeight.w200,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    },
  );
}
