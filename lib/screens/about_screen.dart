import 'package:flutter/material.dart';
import 'package:jasmine/basic/commons.dart';
import 'package:jasmine/configs/versions.dart';
import 'package:jasmine/screens/components/badge.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text("关于"),),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(children: [
                  _buildLogo(),
                  _buildVersion(),
                  Container(height: 30),
                  _buildVersionText(),
                ]))));
  }

  Widget _buildLogo(){
    return Container(
    width: 200,child: Image.asset(
      "lib/assets/startup.webp",
      fit: BoxFit.fitWidth,
    ));
  }

  Widget _buildVersion() {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('软件版本:${currentVersion()}'),
          Row(
            children: [
              Text(
                  '检查更新:${latestVersion == null ? "没有检测到新版本" : "检测到新版本 : $latestVersion"}'),
              TextButton(
                  onPressed: () {
                    manualCheckNewVersion(context);
                  },
                  child: const Text(
                    "检查更新",
                  ))
            ],
          ),
          TextButton(
              onPressed: () {
                openUrl("https://github.com/niuhuan/jasmine/releases/");
              },
              child: const Text(
                "点击这里去下载页面",
              ))
        ],
      );
    });
  }

  Widget _buildVersionText() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Center(
          child: SelectableText(latestVersionInfo() ?? ""),
        );
      },
    );
  }
}
