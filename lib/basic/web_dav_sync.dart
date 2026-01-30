import 'package:flutter/material.dart';
import 'package:jasmine/basic/log.dart';
import 'package:jasmine/basic/methods.dart';
import 'package:jasmine/configs/web_dav_url.dart';

import '../configs/is_pro.dart';
import '../configs/web_dav_password.dart';
import '../configs/web_dav_sync_switch.dart';
import '../configs/web_dav_username.dart';
import 'commons.dart';

Future webDavSync(BuildContext context) async {
  try {
    await methods.webDavSync({
      "url": currentWebDavUrl,
      "username": currentWebUserName,
      "password": currentWebDavPassword,
      "direction": "Merge",
    });
    defaultToast(context, "WebDav 同步成功");
  } catch (e, s) {
    debugPrient("$e\n$s");
    defaultToast(context, "WebDav 同步失败 : $e");
  }
}

Future webDavSyncUpload(BuildContext context) async {
  try {
    await methods.webDavSync({
      "url": currentWebDavUrl,
      "username": currentWebUserName,
      "password": currentWebDavPassword,
      "direction": "Upload",
    });
    defaultToast(context, "WebDav 覆盖上传成功");
  } catch (e, s) {
    debugPrient("$e\n$s");
    defaultToast(context, "WebDav 覆盖上传失败 : $e");
  }
}

Future webDavSyncDownload(BuildContext context) async {
  try {
    await methods.webDavSync({
      "url": currentWebDavUrl,
      "username": currentWebUserName,
      "password": currentWebDavPassword,
      "direction": "Download",
    });
    defaultToast(context, "WebDav 覆盖下载成功");
  } catch (e, s) {
    debugPrient("$e\n$s");
    defaultToast(context, "WebDav 覆盖下载失败 : $e");
  }
}

Future webDavSyncAuto(BuildContext context) async {
  if (currentWebDavSyncSwitch() && isPro) {
    await webDavSync(context);
  }
}

var syncing = false;

Widget webDavSyncClick(BuildContext context) {
  return ListTile(
    title: const Text("立即同步"),
    onTap: () async {
      if (syncing) return;
      syncing = true;
      try {
        await webDavSync(context);
      } finally {
        syncing = false;
      }
    },
  );
}

Widget webDavSyncUploadClick(BuildContext context) {
  return ListTile(
    title: const Text("单向覆盖上传"),
    onTap: () async {
      if (syncing) return;
      syncing = true;
      try {
        await webDavSyncUpload(context);
      } finally {
        syncing = false;
      }
    },
  );
}

Widget webDavSyncDownloadClick(BuildContext context) {
  return ListTile(
    title: const Text("单向覆盖下载"),
    onTap: () async {
      if (syncing) return;
      syncing = true;
      try {
        await webDavSyncDownload(context);
      } finally {
        syncing = false;
      }
    },
  );
}
