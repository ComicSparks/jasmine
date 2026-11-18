import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jasmine/basic/methods.dart';
import 'package:jasmine/configs/android_version.dart';
import 'package:permission_handler/permission_handler.dart';

const _propertyName = "downloadOngoingNotification";
late bool _downloadOngoingNotification;

Timer? _timer;
bool _syncing = false;
bool _resync = false;
String? _lastPayload;
bool _visible = false;

bool get _supportDownloadNotification {
  final os = Platform.operatingSystem;
  return os == 'android' || os == 'ohos';
}

Future<void> initDownloadOngoingNotification() async {
  if (!_supportDownloadNotification) {
    _downloadOngoingNotification = false;
    return;
  }
  final raw = await methods.loadProperty(_propertyName);
  if (raw.isEmpty) {
    _downloadOngoingNotification = true;
    await methods.saveProperty(_propertyName, "true");
  } else {
    _downloadOngoingNotification = raw == "true";
  }
  if (Platform.isAndroid && androidVersion >= 33) {
    try {
      await Permission.notification.request();
    } catch (_) {}
  }
  if (Platform.operatingSystem == 'ohos') {
    try {
      await methods.cancelDownloadNotification();
    } catch (_) {}
  }
  _timer?.cancel();
  _timer = Timer.periodic(const Duration(seconds: 2), (_) {
    syncDownloadOngoingNotification();
  });
  await syncDownloadOngoingNotification();
}

Future<void> setDownloadOngoingNotification(bool value) async {
  await methods.saveProperty(_propertyName, "$value");
  _downloadOngoingNotification = value;
  _lastPayload = null;
  await syncDownloadOngoingNotification();
}

Future<void> syncDownloadOngoingNotification() async {
  if (!_supportDownloadNotification) {
    return;
  }
  if (_syncing) {
    _resync = true;
    return;
  }
  _syncing = true;
  try {
    do {
      _resync = false;
      await _syncOnce();
    } while (_resync);
  } finally {
    _syncing = false;
  }
}

Future<void> _syncOnce() async {
  try {
    if (!_downloadOngoingNotification) {
      await _hide();
      return;
    }
    final downloads = await methods.allDownloads();
    final pending = downloads.where((album) => album.dlStatus == 0).toList();
    if (pending.isEmpty) {
      await _hide();
      return;
    }
    var dled = 0;
    var total = 0;
    for (final album in pending) {
      dled += album.dledImageCount;
      total += album.imageCount;
    }
    const title = "正在下载";
    final text = "${pending.length} 个任务未完成，$dled / $total";
    final payload = "$title|$text|$dled|$total";
    if (payload == _lastPayload) {
      return;
    }
    final shown = await methods.showDownloadNotification(
      title: title,
      text: text,
      progress: dled,
      max: total,
    );
    if (!shown) {
      return;
    }
    _lastPayload = payload;
    _visible = true;
  } catch (_) {}
}

Future<void> _hide() async {
  _lastPayload = null;
  if (!_visible) {
    return;
  }
  await methods.cancelDownloadNotification();
  _visible = false;
}

Widget downloadOngoingNotificationSetting() {
  if (!_supportDownloadNotification) {
    return Container();
  }
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        title: const Text("下载时使用常驻提醒"),
        value: _downloadOngoingNotification,
        onChanged: (value) async {
          await setDownloadOngoingNotification(value);
          if (context.mounted) {
            setState(() {});
          }
        },
      );
    },
  );
}
