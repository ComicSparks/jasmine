import 'dart:io';

import 'package:flutter/material.dart';

import '../basic/commons.dart';
import '../basic/methods.dart';

const _propertyName = "noAnimation";
late bool _noAnimation;

Future<void> initNoAnimation() async {
  _noAnimation =
      (await methods.loadProperty(_propertyName)) == "true";
}

bool currentNoAnimation() {
  return _noAnimation;
}

Future<void> setNoAnimation(bool value) async {
  _noAnimation = value;
  await methods.saveProperty(_propertyName, "$value");
}

Future<void> _chooseNoAnimation(BuildContext context) async {
  String? result = await chooseListDialog<String>(context,
      title: "取消键盘或音量翻页动画", values: ["是", "否"]);
  if (result != null) {
    await setNoAnimation(result == "是");
  }
}

Widget noAnimationSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: const Text("取消键盘或音量翻页动画"),
        subtitle: Text(_noAnimation ? "是" : "否"),
        onTap: () async {
          await _chooseNoAnimation(context);
          setState(() {});
        },
      );
    },
  );
}
