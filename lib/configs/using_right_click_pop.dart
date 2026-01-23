/// 自动全屏

import 'dart:io';

import 'package:flutter/material.dart';

import '../basic/commons.dart';
import '../basic/methods.dart';

const _propertyName = "usingRightClickPop";
bool _usingRightClickPop = false;

Future<void> initUsingRightClickPop() async {
  _usingRightClickPop =
      (await methods.loadProperty(_propertyName)) == "true";
}

bool currentUsingRightClickPop() {
  return _usingRightClickPop;
}

Widget usingRightClickPopSetting() {
  if (!(Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    return Container();
  }
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        value: _usingRightClickPop,
        onChanged: (value) async {
          await methods.saveProperty(_propertyName, "$value");
          _usingRightClickPop = value;
          setState(() {});
        },
        title: const Text("鼠标右键返回上一页"),
      );
    },
  );
}
