import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jasmine/basic/log.dart';
import 'package:jasmine/basic/methods.dart';

import '../basic/commons.dart';
import '../configs/export_path.dart';
import '../configs/export_rename.dart';
import '../configs/is_pro.dart';
import 'components/content_loading.dart';
import 'components/right_click_pop.dart';

class ExportAb {
  final int id;
  final String name;

  ExportAb(this.id, this.name);
}

class DownloadsExportingScreen2 extends StatefulWidget {
  final List<int> idList;

  const DownloadsExportingScreen2({Key? key, required this.idList})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DownloadsExportingScreen2State();
}

class _DownloadsExportingScreen2State extends State<DownloadsExportingScreen2> {
  bool exporting = false;
  bool exported = false;
  bool exportFail = false;
  dynamic e;
  String exportMessage = "正在导出";
  bool deleteExport = false;

  @override
  void initState() {
    //registerEvent(_onMessageChange, "EXPORT");
    super.initState();
  }

  @override
  void dispose() {
    //unregisterEvent(_onMessageChange);
    super.dispose();
  }

  void _onMessageChange(event) {
    setState(() {
      exportMessage = event;
    });
  }

  Widget _body() {
    if (exporting) {
      return ContentLoading(label: exportMessage);
    }
    if (exportFail) {
      return Center(child: Text("导出失败\n$e\n($exportMessage)"));
    }
    if (exported) {
      return const Center(child: Text("导出成功"));
    }
    return ListView(
      children: [
        // Container(height: 20),
        // MaterialButton(
        //   onPressed: _exportPkz,
        //   child: const Text("导出PKZ"),
        // ),
        Container(height: 20),
        displayExportPathInfo(),
        Container(height: 20),
        SwitchListTile(
          title: const Text("导出后删除原文件"),
          value: deleteExport,
          onChanged: (value) {
            setState(() {
              deleteExport = value;
            });
          },
        ),
        Container(height: 20),
        MaterialButton(
          onPressed: _exportJpegs,
          child: Text(
            "导出成文件夹" + (!isPro ? "\n(发电后使用)" : ""),
            style: TextStyle(
              color: !isPro ? Colors.grey : null,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Container(height: 20),
        MaterialButton(
          onPressed: _exportPdf2,
          child: Text(
            "导出成PDF" + (!isPro ? "\n(发电后使用)" : ""),
            style: TextStyle(
              color: !isPro ? Colors.grey : null,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Container(height: 20),
        MaterialButton(
          onPressed: _exportEpub,
          child: Text(
            "导出成EPUB" + (!isPro ? "\n(发电后使用)" : ""),
            style: TextStyle(
              color: !isPro ? Colors.grey : null,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Container(height: 20),
      ],
    );
  }

  _exportJpegs() async {
    if (!isPro) {
      defaultToast(context, "请先发电鸭");
      return;
    }
    late String? path;
    try {
      path = Platform.isIOS
          ? await methods.iosGetDocumentDir()
          : await chooseFolder(context);
    } catch (e) {
      defaultToast(context, "$e");
      return;
    }
    debugPrient("path $path");
    if (path != null) {
      try {
        setState(() {
          exporting = true;
        });
        await methods.export_jm_jpegs(
          widget.idList,
          path,
          deleteExport,
        );
        exported = true;
      } catch (err) {
        e = err;
        exportFail = true;
      } finally {
        setState(() {
          exporting = false;
        });
      }
    }
  }

  _exportPdf2() async {
    if (!isPro) {
      defaultToast(context, "请先发电鸭");
      return;
    }
    late String? path;
    try {
      path = Platform.isIOS
          ? await methods.iosGetDocumentDir()
          : await chooseFolder(context);
    } catch (e) {
      defaultToast(context, "$e");
      return;
    }
    debugPrient("path $path");
    if (path != null) {
      try {
        setState(() {
          exporting = true;
        });
        for (var id in widget.idList) {
          await methods.export_jm_pdf2(
            id,
            path,
            deleteExport,
          );
        }
        exported = true;
      } catch (err) {
        e = err;
        exportFail = true;
      } finally {
        setState(() {
          exporting = false;
        });
      }
    }
  }

  _exportEpub() async {
    if (!isPro) {
      defaultToast(context, "请先发电鸭");
      return;
    }
    late String? path;
    try {
      path = Platform.isIOS
          ? await methods.iosGetDocumentDir()
          : await chooseFolder(context);
    } catch (e) {
      defaultToast(context, "$e");
      return;
    }
    debugPrient("path $path");
    if (path != null) {
      try {
        setState(() {
          exporting = true;
        });
        await methods.export_jm_epub(
          widget.idList,
          path,
          deleteExport,
        );
        exported = true;
      } catch (err) {
        e = err;
        exportFail = true;
      } finally {
        setState(() {
          exporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return rightClickPop(
      child: buildScreen(context),
      context: context,
      canPop: !exporting,
    );
  }

  Widget buildScreen(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("批量导出(即使没有下载完)"),
        ),
        body: _body(),
      ),
      onWillPop: () async {
        if (exporting) {
          defaultToast(context, "导出中, 请稍后");
          return false;
        }
        return true;
      },
    );
  }
}
