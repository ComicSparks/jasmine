import 'dart:convert';
import 'package:flutter/material.dart';
import '../basic/commons.dart';
import '../basic/methods.dart';
import '../configs/is_pro.dart';
import 'components/right_click_pop.dart';

class AccessKeyReplaceScreen extends StatefulWidget {
  final String accessKey;

  const AccessKeyReplaceScreen({Key? key, required this.accessKey}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AccessKeyReplaceScreenState();
}

class _AccessKeyReplaceScreenState extends State<AccessKeyReplaceScreen> {
  bool _loading = true;
  String _username = "";
  String _patId = "";
  String _bindUid = "";
  bool _isPro = false;
  int _requestDelete = 0;
  int _reBind = 0;

  @override
  void initState() {
    _load();
    super.initState();
  }

  Future _load() async {
    try {
      setState(() {
        _loading = true;
      });
      _username = await methods.loadLastLoginUsername();
      final checkResult = await methods.checkPat(widget.accessKey);
      final check = jsonDecode(checkResult);
      setState(() {
        _patId = check["email"] ?? "";
        _bindUid = check["bind_user"] ?? "";
        _isPro = check["fd"] ?? false;
        _requestDelete = check["request_delete"] ?? 0;
        _reBind = check["re_bind"] ?? 0;
        _loading = false;
      });
    } catch (e, s) {
      print("$e\n$s");
      defaultToast(context, "验证失败: $e");
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return rightClickPop(child: buildScreen(context), context: context);
  }

  Widget buildScreen(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text("验证PAT密钥")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("验证PAT密钥")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "密钥验证成功",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ListTile(
            title: const Text("PAT账号"),
            subtitle: Text(_patId.isEmpty ? "未知" : _patId),
          ),
          const Divider(),
          ListTile(
            title: const Text("发电状态"),
            subtitle: Text(_isPro ? "已发电" : "未发电"),
          ),
          const Divider(),
          ListTile(
            title: const Text("绑定的Jasmine账号"),
            subtitle: Text(_bindUid.isEmpty ? "未绑定" : _bindUid),
          ),
          const Divider(),
          ListTile(
            title: const Text("当前登录账号"),
            subtitle: Text(_username.isEmpty ? "未登录" : _username),
          ),
          const Divider(),
          const SizedBox(height: 20),
          if (_bindUid.isEmpty)
            ElevatedButton(
              onPressed: _bind,
              child: const Text("绑定到当前账号"),
            )
          else if (_bindUid != _username)
            Column(
              children: [
                const Text(
                  "该密钥已绑定到其他账号，如需重新绑定，请先解绑或等待重新绑定时间到期",
                  style: TextStyle(color: Colors.orange),
                ),
                const SizedBox(height: 10),
                if (_reBind > 0)
                  Text(
                    "可重新绑定时间: ${DateTime.fromMillisecondsSinceEpoch(_reBind * 1000)}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _bind,
                  child: const Text("强制绑定到当前账号"),
                ),
              ],
            )
          else
            ElevatedButton(
              onPressed: _save,
              child: const Text("保存密钥"),
            ),
        ],
      ),
    );
  }

  Future _bind() async {
    try {
      defaultToast(context, "绑定中...");
      await methods.bindPatAccount(widget.accessKey, _username);
      defaultToast(context, "绑定成功");
      await reloadIsPro();
      Navigator.of(context).pop();
    } catch (e, s) {
      print("$e\n$s");
      defaultToast(context, "绑定失败: $e");
    }
  }

  Future _save() async {
    try {
      defaultToast(context, "保存中...");
      await methods.bindPatAccount(widget.accessKey, _username);
      defaultToast(context, "保存成功");
      await reloadIsPro();
      Navigator.of(context).pop();
    } catch (e, s) {
      print("$e\n$s");
      defaultToast(context, "保存失败: $e");
    }
  }
}
