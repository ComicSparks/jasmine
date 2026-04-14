import 'package:flutter/material.dart';

import '../basic/methods.dart';
import 'passed.dart';

const _propertyName = "alwaysEnterBrowser";
late bool _alwaysEnterBrowser;

Future<void> initAlwaysEnterBrowser() async {
  _alwaysEnterBrowser = (await methods.loadProperty(_propertyName)) == "true";
}

bool currentAlwaysEnterBrowser() {
  return _alwaysEnterBrowser;
}

Widget alwaysEnterBrowserSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        title: const Text("每次进入都是浏览器"),
        subtitle: Text(_alwaysEnterBrowser ? "已开启" : "已关闭"),
        value: _alwaysEnterBrowser,
        onChanged: (value) async {
          await methods.saveProperty(_propertyName, "$value");
          _alwaysEnterBrowser = value;
          if (value) {
            await clearPassed();
          }
          setState(() {});
        },
      );
    },
  );
}
