import 'package:event/event.dart';
import 'package:flutter/material.dart';

import '../basic/commons.dart';
import '../basic/methods.dart';
import 'is_pro.dart';

const _propertyName = "disableRecommendContent";
late bool _disableRecommendContent;
final disableRecommendContentEvent = Event();

Future<void> initDisableRecommendContent() async {
  _disableRecommendContent =
      (await methods.loadProperty(_propertyName)) == "true";
  if (!isPro) {
    _disableRecommendContent = false;
  }
}

bool currentDisableRecommendContent() {
  return _disableRecommendContent;
}

Widget disableRecommendContentSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        title: Text(
          "关闭推荐内容" + (!isPro ? "\n(发电后使用)" : ""),
          style: TextStyle(color: isPro ? null : Colors.grey),
        ),
        subtitle: Text(_disableRecommendContent ? "已关闭" : "已开启"),
        value: _disableRecommendContent,
        onChanged: (value) async {
          if (!isPro) {
            defaultToast(context, "发电才能使用哦~");
            return;
          }
          await methods.saveProperty(_propertyName, "$value");
          _disableRecommendContent = value;
          disableRecommendContentEvent.broadcast();
          setState(() {});
        },
      );
    },
  );
}
