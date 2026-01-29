import 'dart:convert';

import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:jasmine/basic/commons.dart';
import 'package:jasmine/basic/methods.dart';
import 'package:jasmine/configs/is_pro.dart';

enum LoginStatus {
  notSet,
  logging,
  loginField,
  loginSuccess,
}

late SelfInfo _selfInfo;
LoginStatus _status = LoginStatus.notSet;
String _loginMessage = "";
final Event _event = Event();

SelfInfo get selfInfo => _selfInfo;

Event get loginEvent => _event;

LoginStatus get loginStatus => _status;

String get loginMessage => _loginMessage;

set _loginState(LoginStatus value) {
  _status = value;
  _event.broadcast();
}

Future initLogin(BuildContext context) async {
  try {
    _loginState = LoginStatus.logging;
    final preLogin = await methods.preLogin();
    _loginMessage = preLogin.message ?? "";
    if (!preLogin.preSet) {
      _loginState = LoginStatus.notSet;
    } else if (preLogin.preLogin) {
      _selfInfo = preLogin.selfInfo!;
      _loginState = LoginStatus.loginSuccess;
      fav(context);
    } else {
      _loginState = LoginStatus.loginField;
    }
  } catch (e, st) {
    print("$e\n$st");
    _loginState = LoginStatus.loginField;
  } finally {
    reloadIsPro();
  }
}

List<FavoriteFolderItem> favData = [];

Widget createFavoriteFolderItemTile(BuildContext context) {
  return ListTile(
    title: const Text("创建收藏文件夹"),
    onTap: () async {
      if (loginStatus != LoginStatus.loginSuccess) {
        defaultToast(context, "请先登录");
        return;
      }
      var name = await displayTextInputDialog(context,
          title: "创建收藏文件夹", hint: "文件夹名称");
      if (name == null) {
        return;
      }
      await methods.createFavoriteFolder(name);
      fav(context);
      defaultToast(context, "创建成功");
    },
  );
}

Widget deleteFavoriteFolderItemTile(BuildContext context) {
  return ListTile(
    title: const Text("删除收藏文件夹"),
    onTap: () async {
      if (loginStatus != LoginStatus.loginSuccess) {
        defaultToast(context, "请先登录");
        return;
      }
      var j = favData.map((i) {
        return MapEntry(i.name, i.fid);
      }).toList();
      j.add(const MapEntry("默认 / 不删除", 0));
      var v = await chooseMapDialog<int>(
        context,
        title: "删除资料夹",
        values: Map.fromEntries(j),
      );
      if (v != null && v != 0) {
        await methods.deleteFavoriteFolder(v);
        fav(context);
        defaultToast(context, "删除成功");
      }
    },
  );
}

Widget renameFavoriteFolderItemTile(BuildContext context) {
  return ListTile(
    title: const Text("重命名收藏文件夹"),
    onTap: () async {
      if (loginStatus != LoginStatus.loginSuccess) {
        defaultToast(context, "请先登录");
        return;
      }
      var j = favData.map((i) {
        return MapEntry(i.name, i.fid);
      }).toList();
      j.add(const MapEntry("默认 / 不重命名", 0));
      var v = await chooseMapDialog<int>(
        context,
        title: "重命名资料夹",
        values: Map.fromEntries(j),
      );
      if (v != null && v != 0) {
        var name = await displayTextInputDialog(context,
            title: "重命名收藏文件夹", hint: "文件夹名称");
        if (name == null) {
          return;
        }
        await methods.renameFavoriteFolder(v, name);
        fav(context);
        defaultToast(context, "重命名成功");
      }
    },
  );
}

Future fav(BuildContext buildContext) async {
  try {
    favData = (await methods.favorite()).folderList;
  } catch (e, st) {
    print("$e\n$st");
    defaultToast(buildContext, "$e");
  }
}

Future login(String username, String password, BuildContext context) async {
  try {
    _loginState = LoginStatus.logging;
    final selfInfo = await methods.login(username, password);
    _selfInfo = selfInfo;
    _loginState = LoginStatus.loginSuccess;
    fav(context);
  } catch (e, st) {
    print("$e\n$st");
    _loginState = LoginStatus.loginField;
    _loginMessage = "$e";
  }
}

Future loginDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return Container(
        width: 30,
        height: 30,
        color: Colors.black.withOpacity(.1),
        child: Center(
          child: _LoginDialog(),
        ),
      );
    },
  );
}

Future showLoginAgreementBottomSheet(BuildContext context) async {
  await showMaterialModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xAA000000),
    builder: (context) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * (.6),
        child: const _LoginAgreementSheet(),
      );
    },
  );
}

class LoginAgreementHint extends StatelessWidget {
  final EdgeInsetsGeometry padding;

  const LoginAgreementHint({
    super.key,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 8),
  });

  @override
  Widget build(BuildContext context) {
    final agreeStyle =
        Theme.of(context).textTheme.bodyMedium
    //        ?.copyWith(color: Colors.grey)
    ;
    final agreeLinkStyle = agreeStyle?.copyWith(
      decoration: TextDecoration.underline,
      // decorationColor: Colors.grey.shade600,
      // color: Colors.grey.shade600,
    );
    return Padding(
      padding: padding,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text("登录即为同意 ", style: agreeStyle),
          InkWell(
            onTap: () => showLoginAgreementBottomSheet(context),
            child: Text("使用协议", style: agreeLinkStyle),
          ),
        ],
      ),
    );
  }
}

class _LoginAgreementSheet extends StatelessWidget {
  const _LoginAgreementSheet();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bodyStyle = textTheme.bodyMedium;
    final captionStyle = textTheme.bodySmall?.copyWith(color: Colors.grey);
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
                Expanded(
                  child: Text(
                    "使用协议",
                    style: textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                children: [
                  Text(
                    "继续登录/使用即表示您已阅读并同意以下内容：",
                    style: bodyStyle,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "1. 为保障安全与改进服务，您的登录、浏览、搜索、下载等操作记录（含必要的设备与网络信息）可能会被供应商或服务器保存与分析。",
                    style: bodyStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "2. 请勿上传、传播或利用本服务从事任何违法违规行为；如涉及敏感内容，请自行审慎判断并遵守当地法律法规。；因此产生的后果由您自行承担。",
                    style: bodyStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "3. 本应用展示的任何信息仅供参考与交流，不构成医疗/诊断/治疗建议；因此产生的后果（含生理、病理等）由您自行承担。",
                    style: bodyStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "4. 我们可能在必要时更新协议内容；更新后继续使用视为您接受更新。",
                    style: bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "* 若您不同意上述条款，请停止登录并退出使用。",
                    // style: captionStyle,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: MaterialButton(
                  color: Colors.orange.shade700,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "我知道了",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<_LoginDialog> {
  var _username = "";
  var _password = "";

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      final username = await methods.loadUsername();
      final password = await methods.loadPassword();
      setState(() {
        _username = username;
        _password = password;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: MediaQuery.of(context).size.width - 90,
      margin: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Material(
        color: Colors.transparent,
        child: ListView(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                Expanded(child: Container()),
              ],
            ),
            ListTile(
              title: Text("账号"),
              subtitle: Text(_username == "" ? "未设置" : _username),
              onTap: () async {
                String? input = await displayTextInputDialog(
                  context,
                  src: _username,
                  title: '账号',
                  hint: '请输入账号',
                );
                if (input != null) {
                  setState(() {
                    _username = input;
                  });
                }
              },
            ),
            ListTile(
              title: const Text("密码"),
              subtitle: Text(_password == "" ? "未设置" : '\u2022' * 10),
              onTap: () async {
                String? input = await displayTextInputDialog(
                  context,
                  src: _password,
                  title: '密码',
                  hint: '请输入密码',
                  isPasswd: true,
                );
                if (input != null) {
                  setState(() {
                    _password = input;
                  });
                }
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  child: MaterialButton(
                    color: Colors.orange.shade700,
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await login(_username, _password, context);
                      await reloadIsPro();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: const Text(
                        "保存",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
