import 'dart:io';

import 'package:flutter/material.dart';

import '../basic/commons.dart';
import '../basic/methods.dart';

const _propertyName = "displayJmcode";
late bool _displayJmcode;

Future<void> initDisplayJmcode() async {
  var str = await methods.loadProperty(_propertyName);
  if (str == "") {
    str = "true";
  }
  _displayJmcode = str == "true";
}

bool currentDisplayJmcode() {
  return _displayJmcode;
}

Widget displayJmcodeSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        value: _displayJmcode,
        onChanged: (value) async {
          await methods.saveProperty(_propertyName, "$value");
          _displayJmcode = value;
          setState(() {});
        },
        title: const Text("显示漫画代码"),
      );
    },
  );
}
