import 'dart:convert';

import 'package:flutter/material.dart';

import '../basic/commons.dart';
import 'package:jasmine/basic/log.dart';
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
                debugPrient("$e\n$s");
                defaultToast(context, _proErrorMessage(e));
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
                  debugPrient("$e\n$s");
                  defaultToast(context, _proErrorMessage(e));
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
          const ReferralTiles(),
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

const _defaultProServerId = "ilsfsfkt75kp2nnfievnqcjmza0ooksc";

const _proServerIds = <String>[
  "ORI",
  "jdtvmstd22deytdzenvydyil3e0jkxfu",
  "mek5hrs65poai2eqjjofqr7ynu0nxkqx",
  "6h2odtaft7fuvssx6v5b73pwie0dfgvm",
  "ilsfsfkt75kp2nnfievnqcjmza0ooksc",
  "wuwjgjgautzqf6ybwmma6e2pw40iilcy",
  "phuto27lxoqo4skduakcs4siwu0ffwoh",
  "4sfkal33ch44fle6u6smhwufri0cmgnv",
];

final _proServerIdPattern = RegExp(r'^[a-z0-9]+$');
final _proServerRegionPattern = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)+$');

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
            for (final id in _proServerIds) id: id,
          },
        );
        if (serverName != null && serverName.isNotEmpty) {
          final name = serverName;
          await methods.setProServerName(name);
          setState(() {
            _serverName = name;
          });
        }
      },
    );
  }

  String _loadServerName() {
    if (_proServerIds.contains(_serverName)) {
      return _serverName;
    }
    final parts = _serverName.split('|');
    if (parts.length == 2 &&
        _proServerIdPattern.hasMatch(parts[0]) &&
        _proServerRegionPattern.hasMatch(parts[1])) {
      return parts[0];
    }
    return _defaultProServerId;
  }
}

class ReferralTiles extends StatefulWidget {
  const ReferralTiles({Key? key}) : super(key: key);

  @override
  State<ReferralTiles> createState() => _ReferralTilesState();
}

class _ReferralTilesState extends State<ReferralTiles> {
  String _username = "";
  String _referrer = "";
  int _unbindWaitDays = 0;
  int _campaignStart = 0;
  int _campaignEnd = 0;

  @override
  void initState() {
    super.initState();
    methods.loadLastLoginUsername().then((value) {
      if (!mounted) return;
      setState(() {
        _username = value;
      });
    });
    _load();
  }

  Future<void> _load() async {
    try {
      final raw = await methods.referralCall('{"action":"local"}');
      if (!mounted || raw.isEmpty) return;
      _apply(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {}
  }

  Future<void> _referral(String payload, String ok) async {
    try {
      final raw = await methods.referralCall(payload);
      if (!mounted) return;
      if (raw.isNotEmpty) {
        _apply(jsonDecode(raw) as Map<String, dynamic>);
      }
      defaultToast(context, ok);
    } catch (e) {
      if (mounted) defaultToast(context, _referralError(e));
    }
  }

  void _apply(Map<String, dynamic> map) {
    setState(() {
      _referrer = (map["referrer"] ?? "").toString();
      _unbindWaitDays = _asInt(map["unbind_wait_days"]);
      _campaignStart = _asInt(map["campaign_start"]);
      _campaignEnd = _asInt(map["campaign_end"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: const Text("推荐人"),
          subtitle: Text(_referrer),
          onTap: () async {
            if (_username.isEmpty) {
              defaultToast(context, "先登录");
              return;
            }
            if (_referrer.isNotEmpty) return;
            final name = await displayTextInputDialog(context, title: "填写推荐人用户名");
            if (name == null || name.trim().isEmpty) return;
            await _referral(
              jsonEncode({"action": "bind", "referrer": name.trim()}),
              "已绑定",
            );
          },
          onLongPress: () async {
            if (_referrer.isEmpty) return;
            if (_unbindWaitDays > 0) {
              defaultToast(context, "还有 $_unbindWaitDays 天");
              return;
            }
            final ok = await confirmDialog(context, "解绑推荐人", "确定解绑推荐人？");
            if (!ok || !context.mounted) return;
            await _referral('{"action":"unbind"}', "已解绑");
          },
        ),
        ListTile(
          title: const Text("活动时间"),
          subtitle: Text(_campaignLabel(_campaignStart, _campaignEnd)),
        ),
      ],
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? "") ?? 0;
}

String _campaignLabel(int start, int end) {
  if (start <= 0 || end <= 0) return "";
  String fmt(int seconds) {
    final time = DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true).toLocal();
    String two(int value) => value.toString().padLeft(2, "0");
    return "${time.year}-${two(time.month)}-${two(time.day)} ${two(time.hour)}:${two(time.minute)}";
  }

  return "${fmt(start)} — ${fmt(end)}";
}

String _referralError(Object error) {
  final text = error.toString();
  final wait = RegExp(r"REFERRER_UNBIND_WAIT:(\d+)").firstMatch(text);
  if (wait != null) return "还有 ${wait.group(1)} 天";
  if (text.contains("REFERRER_SELF")) return "不能填写自己";
  if (text.contains("REFERRER_LOCKED")) return "已经绑定了推荐人";
  if (text.contains("REFERRER_MUTUAL")) return "不能互相绑定";
  if (text.contains("REFERRER_NOT_BOUND")) return "还没有推荐人";
  return text;
}

String _proErrorMessage(Object e) {
  var text = e.toString();
  const prefixes = ['Bad state: ', 'Exception: ', 'Error: '];
  for (final prefix in prefixes) {
    if (text.startsWith(prefix)) {
      text = text.substring(prefix.length);
      break;
    }
  }
  text = text.trim();
  if (text.isEmpty) {
    text = 'SERVER_FAILED';
  }
  const messages = <String, String>{
    'NETWORK_TIMEOUT': '网络超时，请检查网络或更换发电方式',
    'NETWORK_UNREACHABLE': '连接不上服务器，请检查网络或更换发电方式',
    'SERVER_FAILED': '服务器处理失败',
    'SERVER_RESPONSE_INVALID': '服务器返回异常',
    'REQUEST_INVALID': '请求无效',
    'ORDER_NOT_SYNCED': '订单尚未同步，请稍后再试',
    'ORDER_ALREADY_USED': '订单已被使用',
    'ORDER_AMOUNT_INVALID': '订单金额无效',
    'TICKET_NOT_FOUND': '兑换券不存在',
    'TICKET_ALREADY_USED': '兑换券已被使用',
    'TICKET_EVENT_USED': '活动兑换券已参与',
  };
  return messages[text] ?? text;
}
