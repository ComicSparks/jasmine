import 'package:flutter/material.dart';
import 'package:jasmine/basic/methods.dart';

const _propertyName = "dragRegionLock";
const _defaultDragRegionLock = true;

late bool _dragRegionLock;

Future<void> initDragRegionLock() async {
  final value = await methods.loadProperty(_propertyName);
  if (value == "") {
    _dragRegionLock = _defaultDragRegionLock;
  } else {
    _dragRegionLock = value == "true";
  }
}

bool currentDragRegionLock() => _dragRegionLock;

Future<void> setDragRegionLock(bool value) async {
  _dragRegionLock = value;
  await methods.saveProperty(_propertyName, "$value");
}

Widget dragRegionLockSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        value: _dragRegionLock,
        onChanged: (value) async {
          await setDragRegionLock(value);
          setState(() {});
        },
        title: const Text("拖拽区域锁定"),
        subtitle: const Text("避免缩放时误触滚动"),
      );
    },
  );
}
