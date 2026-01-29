import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:jasmine/basic/commons.dart';
import 'package:jasmine/basic/methods.dart';
import 'package:jasmine/configs/login.dart';

enum DailySignStatus {
  unchecked,
  checking,
  signed,
  error,
}

DailySignStatus dailySignStatus = DailySignStatus.unchecked;

final dailySignEvent = Event();

void _setDailySignStatus(DailySignStatus status) {
  dailySignStatus = status;
  dailySignEvent.broadcast();
}

String dailySignStatusLabel() {
  switch (dailySignStatus) {
    case DailySignStatus.checking:
      return "检测中...";
    case DailySignStatus.signed:
      return "已签到";
    case DailySignStatus.error:
      return "签到失败";
    case DailySignStatus.unchecked:
    default:
      return "未检测签到";
  }
}

Future<void> checkDailySignStatus(BuildContext context,
    {bool toast = false}) async {
  if (loginStatus != LoginStatus.loginSuccess) {
    _setDailySignStatus(DailySignStatus.unchecked);
    return;
  }
  _setDailySignStatus(DailySignStatus.checking);
  try {
    final msg = await methods.daily(selfInfo.uid);
    if (toast) {
      defaultToast(context, msg.isNotEmpty ? msg : "已签到");
    }
    _setDailySignStatus(DailySignStatus.signed);
  } catch (e, st) {
    print("$e\n$st");
    if (toast) {
      defaultToast(context, "$e");
    }
    _setDailySignStatus(DailySignStatus.error);
  }
}
