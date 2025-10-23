import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
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

class DownloadsExportingScreen extends StatefulWidget {
  final List<int> idList;

  const DownloadsExportingScreen({Key? key, required this.idList})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DownloadsExportingScreenState();
}

class _DownloadsExportingScreenState extends State<DownloadsExportingScreen> {
  bool exporting = false;
  bool exported = false;
  bool exportFail = false;
  dynamic e;
  String exportMessage = "正在导出";
  var deleteExport = false;

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
          title: const Text("导出后删除下载的漫画"),
          value: deleteExport,
          onChanged: (value) {
            setState(() {
              deleteExport = value;
            });
          },
        ),
        Container(height: 20),
        _buildButtonInner(
          _exportJmis,
          "分别导出JMI" + (!isPro ? "\n(发电后使用)" : ""),
        ),
        Container(height: 20),
        _buildButtonInner(
          _exportZips,
          "分别导出JM.ZIP" + (!isPro ? "\n(发电后使用)" : ""),
        ),
        Container(height: 20),
        _buildButtonInner(
          _exportJpegZips,
          "分别导出JPEGS.ZIP" + (!isPro ? "\n(发电后使用)" : ""),
        ),
        Container(height: 20),
        _buildButtonInner(
          _exportCbzsZips,
          "分别导出CBZ" + (!isPro ? "\n(发电后使用)" : ""),
        ),
        Container(height: 20),
        if (true) ...[
          _buildButtonInner(
            _exportPdf,
            "分别导Pdf" + (!isPro ? "\n(发电后使用)" : ""),
          ),
          Container(height: 20),
        ],
        Container(height: 20),
        _buildButtonInner(
          _exportEpubs,
          "分别导出EPUB" + (!isPro ? "\n(发电后使用)" : ""),
        ),
        Container(height: 20),
      ],
    );
  }

  Widget _buildButtonInner(VoidCallback? onPressed, String text) {
    return MaterialButton(
      onPressed: onPressed,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            width: constraints.maxWidth,
            padding: const EdgeInsets.all(15),
            color:
                (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black)
                    .withOpacity(.05),
            child: Text(
              text,
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }

  _exportJmis() async {
    if (!isPro) {
      defaultToast(context, "请先发电鸭");
      return;
    }
    if (Platform.isMacOS) {
      await chooseEx(context);
    }
    if (!await confirmDialog(
        context, "导出确认", "将您所选的漫画分别导出JMI${showExportPath()}")) {
      return;
    }
    try {
      setState(() {
        exporting = true;
      });
      final path = await attachExportPath();
      for (var value in widget.idList) {
        var ab = await methods.downloadById(value);
        setState(() {
          exportMessage = "正在导出 : " + (ab?.album?.name ?? "");
        });
        String? rename;
        if (currentExportRename()) {
          rename = await displayTextInputDialog(context,
              title: "导出重命名", src: ab?.album?.name ?? "");
        }
        await methods.export_jm_jmi_single(
          value,
          path,
          rename,
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

  _exportPdf() async {
    if (!isPro) {
      defaultToast(context, "请先发电鸭");
      return;
    }
    if (Platform.isMacOS) {
      await chooseEx(context);
    }
    if (!await confirmDialog(
        context, "导出确认", "将您所选的漫画分别导出PDF${showExportPath()}")) {
      return;
    }
    try {
      setState(() {
        exporting = true;
      });
      final path = await attachExportPath();
      for (var value in widget.idList) {
        var ab = await methods.downloadById(value);
        setState(() {
          exportMessage = "正在导出 : " + (ab?.album?.name ?? "");
        });
        await methods.export_jm_pdf(
          value,
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

  _exportCbzsZips() async {
    if (!isPro) {
      defaultToast(context, "请先发电鸭");
      return;
    }
    if (Platform.isMacOS) {
      await chooseEx(context);
    }
    if (!await confirmDialog(
        context, "导出确认", "将您所选的漫画分别导出cbzs.zip${showExportPath()}")) {
      return;
    }
    try {
      setState(() {
        exporting = true;
      });
      final path = await attachExportPath();
      for (var value in widget.idList) {
        var ab = await methods.downloadById(value);
        setState(() {
          exportMessage = "正在导出 : " + (ab?.album?.name ?? "");
        });
        String? rename;
        if (currentExportRename()) {
          rename = await displayTextInputDialog(context,
              title: "导出重命名", src: ab?.album?.name ?? "");
        }
        await methods.export_cbzs_zip_single(
          value,
          path,
          rename,
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

  _exportZips() async {
    if (!isPro) {
      defaultToast(context, "请先发电鸭");
      return;
    }
    if (Platform.isMacOS) {
      await chooseEx(context);
    }
    if (!await confirmDialog(
        context, "导出确认", "将您所选的漫画分别导出ZIP${showExportPath()}")) {
      return;
    }
    try {
      setState(() {
        exporting = true;
      });
      final path = await attachExportPath();
      for (var value in widget.idList) {
        var ab = await methods.downloadById(value);
        setState(() {
          exportMessage = "正在导出 : " + (ab?.album?.name ?? "");
        });
        String? rename;
        if (currentExportRename()) {
          rename = await displayTextInputDialog(context,
              title: "导出重命名", src: ab?.album?.name ?? "");
        }
        await methods.export_jm_zip_single(
          value,
          path,
          rename,
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

  _exportJpegZips() async {
    if (!isPro) {
      defaultToast(context, "请先发电鸭");
      return;
    }
    if (Platform.isMacOS) {
      await chooseEx(context);
    }
    if (!await confirmDialog(
        context, "导出确认", "将您所选的漫画分别导出JPEGS.ZIP${showExportPath()}")) {
      return;
    }
    try {
      setState(() {
        exporting = true;
      });
      final path = await attachExportPath();
      for (var value in widget.idList) {
        var ab = await methods.downloadById(value);
        setState(() {
          exportMessage = "正在导出 : " + (ab?.album?.name ?? "");
        });
        String? rename;
        if (currentExportRename()) {
          rename = await displayTextInputDialog(context,
              title: "导出重命名", src: ab?.album?.name ?? "");
        }
        await methods.export_jm_jpegs_zip_single(
          value,
          path,
          rename,
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

  _exportEpubs() async {
    if (!isPro) {
      defaultToast(context, "请先发电鸭");
      return;
    }
    if (Platform.isMacOS) {
      await chooseEx(context);
    }
    if (!await confirmDialog(
        context, "导出确认", "将您所选的漫画分别导出EPUB${showExportPath()}")) {
      return;
    }
    try {
      setState(() {
        exporting = true;
      });
      final path = await attachExportPath();
      for (var value in widget.idList) {
        var ab = await methods.downloadById(value);
        setState(() {
          exportMessage = "正在导出 : " + (ab?.album?.name ?? "");
        });
        String? rename;
        if (currentExportRename()) {
          rename = await displayTextInputDialog(context,
              title: "导出重命名", src: ab?.album?.name ?? "");
        }
        await methods.export_jm_epub_single(
          value,
          path,
          rename,
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
          title: const Text("批量导出"),
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
