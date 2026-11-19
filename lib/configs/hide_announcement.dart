import 'package:flutter/material.dart';

import '../basic/methods.dart';
import 'is_pro.dart';

const _propertyName = "hideAnnouncement";
late bool _hideAnnouncement;

Future<void> initHideAnnouncement() async {
  _hideAnnouncement = (await methods.loadProperty(_propertyName)) == "true";
  if (!isPro && _hideAnnouncement) {
    _hideAnnouncement = false;
    await methods.saveProperty(_propertyName, "false");
  }
}

bool currentHideAnnouncement() {
  return isPro && _hideAnnouncement;
}

Widget hideAnnouncementSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        title: const Text("不展示公告"),
        subtitle: Text(_hideAnnouncement ? "是" : "否"),
        value: _hideAnnouncement,
        onChanged: (value) async {
          await methods.saveProperty(_propertyName, "$value");
          _hideAnnouncement = value;
          setState(() {});
        },
      );
    },
  );
}
