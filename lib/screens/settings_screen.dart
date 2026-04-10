import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jasmine/basic/methods.dart';
import 'package:jasmine/configs/app_font_size.dart';
import 'package:jasmine/configs/app_orientation.dart';
import 'package:jasmine/configs/drag_region_lock.dart';
import 'package:jasmine/configs/gesture_speed.dart';
import 'package:jasmine/configs/network_api_host.dart';
import 'package:jasmine/configs/network_cdn_host.dart';
import 'package:jasmine/configs/reader_zoom_scale.dart';
import 'package:jasmine/screens/downloads_exports_screen2.dart';

import '../basic/commons.dart';
import '../basic/web_dav_sync.dart';
import '../configs/Authentication.dart';
import '../configs/android_display_mode.dart';
import '../configs/categories_sort.dart';
import '../configs/comic_seal.dart';
import '../configs/display_jmcode.dart';
import '../configs/download_and_export_to.dart';
import '../configs/esc_to_pop.dart';
import '../configs/disable_recommend_content.dart';
import '../configs/export_rename.dart';
import '../configs/ignore_upgrade_pop.dart';
import '../configs/ignore_view_log.dart';
import '../configs/is_pro.dart';
import '../configs/login.dart';
import '../configs/no_animation.dart';
import '../configs/proxy.dart';
import '../configs/search_title_words.dart';
import '../configs/theme.dart';
import '../configs/two_page_direction.dart';
import '../configs/using_right_click_pop.dart';
import '../configs/versions.dart';
import '../configs/volume_key_control.dart';
import '../configs/web_dav_password.dart';
import '../configs/web_dav_sync_switch.dart';
import '../configs/web_dav_url.dart';
import '../configs/web_dav_username.dart';
import '../configs/passed.dart' as passed_config;
import 'components/right_click_pop.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SettingsState();
  }
}

class _SettingsState extends State<SettingsScreen> {
  bool _startupImageExists = false;

  @override
  void initState() {
    super.initState();
    _loadStartupImageState();
  }

  Future<void> _loadStartupImageState() async {
    try {
      final startupImagePath = await methods.getStartupImagePath();
      if (!mounted) {
        return;
      }
      setState(() {
        _startupImageExists = startupImagePath.isNotEmpty;
      });
    } catch (_) {}
  }

  Future<String> _renderPngBase64WithinScreen(
    Uint8List imageBytes,
    Size screenSize,
  ) async {
    final codec = await ui.instantiateImageCodec(imageBytes);
    final frameInfo = await codec.getNextFrame();
    final srcImage = frameInfo.image;
    final srcWidth = srcImage.width.toDouble();
    final srcHeight = srcImage.height.toDouble();

    final scale = math.min(
      math.min(screenSize.width / srcWidth, screenSize.height / srcHeight),
      1.0,
    );
    final targetWidth = math.max(1, (srcWidth * scale).round());
    final targetHeight = math.max(1, (srcHeight * scale).round());

    final resizedCodec = await ui.instantiateImageCodec(
      imageBytes,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
    );
    final resizedFrame = await resizedCodec.getNextFrame();
    final pngData = await resizedFrame.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (pngData == null) {
      throw StateError("图片编码失败");
    }
    return base64Encode(pngData.buffer.asUint8List());
  }

  Future<void> _pickAndSaveStartupImage(BuildContext context) async {
    try {
      Uint8List? imageBytes;
      if (Platform.isAndroid || Platform.isIOS) {
        final picker = ImagePicker();
        final picked = await picker.pickImage(source: ImageSource.gallery);
        if (picked == null) {
          return;
        }
        imageBytes = await picked.readAsBytes();
      } else {
        final picked = await FilePicker.platform.pickFiles(
          dialogTitle: "选择启动图",
          type: FileType.custom,
          allowedExtensions: ["png", "jpg", "jpeg", "bmp", "webp"],
        );
        if (picked == null || picked.files.isEmpty) {
          return;
        }
        final file = picked.files.first;
        if (file.bytes != null) {
          imageBytes = file.bytes!;
        } else if (file.path != null) {
          imageBytes = await File(file.path!).readAsBytes();
        }
      }

      if (imageBytes == null) {
        defaultToast(context, "未读取到图片");
        return;
      }

      final size = MediaQuery.of(context).size;
      final base64Data = await _renderPngBase64WithinScreen(imageBytes, size);
      await methods.saveStartupImage(base64Data);
      defaultToast(context, _startupImageExists ? "替换启动图成功" : "设置启动图成功");
      await _loadStartupImageState();
    } catch (e) {
      defaultToast(context, "设置启动图失败 : $e");
      print("设置启动图失败 : $e");
    }
  }

  Future<void> _deleteStartupImage(BuildContext context) async {
    if (!await confirmDialog(context, "删除启动图", "确定删除当前启动图吗?")) {
      return;
    }
    try {
      await methods.deleteStartupImage();
      defaultToast(context, "删除启动图成功");
      await _loadStartupImageState();
    } catch (e) {
      defaultToast(context, "删除启动图失败 : $e");
    }
  }

  Future<void> _resetBrowser(BuildContext context) async {
    if (!await confirmDialog(context, "重置浏览器", "确定删除浏览器启动标记吗? 下次启动将重新进入浏览器。")) {
      return;
    }
    try {
      await methods.deleteProperty("passed");
      await passed_config.initPassed();
      defaultToast(context, "重置浏览器成功");
    } catch (e) {
      defaultToast(context, "重置浏览器失败 : $e");
    }
  }

  Widget _startupImageSettingTile(BuildContext context) {
    return ListTile(
      onTap: () async {
        await _pickAndSaveStartupImage(context);
      },
      title: Text(_startupImageExists ? "替换启动图" : "设置启动图"),
    );
  }

  Widget _deleteStartupImageTile(BuildContext context) {
    return ListTile(
      onTap: () async {
        await _deleteStartupImage(context);
      },
      title: const Text("删除启动图"),
    );
  }

  Widget _resetBrowserTile(BuildContext context) {
    return ListTile(
      onTap: () async {
        await _resetBrowser(context);
      },
      title: const Text("重置浏览器"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return rightClickPop(child: buildScreen(context), context: context);
  }

  Widget buildScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("设置"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ExpansionTile(
              leading: const Icon(Icons.manage_accounts),
              title: const Text('用户和网络'),
              children: [
                const Divider(),
                apiHostSetting(),
                cdnHostSetting(),
                proxySetting(),
                const Divider(),
                createFavoriteFolderItemTile(context),
                deleteFavoriteFolderItemTile(context),
                renameFavoriteFolderItemTile(context),
                const Divider(),
                ListTile(
                  onTap: () async {
                    if (await confirmDialog(
                        context, "清除账号信息", "您确定要清除账号信息并退出APP吗?")) {
                      await methods.logout();
                      exit(0);
                    }
                  },
                  title: const Text("清除账号信息"),
                ),
                const Divider(),
              ],
            ),
            ExpansionTile(
              leading: Icon(Icons.menu_book_outlined),
              title: Text('阅读'),
              children: [
                const Divider(),
                volumeKeyControlSetting(),
                noAnimationSetting(),
                const Divider(),
                gestureSpeedSetting(),
                dragRegionLockSetting(),
                readerZoomMinScaleSetting(),
                readerZoomMaxScaleSetting(),
                readerZoomDoubleTapScaleSetting(),
                const Divider(),
                twoGalleryDirectionSetting(context),
                const Divider(),
              ],
            ),
            ExpansionTile(
              leading: Icon(Icons.backup),
              title: Text('同步'),
              children: [
                const Divider(),
                webDavSyncSwitchSetting(),
                webDavUrlSetting(),
                webDavUserNameSetting(),
                webDavPasswordSetting(),
                webDavSyncClick(context),
                webDavSyncUploadClick(context),
                webDavSyncDownloadClick(context),
                const Divider(),
              ],
            ),
            ExpansionTile(
              leading: Icon(Icons.ad_units),
              title: Text('系统和应用程序'),
              children: [
                _resetBrowserTile(context),
                const Divider(),
                _startupImageSettingTile(context),
                if (_startupImageExists) _deleteStartupImageTile(context),
                const Divider(),
                disableRecommendContentSetting(),
                if (isPro) ...[
                  const Divider(),
                  autoUpdateCheckSetting(),
                  ignoreUpgradePopSetting(),
                  const Divider(),
                ],
                const Divider(),
                ignoreVewLogSetting(),
                const Divider(),
                appOrientationWidget(),
                const Divider(),
                categoriesSortSetting(context),
                themeSetting(context),
                const Divider(),
                androidDisplayModeSetting(),
                const Divider(),
                usingRightClickPopSetting(),
                escToPopSetting(),
                const Divider(),
                comicSealCategorySetting(),
                comicSealTitleWordsSetting(),
                const Divider(),
                authenticationSetting(),
                const Divider(),
                exportRenameSetting(),
                downloadAndExportToSetting(),
                const Divider(),
                displayJmcodeSetting(),
                const Divider(),
                ListTile(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (c) => const DownloadsExportScreen2()));
                  },
                  title: const Text("导出下载到目录(即使没有下载完)"),
                ),
                const Divider(),
                searchTitleWordsSetting(),
                ...fontSizeAdjustSettings(),
                const Divider(),
              ],
            ),
            SafeArea(
              top: false,
              child: Container(
                height: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
