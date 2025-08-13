import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jasmine/basic/commons.dart';
import 'package:jasmine/configs/android_display_mode.dart';
import 'package:jasmine/configs/proxy.dart';
import 'package:jasmine/configs/versions.dart';
import 'package:jasmine/screens/components/badge.dart';

import '../basic/methods.dart';
import '../configs/is_pro.dart';
import '../configs/theme.dart';
import '../configs/using_right_click_pop.dart';
import 'components/right_click_pop.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AboutState();
  }
}

class _AboutState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return rightClickPop(child: buildScreen(context), context: context);
  }

  Widget buildScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("关于"),
      ),
      body: ListView(
        children: [
          const Divider(),
          _buildLogo(),
          const Divider(),
          _buildCurrentVersion(),
          const Divider(),
          _buildNewestVersion(),
          if (latestVersion != null) _buildGotoGithub(),
          const Divider(),
          _buildVersionText(),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double? width, height;
        if (constraints.maxWidth < constraints.maxHeight) {
          width = constraints.maxWidth / 3;
        } else {
          height = constraints.maxHeight / 3;
        }
        double l = width ?? height!;
        return Column(
          children: [
            Container(height: l / 4),
            SizedBox(
              width: l,
              height: l,
              child: ConstrainedBox(
                constraints: const BoxConstraints.expand(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Opacity(
                    opacity: 0.9,
                    child: Icon(Icons.abc,size: l,),
                  ),
                ),
              ),
            ),
            Container(height: l / 4),
          ],
        );
      },
    );
  }

  Widget _buildCurrentVersion() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Text("当前版本 : ${currentVersion()}"),
    );
  }

  Widget _buildNewestVersion() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Text.rich(TextSpan(
        children: [
          const TextSpan(text: "最新版本 : "),
          // if (isPro)
          _buildNewestVersionSpan(),
          // if (isPro)
          _buildCheckButton(),
          // if (!isPro)
          //   const TextSpan(
          //     text: "请前往官网获取最新版本",
          //     style: TextStyle(color: Colors.grey),
          //   ),
        ],
      )),
    );
  }

  InlineSpan _buildNewestVersionSpan() {
    return WidgetSpan(
      child: Container(
        padding: const EdgeInsets.only(right: 20),
        child: VersionBadged(
          child: Text(
            "${latestVersion ?? "没有检测到新版本"}    ",
          ),
        ),
      ),
    );
  }

  InlineSpan _buildCheckButton() {
    return WidgetSpan(
      child: GestureDetector(
        child: const Text(
          "检查更新",
          style: TextStyle(height: 1.3, color: Colors.blue),
          strutStyle: StrutStyle(height: 1.3),
        ),
        onTap: () async {
          await manualCheckNewVersion(context);
          setState(() {});
        },
      ),
    );
  }

  final repoOwnerUrl = "https://api.github.com/repos/ComicSparks/glxx/releases/tags/jasmine";

  Widget _buildGotoGithub() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: GestureDetector(
        child: const Text(
          "去下载地址",
          style: TextStyle(color: Colors.blue),
        ),
        onTap: () async {
          var owner = jsonDecode(await methods.httpGet(repoOwnerUrl))["body"].toString().trim();
          openUrl("https://github.com/$owner/jasmine/releases/");
        },
      ),
    );
  }

  Widget _buildVersionText() {
    var info = latestVersionInfo();
    if (info != null) {
      info = "更新内容\n\n$info";
    }
    return Container(
      padding: const EdgeInsets.all(20),
      child: SelectableText(info ?? ""),
    );
  }
}
