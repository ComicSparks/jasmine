import 'dart:async' show Future;

import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:jasmine/basic/commons.dart';
import 'package:jasmine/basic/log.dart';
import 'package:jasmine/basic/methods.dart';

import 'ignore_upgrade_pop.dart';

const _defaultDownloadUrl = "https://cdn.comicsparks.work/download/jasmine";

const _versionAssets = 'lib/assets/version.txt';

class _SemVer {
  final int major;
  final int minor;
  final int patch;

  const _SemVer(this.major, this.minor, this.patch);

  static _SemVer? parse(String input) {
    var src = input.trim();
    if (src.startsWith('v')) {
      src = src.substring(1);
    }
    final m = RegExp(r'^(\d+)\.(\d+)\.(\d+)$').firstMatch(src);
    if (m == null) return null;
    return _SemVer(
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
    );
  }

  @override
  String toString() {
    return '$major.$minor.$patch';
  }
}

late String _version;
String? _latestVersion;
String? _latestVersionInfo;
String _downloadUrl = _defaultDownloadUrl;

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

String latestDownloadUrl() {
  return _downloadUrl;
}

Future autoCheckNewVersion() {
  // if (!isPro) return Future.value();
  if (_period != 0) {
    // -1 不检查, >0 未到检查时间
    return Future.value();
  }
  return _versionCheck();
}

int _compareSemVer(_SemVer local, _SemVer remote) {
  if (remote.major != local.major) {
    return remote.major.compareTo(local.major);
  }
  if (remote.minor != local.minor) {
    return remote.minor.compareTo(local.minor);
  }
  return remote.patch.compareTo(local.patch);
}

bool dirtyVersion() {
  return _SemVer.parse(_version) == null;
}

// maybe exception
Future _versionCheck() async {
  final localSemVer = _SemVer.parse(_version);
  if (localSemVer != null) {
    final config = await methods.appConfig();
    final remoteLatestVersion = config["latestVersion"]?.toString();
    final remoteDownloadUrl = config["downloadUrl"]?.toString();
    if (remoteDownloadUrl != null && remoteDownloadUrl.isNotEmpty) {
      _downloadUrl = remoteDownloadUrl;
    } else {
      _downloadUrl = _defaultDownloadUrl;
    }
    if (remoteLatestVersion != null && remoteLatestVersion.isNotEmpty) {
      final remoteSemVer = _SemVer.parse(remoteLatestVersion);
      if (remoteSemVer != null &&
          _compareSemVer(localSemVer, remoteSemVer) > 0) {
        _latestVersion = remoteLatestVersion;
        _latestVersionInfo =
            config["changeLog"]?.toString().trim() ?? "";
      } else {
        _latestVersion = null;
        _latestVersionInfo = null;
      }
    } else {
      _latestVersion = null;
      _latestVersionInfo = null;
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
  final latest = latestVersion;
  if (latest == null || !_display) {
    return;
  }

  final force = _isForceUpgrade(currentVersion(), latest);
  if (force) {
    if (currentIgnoreUpgradePop()) {
      return;
    }
    _display = false;
    TopConfirm.topConfirm(
      context,
      "发现新版本",
      "发现新版本 $latest，请立即更新后继续使用",
      force: true,
      primaryText: "去下载",
      onPrimary: _openRelease,
    );
    return;
  }

  if (!currentIgnoreUpgradePop()) {
    _display = false;
    TopConfirm.topConfirm(context, "发现新版本", "发现新版本 $latest , 请到关于页面更新");
  }
}

bool _isForceUpgrade(String current, String latest) {
  final c = _SemVer.parse(current);
  final l = _SemVer.parse(latest);
  if (c == null || l == null) return false;
  if (l.major != c.major) return true;
  if (l.minor != c.minor) return true;
  return false;
}

Future<void> _openRelease() async {
  try {
    await openUrl(latestDownloadUrl());
  } catch (_) {
    // ignore
  }
}

class TopConfirm {
  static topConfirm(BuildContext context, String title, String message,
      {bool force = false,
      String primaryText = "朕知道了",
      Future<void> Function()? onPrimary,
      Function()? afterIKnown}) {
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
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Container(height: 30),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 28,
                          ),
                        ),
                        Container(height: 15),
                        Text(
                          message,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        Container(height: 25),
                        MaterialButton(
                          elevation: 0,
                          color: Colors.black.withOpacity(.1),
                          onPressed: () {
                            if (onPrimary != null) {
                              onPrimary();
                            }
                            if (!force) {
                              overlayEntry.remove();
                            }
                            afterIKnown?.call();
                          },
                          child: Text(primaryText),
                        ),
                        Container(height: 30),
                      ],
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
    final overlay = Overlay.of(context);
    overlay.insert(overlayEntry);
  }
}
