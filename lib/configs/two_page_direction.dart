import 'package:flutter/material.dart';
import 'package:jasmine/basic/commons.dart';
import 'package:jasmine/basic/methods.dart';

enum TwoPageDirection {
  leftToRight,
  rightToLeft,
}

const _propertyName = "twoPageDirection";
late TwoPageDirection _twoPageDirection;

Future initTwoPageDirection() async {
  _twoPageDirection = _fromString(await methods.loadProperty(_propertyName));
}

TwoPageDirection _fromString(String valueForm) {
  for (var value in TwoPageDirection.values) {
    if (value.toString() == valueForm) {
      return value;
    }
  }
  return TwoPageDirection.values.first;
}

TwoPageDirection get currentTwoPageDirection => _twoPageDirection;

String twoPageDirectionName(TwoPageDirection direction, BuildContext context) {
  switch (direction) {
    case TwoPageDirection.leftToRight:
      return "从左到右";
    case TwoPageDirection.rightToLeft:
      return "从右到左";
  }
}

Future chooseTwoPageDirection(BuildContext context) async {
  final Map<String, TwoPageDirection> map = {};
  for (var element in TwoPageDirection.values) {
    map[twoPageDirectionName(element, context)] = element;
  }
  final newTwoPageDirection = await chooseMapDialog(
    context,
    title: "请选择阅读器方向",
    values: map,
  );
  if (newTwoPageDirection != null) {
    await methods.saveProperty(_propertyName, "$newTwoPageDirection");
    _twoPageDirection = newTwoPageDirection;
  }
}

Widget twoGalleryDirectionSetting(BuildContext context) {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        onTap: () async {
          await chooseTwoPageDirection(context);
          setState(() {});
        },
        title: const Text("双页阅读器方向"),
        subtitle: Text(twoPageDirectionName(_twoPageDirection, context)),
      );
    },
  );
}

