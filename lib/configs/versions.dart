import 'dart:async' show Future;
import 'dart:convert';

import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:jasmine/basic/commons.dart';
import 'package:jasmine/basic/log.dart';
import 'package:jasmine/basic/methods.dart';

import 'ignore_upgrade_pop.dart';

const repoOwnerUrl =
    "https://api.github.com/repos/ComicSparks/glxx/releases/tags/jasmine";
const _versionUrl =
    "https://api.github.com/repos/OWNER/jasmine/releases/latest";

const _versionAssets = 'lib/assets/version.txt';
RegExp _versionExp = RegExp(r"^v\d+\.\d+.\d+$");

late String _version;
String? _latestVersion;
String? _latestVersionInfo;

const _propertyName = "checkVersionPeriod";
late int _period = -1;

Future initVersion() async {
  // 当前版本
  try {
    _version = (await rootBundle.loadString(_versionAssets)).trim();
  } catch (e) {
    _version = "dirty";
  }
  // 检查周期
  var vStr = await methods.loadProperty(_propertyName);
  if (vStr == "") {
    vStr = "0";
  }
  _period = int.parse(vStr);
  if (_period > 0) {
    if (DateTime.now().millisecondsSinceEpoch > _period) {
      await methods.saveProperty(_propertyName, "0");
      _period = 0;
    }
  }
}

var versionEvent = Event<EventArgs>();

String currentVersion() {
  return _version;
}

String? get latestVersion => _latestVersion;

String? latestVersionInfo() {
  return _latestVersionInfo;
}

Future autoCheckNewVersion() {
  // if (!isPro) return Future.value();
  if (_period != 0) {
    // -1 不检查, >0 未到检查时间
    return Future.value();
  }
  return _versionCheck();
}

Future manualCheckNewVersion(BuildContext context) async {
  try {
    defaultToast(context, "检查更新中");
    await _versionCheck();
    defaultToast(context, "检查更新成功");
  } catch (e) {
    defaultToast(context, "检查更新失败 : $e");
  }
}

bool dirtyVersion() {
  return !_versionExp.hasMatch(_version);
}

// maybe exception
Future _versionCheck() async {
  if (_versionExp.hasMatch(_version)) {
    var owner = jsonDecode(await methods.httpGet(repoOwnerUrl))["body"]
        .toString()
        .trim();
    var json = jsonDecode(
        await methods.httpGet(_versionUrl.replaceAll("OWNER", owner)));
    if (json["name"] != null) {
      String latestVersion = (json["name"]);
      if (latestVersion != _version) {
        _latestVersion = latestVersion;
        _latestVersionInfo = json["body"] ?? "";
      }
    }
  } // else dirtyVersion
  versionEvent.broadcast();
  debugPrient("$_latestVersion");
}

String _periodText() {
  if (_period < 0) {
    return "自动检查更新已关闭";
  }
  if (_period == 0) {
    return "自动检查更新已开启";
  }
  return "下次检查时间 : " +
      formatDateTimeToDateTime(
        DateTime.fromMillisecondsSinceEpoch(_period),
      );
}

Future _choosePeriod(BuildContext context) async {
  var result = await chooseListDialog(
    context,
    title: "自动检查更新",
    values: ["开启", "一周后", "一个月后", "一年后", "关闭"],
    tips: "重启后红点会消失",
  );
  switch (result) {
    case "开启":
      await methods.saveProperty(_propertyName, "0");
      _period = 0;
      break;
    case "一周后":
      var time = DateTime.now().millisecondsSinceEpoch + (1000 * 3600 * 24 * 7);
      await methods.saveProperty(_propertyName, "$time");
      _period = time;
      break;
    case "一个月后":
      var time =
          DateTime.now().millisecondsSinceEpoch + (1000 * 3600 * 24 * 30);
      await methods.saveProperty(_propertyName, "$time");
      _period = time;
      break;
    case "一年后":
      var time =
          DateTime.now().millisecondsSinceEpoch + (1000 * 3600 * 24 * 365);
      await methods.saveProperty(_propertyName, "$time");
      _period = time;
      break;
    case "关闭":
      await methods.saveProperty(_propertyName, "-1");
      _period = -1;
      break;
  }
}

Widget autoUpdateCheckSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: const Text("自动检查更新"),
        subtitle: Text(_periodText()),
        onTap: () async {
          await _choosePeriod(context);
          setState(() {});
        },
      );
    },
  );
}

String formatDateTimeToDateTime(DateTime c) {
  try {
    return "${add0(c.year, 4)}-${add0(c.month, 2)}-${add0(c.day, 2)} ${add0(c.hour, 2)}:${add0(c.minute, 2)}";
  } catch (e) {
    return "-";
  }
}

var _display = true;

void versionPop(BuildContext context) {
  if (latestVersion != null && _display && !currentIgnoreUpgradePop()) {
    _display = false;
    TopConfirm.topConfirm(context, "发现新版本", "发现新版本 $latestVersion , 请到关于页面更新");
  }
}

class TopConfirm {
  static topConfirm(BuildContext context, String title, String message,
      {Function()? afterIKnown}) {
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(builder: (BuildContext context) {
      return LayoutBuilder(
        builder: (
          BuildContext context,
          BoxConstraints constraints,
        ) {
          var mq = MediaQuery.of(context).size.width - 30;
          return Material(
            color: Colors.transparent,
            child: Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.35),
              ),
              child: Column(
                children: [
                  Expanded(child: Container()),
                  Container(
                    width: mq,
                    child: Card(
                      child: Column(
                        children: [
                          Container(height: 30),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 28,
                            ),
                          ),
                          Container(height: 15),
                          Text(
                            message,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Container(height: 25),
                          MaterialButton(
                            elevation: 0,
                            color: Colors.grey.shade700.withOpacity(.1),
                            onPressed: () {
                              overlayEntry.remove();
                            },
                            child: const Text("朕知道了"),
                          ),
                          Container(height: 30),
                        ],
                      ),
                    ),
                  ),
                  Expanded(child: Container()),
                ],
              ),
            ),
          );
        },
      );
    });
    OverlayState? overlay = Overlay.of(context);
    if (overlay != null) {
      overlay.insert(overlayEntry);
    }
  }
}
