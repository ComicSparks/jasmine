import 'package:flutter/material.dart';

import '../basic/commons.dart';
import '../basic/methods.dart';
import 'is_pro.dart';

const _propertyName = "exportRename";
late bool _exportRename;

Future<void> initExportRename() async {
  _exportRename = (await methods.loadProperty(_propertyName)) == "true";
}

bool currentExportRename() {
  return _exportRename;
}

Widget exportRenameSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        value: _exportRename,
        onChanged: !isPro
            ? null
            : (value) async {
                await methods.saveProperty(_propertyName, "$value");
                _exportRename = value;
                setState(() {});
              },
        title: Text(
          "导出的时候重新命名",
          style: TextStyle(
            color: !isPro ? Colors.grey : null,
          ),
        ),
      );
    },
  );
}
