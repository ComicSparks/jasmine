import 'dart:io';

import 'package:flutter/material.dart';

import '../basic/commons.dart';
import '../basic/methods.dart';

const _propertyName = "searchTitleWords";
late bool _searchTitleWords;

Future<void> initSearchTitleWords() async {
  var str = await methods.loadProperty(_propertyName);
  if (str == "") {
    str = "false";
  }
  _searchTitleWords = str == "true";
}

bool currentSearchTitleWords() {
  return _searchTitleWords;
}

Widget searchTitleWordsSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        value: _searchTitleWords,
        onChanged: (value) async {
          await methods.saveProperty(_propertyName, "$value");
          _searchTitleWords = value;
          setState(() {});
        },
        title: const Text("标题中的关键字点击搜索"),
      );
    },
  );
}
