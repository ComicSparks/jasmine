import 'package:flutter/material.dart';

import '../basic/commons.dart';
import '../basic/methods.dart';
import '../configs/is_pro.dart';
import 'access_key_replace_screen.dart';
import 'components/right_click_pop.dart';

class ProScreen extends StatefulWidget {
  const ProScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> {
  String _username = "";

  @override
  void initState() {
    methods.loadLastLoginUsername().then((value) {
      setState(() {
        _username = value;
      });
    });
    proEvent.subscribe(_setState);
    super.initState();
  }

  @override
  void dispose() {
    proEvent.unsubscribe(_setState);
    super.dispose();
  }

  void _setState(_) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return rightClickPop(child: buildScreen(context), context: context);
  }

  Widget buildScreen(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var min = size.width < size.height ? size.width : size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text("发电中心"),
      ),
      body: ListView(
        children: [
          SizedBox(
            width: min / 2,
            height: min / 2,
            child: Center(
              child: Icon(
                isPro ? Icons.offline_bolt : Icons.offline_bolt_outlined,
                size: min / 3,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Center(child: Text(_username)),
          Container(height: 20),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "登录账号才能确认发电状态\n"
              "点击\"我曾经发过电\"进同步发电状态\n"
              "点击\"我刚才发了电\"兑换作者给您的礼物卡\n"
              "更换\"发电方式\"可能解决FAIL问题\n"
              "去\"关于\"界面找到维护地址用爱发电",
            ),
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: const Text("登录兑换"),
                  subtitle: Text(
                    proInfoAf.isPro
                        ? "发电中 (${DateTime.fromMillisecondsSinceEpoch(1000 * proInfoAf.expire).toString()})"
                        : "未发电",
                  ),
                ),
              ),
              Expanded(
                child: ListTile(
                  title: const Text("PAT会员"),
                  subtitle: Text(
                    proInfoPat.isPro ? "发电中" : "未发电",
                  ),
                  onTap: () {
                    defaultToast(context, "点击下方PAT会员进行设置");
                  },
                ),
              ),
            ],
          ),
          const Divider(),
          ListTile(
            title: const Text("我曾经发过电"),
            onTap: () async {
              try {
                await methods.reloadPro();
                defaultToast(context, "SUCCESS");
              } catch (e, s) {
                print("$e\n$s");
                defaultToast(context, "FAIL");
              }
              await reloadIsPro();
              setState(() {});
            },
          ),
          const Divider(),
          ListTile(
            title: const Text("我刚才发了电"),
            onTap: () async {
              final code = await displayTextInputDialog(context, title: "输入代码");
              if (code != null && code.isNotEmpty) {
                try {
                  await methods.inputCdKey(code);
                  defaultToast(context, "SUCCESS");
                } catch (e, s) {
                  print("$e\n$s");
                  defaultToast(context, "FAIL");
                }
              }
              await reloadIsPro();
              setState(() {});
            },
          ),
          const Divider(),
          const ProServerNameWidget(),
          const Divider(),
          ...patProWidgets(),
          const Divider(),
        ],
      ),
    );
  }

  List<Widget> patProWidgets() {
    List<Widget> widgets = [];
    if (proInfoPat.accessKey.isNotEmpty) {
      var text = "已记录密钥";
      if (proInfoPat.patId.isNotEmpty) {
        text += "\nPAT账号: ${proInfoPat.patId}";
      }
      if (proInfoPat.bindUid.isNotEmpty) {
        text += "\n绑定账号: ${proInfoPat.bindUid}";
      }
      if (proInfoPat.requestDelete > 0) {
        DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
          proInfoPat.requestDelete * 1000,
          isUtc: true,
        );
        text += "\n解绑时间: ${dateTime.toLocal()}";
      }
      if (proInfoPat.reBind > 0) {
        DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
          proInfoPat.reBind * 1000,
          isUtc: true,
        );
        text += "\n可重绑时间: ${dateTime.toLocal()}";
      }
      
      List<TextSpan> append = [];
      if (proInfoPat.bindUid == "") {
        append.add(const TextSpan(
          text: "\n(点击绑定到当前账号)",
          style: TextStyle(color: Colors.blue),
        ));
      } else if (proInfoPat.bindUid != _username) {
        append.add(const TextSpan(
          text: "\n(已绑定到其他账号，点击重新绑定)",
          style: TextStyle(color: Colors.red),
        ));
      } else if (proInfoPat.isPro == false) {
        append.add(const TextSpan(
          text: "\n(未检测到发电状态)",
          style: TextStyle(color: Colors.orange),
        ));
      } else {
        append.add(const TextSpan(
          text: "\n(正常)",
          style: TextStyle(color: Colors.green),
        ));
      }
      
      widgets.add(ListTile(
        onTap: () async {
          var choose = await chooseMapDialog<int>(
            context,
            title: "选择操作",
            values: {
              "更新PAT状态": 2,
              "绑定到当前账号": 3,
              "更换PAT密钥": 1,
              "清除PAT信息": 4,
            },
          );
          switch (choose) {
            case 1:
              addPatAccount();
              break;
            case 2:
              reloadPatAccount();
              break;
            case 3:
              bindThisAccount();
              break;
            case 4:
              clearPatInfo();
              break;
          }
        },
        title: const Text("PAT会员"),
        subtitle: Text.rich(TextSpan(children: [
          TextSpan(text: text),
          ...append,
        ])),
      ));
    } else {
      widgets.add(ListTile(
        onTap: () {
          addPatAccount();
        },
        title: const Text("PAT会员"),
        subtitle: const Text("点击绑定PAT会员"),
      ));
    }
    return widgets;
  }

  void addPatAccount() async {
    String? key = await displayTextInputDialog(context, title: "输入PAT授权码");
    if (key != null && key.isNotEmpty) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return AccessKeyReplaceScreen(accessKey: key);
          },
        ),
      );
      await reloadIsPro();
      setState(() {});
    }
  }

  void reloadPatAccount() async {
    defaultToast(context, "请稍候");
    try {
      await methods.reloadPatAccount();
      await reloadIsPro();
      defaultToast(context, "SUCCESS");
    } catch (e) {
      defaultToast(context, "FAIL : $e");
    }
    setState(() {});
  }

  void bindThisAccount() async {
    defaultToast(context, "请稍候");
    try {
      await methods.bindPatAccount(proInfoPat.accessKey, _username);
      await methods.reloadPatAccount();
      await reloadIsPro();
      defaultToast(context, "SUCCESS");
    } catch (e) {
      defaultToast(context, "FAIL : $e");
    }
    setState(() {});
  }

  void clearPatInfo() async {
    await methods.clearPat();
    await reloadIsPro();
    defaultToast(context, "已清除");
    setState(() {});
  }
}

class ProServerNameWidget extends StatefulWidget {
  const ProServerNameWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProServerNameWidgetState();
}

class _ProServerNameWidgetState extends State<ProServerNameWidget> {
  String _serverName = "";

  @override
  void initState() {
    methods.getProServerName().then((value) {
      setState(() {
        _serverName = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text("发电方式"),
      subtitle: Text(_loadServerName()),
      onTap: () async {
        final serverName = await chooseMapDialog(
          context,
          title: "选择发电方式",
          values: {
            "风力发电": "HK",
            "水力发电": "US",
          },
        );
        if (serverName != null && serverName.isNotEmpty) {
          await methods.setProServerName(serverName);
          setState(() {
            _serverName = serverName;
          });
        }
      },
    );
  }

  String _loadServerName() {
    switch (_serverName) {
      case "HK":
        return "风力发电";
      case "US":
        return "水力发电";
      default:
        return "";
    }
  }
}
